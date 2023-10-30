# Klipper fails to start

You have everything flashed up, you were able to get the UUID's of all your devices, you thought it was smooth sailing from this point. Then you booted the printer only go find the big red warning box of Klipper failing to start.

Really, this isn't a bad situation to be in. At this point it is all just configuration in the printer.cfg file to get everything up and running. 

This is the best time to have a look at your manufacture sample configurations for your device. I've linked to a few (not all) in the [mainboard common_hardware](../mainboard_flashing/common_hardware) and [toolhead common_hardware](../toolhead_flashing/common_hardware) folders. These sample configs will have all the pin numberings for the different headers (heater, thermistor, fans, etc.) that you will need to replicate into your main printer config folder.

### MCU

First thing, you need to make sure you have the UUID of each CAN device set against their corresponding MCU in your config file. 
The mainboard of your printer is always just called `[mcu]`, and any subsequent boards (ie. CAN toolheads in this case) have their own name and are labelled `[mcu toolheadname]` with the "toolheadname" being what you want to call it. Some sample configs call it `[mcu can0]`, BigTreeTech like to call theirs `[mcu EBBCan]`, but at the end of the day it's an arbitrary label. You can call it `[mcu whoopy]` if you want to, as long as you consistently use that name for all your pin assignments down the line (we'll get to that later).

If you are using a standalone CAN adapter (eg. a U2C or UTOC or similar) then it is likely that your mainboard should be left completely alone and still be set as per manufacturer instructions. Probably something like:

```
[mcu]
serial: /dev/serial/by-id/usb-Klipper_stm32f446xx_37001A001851303439363932-if00
```
However, if you are using USB-CAN-Bridge mode on your mainboard then you need to make sure this has now been changed to show your **mainboard's** canbus UUID. Something like:
```
[mcu]
canbus_uuid: a396d68a95a3
```
In either case, you will need to set a secondary MCU for your toolhead board. This will *always* be a canbus_uuid as that is the whole point of this guide.
Again, the name you give it is arbitrary, but it's probably easier to stick to whatever the manufacturer sample config has set.
eg:
```
[mcu EBBCan]
canbus_uuid: ec60cf516124
```

### Pins

The next step is to set all the correct pins for all of hte functions that are now on your toolhead instead of your mainboard. Usually this is the `[extruder]` section (along with the `[tmcxxxx extruder]` TMC section), any `[fan]` and `[heater_fan hotend_fan]` sections that are for your hotend/part cooling fans, your `[probe]` section, maybe the `endstop_pin:` in your `[stepper_x]` section if you now have the x-endstop switch plugged in to your toolhead, and anything else that is plugged in to your toolhead.

What I do is I have my printer.cfg open in one window, and the sample config for my toolhead open in a seperate window next to it. Then I go to each section (eg. the `[extruder]` section) and change any of my old pin values for the corresponding ones in the sample config. Take note that **any** pin that is now being used on your toolhead needs to have the MCU name as a prefix. For example, if your toolhead mcu is called `[mcu EBBCan]`, and the step_pin on your toolhead is `PD0`, then in your config you have to call the pin `EBBCan:PD0` and these names **are case sensitive**. So any toolhead pins will look something like:

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/f4864243-5f7e-47ee-82b2-fc0f1d9df8e5)

Go through your printer.cfg until all "things" that are connected to your toolhead have had their pins changed.

### "ADC out of range" error

So you've set the MCU sections correctly, and gone through and changed all the pins that need changing, but Klipper still won't start and you get this strange "ADC out of range" error. This is a pretty good error to have all things considered. It just means that one of your temperature sensors is reading way too hot or way too cold for it to be normal. 

As  the whole point of this guide is getting a CAN toolhead running, there is a very high chance that the temperature sensor in question will be your hotend sensor. If you have it unplugged, you'll get this ADC error so check that first.

If it's definitely plugged in to the toolhead, double check that you set the pin in the printer.cfg correctly. If it's still "looking" at the old mainboard temperature sensor pin location then it will also act the same as if it was unplugged.

If you have a PT100 or PT1000 sensor and a board with the MAX31865 chip make sure the DIP switches are set correctly for your type of sensor and that the printer.cfg is correct. Most sample configs leave this section commented out so you will need to add it to your config (and make sure to remove the old `sensor_type:` and `sensor_pin:` options as the MAX31865 section will handle it instead).

If none of these options helped then make sure your thermistor hasn't broken a wire or crimp, and also have a look at your klippy.log and it'll tell you exactly what temperature sensor is the one with issues. Maybe it's not even your hotend thermistor, and maybe you've bumped loose your bed thermsitor or something.

### "MCU: Unable to connect"

Klipper won't start, and you get the error "MCU'yourMCUname': Unable to connect"

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/491e4654-981b-4a8b-be36-6d65c907fa95)

I'm going to assume you have looked at the above steps and your config file has all the correct UUID values against the correct MCU section. If that is the case then we need to check a few things.

First: run an `ip a` on your Pi and make sure it shows a can0 interface. If you don't see a can0 interface listed then check through the [can0 troubleshooting steps](./no_can0.md)

If the can0 network shows up fine, then we need to see if your device is actually online proplerly. We don't want Klipper actually attempting to start at this point, so the easiest way is to rename your `printer.cfg` to `printer.old` or something, then shudown your pi with `sudo shutdown now` then turn off **all** the power to your printer. Wait 30 seconds or so then turn it back on. After a minute or two your Pi should be online again so SSH back in and run `~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0` to do a query of all canbus devices. 

If no UUIDs show up (or you get only the mainboard UUID and not your toolhead) then check the [no UUID troubleshooting steps](./no_uuid.md). 

If your toolhead UUID shows up but it says `Application: Katapult` (or `Application: Canboot`) then your toolhead is on the CAN network but is in bootloader mode. Continue flashing with the toolhead flashing guide, starting at the ["Installing Klipper" section](../toolhead_flashing#installing-klipper).

If all your devices show up fine, and show `Application: Klipper` as they should, then rename your `printer.old` file back to `printer.cfg` and do a firmware restart. It might be that it all just works now and it needed a power cycle. If it still doesn't work then you may have an error in your printer.cfg (the mainboard UUID and toolhead UUID being swapped around is a common one). Go back to the **MCU** section above.


[Return to Troubleshooting](./)
