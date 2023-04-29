# SB2240 Steppers

The SB2240 has a TMC 2240 stepper driver for the extruder. This commonly does not work correctly in the Klipper default configuration, and causes an "undervoltage" errror: `uv_cp=1(Undervoltage!)`.

Undervoltage is a misnomer; this error actually occurs because of too much fluctuation in supply voltage due to back-EMF from the motor and voltage rail fluctuations from other devices, and may well happen because the supply voltage is momentarily too high.

The TMC 2240 has a sophisticated self-tuning capability that is actually required for correct operation with some motors and other circuits.

This guide assumes you have a Klipper installation after release 188, not all the GCODE features used here exist before that release.

## TMC 2240 configuration
One way to configure this is as follows (a complete example configuration will be included at the end):

* Turn off interpolation, as this interferes with autotuning. `interpolate: False`
* Configure the run current to about 60% of the maximum continuous rating of your motor. That will not actually be used most of the time, but the driver must know what it is. `run_current: 0.6`
* `rref: 12000` because that is the value of the resistor on the BTT board.
* We want to be in stealthChop mode all the time, therefore `stealthchop_threshold: 99999`
* Now we configure a set of driver hardware registers:
  * `driver_IHOLDDELAY: 8` This inserts a small delay before entering stationary hold mode.
  * `driver_IRUNDELAY: 2` This gives a slight ramp-up time when starting the motor.
  * `driver_TBL: 3`
  * `driver_TOFF: 4`
  * `driver_HEND: 3`
  * `driver_HSTRT: 4`
  * `driver_TPFD: 0` Following BigTreeTech's suggestion, this reduces the current spikes delivered to the input voltage line at one phase of the step cycle. Required, but not sufficient.
  * `driver_PWM_AUTOSCALE: True` Autotuning must be on.
  * `driver_PWM_AUTOGRAD: True` Autotuning must be on.
  * `driver_PWM_GRAD: 12` This should be calculated for your particular motor, but this is a sensible default for most pancake extruder steppers.
  * `driver_PWM_OFS: 40` This should be calculated for your particular motor, but this is a sensible default for most pancake extruder steppers.
  * `driver_PWM_REG: 15` This sets the autotuning rate to maximum.
  * `driver_PWM_LIM: 12` This sets the mode-switching current jerk compensation to minimum. This may not be strictly necessary.
  * `driver_SGT: 35` This may need adjusted for your particular setup, more on this later. This setting is the stallguard threshold, also used for sensorless homing, but on the TMC 2240 it also controls the sensitivity of the autotuning process. Especially, increasing this value can lower the driver temperature (the range is -64 to +63).
  * `driver_SEMIN: 2` Sets the lower end of the current band for current autotuning. This may not be strictly necessary.
  * `driver_SEMAX: 8` Sets the upper end of the current band for current autotuning. This may not be strictly necessary.

## Extra configuration by GCODE macro

Now, some of the registers we need to change cannot be written from the configuration, so we need a gcode macro. This must be called from your `PRINT_START`, or before any other use of the extruder.

```
[gcode_macro configure_extruder]
gcode:
  # Enable accurate stall current measurement
  SET_TMC_FIELD STEPPER=extruder FIELD=pwm_meas_sd_enable VALUE=1
  SET_TMC_FIELD STEPPER=extruder FIELD=sg4_filt_en VALUE=1
  # Set the StealthChop stall detection threshold (may not be completely necessary)
  SET_TMC_FIELD STEPPER=extruder FIELD=SG4_THRS VALUE=10
  # Set the hold current to zero, and completely switch off the motor when it is not in use
  SET_TMC_FIELD STEPPER=extruder FIELD=IHOLD VALUE=0
  SET_TMC_FIELD STEPPER=extruder FIELD=freewheel VALUE=1
  # Set the max expected velocity to a value such that we are unlikely to switch to fullstepping except during a very fast retraction or prime
  SET_TMC_FIELD STEPPER=extruder FIELD=THIGH VELOCITY=50
  # Use CoolStep, but we need a certain step frequency for it to work
  SET_TMC_FIELD STEPPER=extruder FIELD=TCOOLTHRS VALUE=4000
  # But do switch to PWM autotuning when at high flow
  SET_TMC_FIELD STEPPER=extruder FIELD=TPWMTHRS VELOCITY=1
  # Allow the motor to freewheel when not in use, means it runs cooler
  SET_TMC_FIELD STEPPER=extruder FIELD=freewheel VALUE=1
  # Set the temperature prewarning to something reasonable. Cosmetic, Klipper does nothing with this
  SET_TMC_FIELD STEPPER=extruder FIELD=OVERTEMPPREWARNING_VTH VALUE=2885 # 7.7 * 100 C + 2038
  # The following is absolutely critical: set the overvoltage snubber to a sensible voltage.
  # This should be set to about 0.8 V above your power supply's idle voltage.
  # Your PSU voltage can be read from the TMC 2240 by issuing a GCODE command:
  # DUMP_TMC stepper=extruder register=ADC_VSUPPLY_AIN
  # The voltage is the value of adc_vsupply times by 0.009732
  {% set v = (24.7/0.009732)|int %}
  SET_TMC_FIELD STEPPER=extruder FIELD=OVERVOLTAGE_VTH VALUE={ v }
```

## Hotend configuration
If you have a Phaetus Rapido hotend, or another fast-heating ceramic heater element hotend, you may find the following also necessary:
* `pwm_cycle_time: 0.02` Run the PWM for the hotend much faster than the default.
* `smooth_time: 0.5` Increase the responsiveness of the derivative term in the PID controller.
* `max_power: 0.8` Don't ever run the heater 100% of the time, give the supply capacitors some time to recharge. 0.8 may still be too high, some users have needed as little as 0.5, especially with UHF hotends. This will not restrict flow, as the heater usually needs a PWM rate of no more than about 40% at any time.

Retuning the hotend PID will be necessary after applying that configuration.

## Configuration example

This assumes you named the toolhead `sb2240`, and use a 2-wire PT1000 on the MAX port of the SB2240 for a hotend thermistor.

```
#####################################################################
#   Extruder
#####################################################################

##  Connected to MOTOR_6
##  Heater - HE0
##  Thermistor - PT100
[extruder]
step_pin: sb2240:PD0
dir_pin: !sb2240:PD1
enable_pin: !sb2240:PD2
##  Update value below when you perform extruder calibration
##  If you ask for 100mm of filament, but in reality it is 98mm:
##  rotation_distance = <previous_rotation_distance> * <actual_extrude_distance> / 100
##  22.6789511 is a good starting point
rotation_distance: 22.6789511   #Bondtech 5mm Drive Gears
##  Update Gear Ratio depending on your Extruder Type
##  Use 50:17 for Afterburner/Clockwork (BMG Gear Ratio)
##  Use 80:20 for M4, M3.1
gear_ratio: 50:10               #BMG Gear Ratio
microsteps: 32
full_steps_per_rotation: 200    #200 for 1.8 degree, 400 for 0.9 degree
nozzle_diameter: 0.400
filament_diameter: 1.75
instantaneous_corner_velocity: 1.5
max_extrude_cross_section: 0.8

heater_pin: sb2240:PB13 # Heat0
pwm_cycle_time: 0.02
smooth_time: 0.5
max_power: 0.8

sensor_type: MAX31865
sensor_pin: sb2240:PA4
spi_speed: 1000000
#   The SPI speed (in hz) to use when communicating with the chip.
#   The default is 4000000.
spi_software_miso_pin: sb2240:PA6
spi_software_mosi_pin: sb2240:PA7
spi_software_sclk_pin: sb2240:PA5
#   See the "common SPI settings" section for a description of the
#   above parameters.
#tc_type: K
#tc_use_50Hz_filter: True
#tc_averaging_count: 1
#   The above parameters control the sensor parameters of MAX31856
#   chips. The defaults for each parameter are next to the parameter
#   name in the above list.
#rtd_nominal_r: 1000
#rtd_reference_r: 4300
rtd_num_of_wires: 2
#rtd_use_50Hz_filter: True
#   The above parameters control the sensor parameters of MAX31865
#   chips. The defaults for each parameter are next to the parameter
#   name in the above list.
#control: pid
#pid_kp = 19.755
#pid_ki = 0.770
#pid_kd = 126.680
min_extrude_temp: 170
#   The minimum temperature (in Celsius) at which extruder move
#   commands may be issued. The default is 170 Celsius.
min_temp: 0
max_temp: 300

[tmc2240 extruder]
cs_pin: sb2240:PA15
#   The pin corresponding to the TMC2240 chip select line. This pin
#   will be set to low at the start of SPI messages and raised to high
#   after the message completes. This parameter must be provided.
spi_speed: 500000
spi_software_sclk_pin: sb2240:PB10
spi_software_mosi_pin: sb2240:PB11
spi_software_miso_pin: sb2240:PB2
#   See the "common SPI settings" section for a description of the
#   above parameters.
#chain_position:
#chain_length:
#   These parameters configure an SPI daisy chain. The two parameters
#   define the stepper position in the chain and the total chain length.
#   Position 1 corresponds to the stepper that connects to the MOSI signal.
#   The default is to not use an SPI daisy chain.
interpolate: False
#   If true, enable step interpolation (the driver will internally
#   step at a rate of 256 micro-steps). The default is True.
run_current: 0.6
#   The amount of current (in amps RMS) to configure the driver to use
#   during stepper movement. This parameter must be provided.
# hold_current: 0.12
#   The amount of current (in amps RMS) to configure the driver to use
#   when the stepper is not moving. Setting a hold_current is not
#   recommended (see TMC_Drivers.md for details). The default is to
#   not reduce the current.
rref: 12000
#   The resistance (in ohms) of the resistor between IREF and GND. The
#   default is 12000.
stealthchop_threshold: 99999
#   The velocity (in mm/s) to set the "stealthChop" threshold to. When
#   set, "stealthChop" mode will be enabled if the stepper motor
#   velocity is below this value. The default is 0, which disables
#   "stealthChop" mode.
driver_IHOLDDELAY: 8
driver_IRUNDELAY: 2
#driver_TPOWERDOWN: 10
driver_TBL: 3
driver_TOFF: 4
driver_HEND: 3
driver_HSTRT: 4
#driver_FD3: 0
driver_TPFD: 0
##driver_CHM: 0
##driver_VHIGHFS: 0
##driver_VHIGHCHM: 0
##driver_DISS2G: 0
##driver_DISS2VS: 1
driver_PWM_AUTOSCALE: True
driver_PWM_AUTOGRAD: True
#driver_PWM_FREQ: 2
##driver_FREEWHEEL: 0
driver_PWM_GRAD: 12
driver_PWM_OFS: 40
driver_PWM_REG: 15
driver_PWM_LIM: 12
driver_SGT: 30
driver_SEMIN: 2
#driver_SEUP: 3
driver_SEMAX: 8
#driver_SEDN: 2
#driver_SEIMIN: 0
#driver_SFILT: 1
#driver_SG4_ANGLE_OFFSET: 1
#   Set the given register during the configuration of the TMC2240
#   chip. This may be used to set custom motor parameters. The
#   defaults for each parameter are next to the parameter name in the
#   above list.
diag0_pin: sb2240:PB3
#diag1_pin:
#   The micro-controller pin attached to one of the DIAG lines of the
#   TMC2240 chip. Only a single diag pin should be specified. The pin
#   is "active low" and is thus normally prefaced with "^!". Setting
#   this creates a "tmc2240_stepper_x:virtual_endstop" virtual pin
#   which may be used as the stepper's endstop_pin. Doing this enables
#   "sensorless homing". (Be sure to also set driver_SGT to an
#   appropriate sensitivity value.) The default is to not enable
#   sensorless homing.

[gcode_macro configure_extruder]
gcode:
  SET_TMC_FIELD STEPPER=extruder FIELD=pwm_meas_sd_enable VALUE=1
  SET_TMC_FIELD STEPPER=extruder FIELD=sg4_filt_en VALUE=1
  SET_TMC_FIELD STEPPER=extruder FIELD=freewheel VALUE=1
  SET_TMC_FIELD STEPPER=extruder FIELD=SG4_THRS VALUE=10
  SET_TMC_FIELD STEPPER=extruder FIELD=IHOLD VALUE=0
  SET_TMC_FIELD STEPPER=extruder FIELD=THIGH VELOCITY=50
  SET_TMC_FIELD STEPPER=extruder FIELD=TCOOLTHRS VALUE=4000
  SET_TMC_FIELD STEPPER=extruder FIELD=TPWMTHRS VELOCITY=1
  SET_TMC_FIELD STEPPER=extruder FIELD=OVERTEMPPREWARNING_VTH VALUE=2885 # 7.7 * 100 C + 2038
  {% set v = (24.7/0.009732)|int %}
  SET_TMC_FIELD STEPPER=extruder FIELD=OVERVOLTAGE_VTH VALUE={ v }
```
