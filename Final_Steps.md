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

If you are running a dedicated USB Can adapter (like a U2C) then you don't need to do anything for this device, it won't be used/seen in the printer.cfg.

If you are running a USB-CAN-Bridge Mainboard, then you will need to now set your main [mcu] section to use the UUID of your mainboard (that you found in [this step](./mainboard_flashing#klipper-is-now-installed))

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/11040725-aa0f-4f98-bb8d-df4420320096)


Note that the mainboard **must** be simply called [mcu]. And also note that there is no `restart_method` or anything else in this section, just the `canbus_uuid`.

For your toolhead, you will need to add a new mcu section but as this is a ["extra" mcu](https://www.klipper3d.org/Config_Reference.html#mcu-my_extra_mcu) you need to give it a name. The name is arbitrary, but keeping it similar to what the manufacturer uses in their sample config files makes it easier later.

eg. if I called my board "EBBCan", then I would have the [mcu EBBCan] section with the UUID of my toolhead (that you found in [this step](./toolhead_flashing#klipper-is-now-installed))

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/4f3d2478-490b-41d9-8ee1-322d4a7f8117)


If you have completed the above and have the canbus uuid of your CAN device in your printer.cfg, then everything else is just a case of setting up the required pins with the toolhead MCU name prefixed to the pin name. 

Most toolheads will have a sample.cfg on their github, so it's usually a simple case of copy-pasting the required information from the sample into your own printer.cfg.

