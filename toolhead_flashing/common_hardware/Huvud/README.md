

[## Klipper configuration

### Firmware configuration

* Enable Micro-controller Architecture (STMicroelectronics STM32)
* Pick STM32F103
* Pick Bootloader offset (2KiB bootloader (HID Bootloader))
* Disable Use USB for communication (instead of serial)
* Enable Use CAN for communication (instead of seria)l
* Pick CAN pins (Pins PB8(rx) and PB9(tx))

It is possible to use USB instead of the CAN bus, like most other controller boards. 

### Bootloader and Flashing

The boards come preloaded with the HID bootloader for flashing over USB. Note that the board can not be powered over USB. 

To enter the bootloader pin BOOT1 must be connected to 3.3V when the board is powered up or reset. When in the bootloader the green LED will flash quickly. Flash with the command "make flash FLASH_DEVICE=1209:beba"

Hopefully a CAN capable bootloader will be developed to allow flashing over CAN bus.

### printer.cfg

[Example partial printer.cfg](printer.cfg)
](https://github.com/Esoterical/voron_canbus)



0.61
Hello! I love the Huvud boards--I have a ton of the V0.50 on my printers and just installed the first V0.61 on a printer last night! There were a few gotchas/clarifications as more people install this:

Add flashing instructions
-8Mhz clock for make menuconfig build
-Add note -- if the wrong bootloader option is selected and you try to flash the Huvud, it will not work--need to flash the bootloader again using an ST-Link

Updated pin descriptions:
Extruder
Step: PB3
Dir: PB4
Enable: PB5
Uart TX: PA9
uart (RX): PA10

Thermistor 1 - PA0
Thermistor 2 - PA1
Heater - PA6
Fan 1 - PA7
Fan 0 - PA8
Endstop 1 - PB10
Endstop 2 - PB11
Endstop 3 - PB12
ADXL CS pin - PB1
Diag for TMC2209? - PA15





