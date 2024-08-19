---
layout: default 
title: Final Steps
nav_order: 60
---

# Final Steps

So your CAN network is now running and you can see the CAN boards on it, everything is coming up Milhouse.

There are some last things you need to complete before your Klipper (on pi) will talk to the boards though.

# Update Config

You will need to add some settings to your printer.cfg in order for Klipper (on the Pi) to actually talk to your new CAN nodes. 

## Dedicated CAN adapter

If you are running a dedicated USB Can adapter (like a U2C) then you don't need to do anything for this device, it won't be used/seen in the printer.cfg, Just skip to the [Toolhead section](#toolhead).

## USB-CAN-Bridge Mainboard

If you are running a USB-CAN-Bridge Mainboard, then you will need to now set your main [mcu] section to use the UUID of your mainboard (that you found in [this step](./mainboard_flashing#klipper-is-now-installed))

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/11040725-aa0f-4f98-bb8d-df4420320096)


Note that the mainboard **must** be simply called [mcu]. And also note that there is no `restart_method` or anything else in this section, just the `canbus_uuid`.

## Toolhead

For your toolhead, the best first step is to look for a sample config from your manufacturer (links in the [Toolhead Common Hardware](./toolhead_flashing/common_hardware) section). You can simply copy this sample file to the config folder on your Pi, then in your printer.cfg add a line [include samplefilename.cfg] so klipper loads in any settings from this additional file as well as the settings in the main printer.cfg file.

![image](https://github.com/user-attachments/assets/6f322043-b750-48d2-a4fb-25c6e2bed6ee)

You will need to add (or modify) the new mcu section but as this is a ["extra" mcu](https://www.klipper3d.org/Config_Reference.html#mcu-my_extra_mcu) you need to give it a name. The name is arbitrary, but keeping it similar to what the manufacturer uses in their sample config files makes it easier later.

eg. if I called my board "EBBCan", then I would have the [mcu EBBCan] section with the UUID of my toolhead (that you found in [this step](./toolhead_flashing#klipper-is-now-installed))

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/4f3d2478-490b-41d9-8ee1-322d4a7f8117)

You will need to adjust a few things from the sample config file. Make sure to change any temperature sensor types so it matches what your *actual* temperature sensor in your printer. Also adjust any motor and extruder specific settings (motor run current, extruder rotation_distance, etc.) as the default values in the sample config may not match what is in your printer.

Once the sample config file matches your *actual* hardware, you need to go back to your printer.cfg and delete or comment out any section that is now in your sample config file. Things like the [extruder] section (including the [tmc2209 extruder] motor section), Fans, Probe, endstops, etc.

If you have the same section ative in both your printer.cfg and the sample config file, then Klipper will only "read" it once which means it may start looking at the wrong pins for your hardware. Having the hotend temperature sensor still set to the old mainboard pin is a common mistake, and this manifests as an "ADC out of range" error when Klipper tries to start (because it is looking at a pin on the mainboard that no longer has the temperature sensor plugged in to it).



