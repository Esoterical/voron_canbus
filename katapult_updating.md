---
layout: default  
title: Updating Katapult
parent: Updating
nav_order: 30
---
# Updating Katapult

Updating Katapult isn't something you should need to do regularly, if at all. If Katapult is currently working on your board (toolhead or mainboard or other) then just leave it as is.

The only time you should really need to update Katapult is if you are changing CAN speeds, and even then that's only on the toolhead. If you need to do this please refer to [Updating CAN Speed](./updating_can_speed.md)

You should never really have to update your Katapult on the mainboard. Even if you wish to change your CanBUS speeds you don't need to change Katapult **On the Mainboard** as it only communicates via USB and not via CAN.

## Updating Toolhead Katapult

This is only if you need to update katapult as well. If you are just doing a Klipper firmware update (because you updated Klipper on your Pi and now it is yelling at you or something) then skip to [here](#updating-toolhead-klipper)

**Step 1**

Change to your Katapult directory with `cd ~/katapult`
then go into the Katapult firmware config menu with `make menuconfig`
This time **make sure "Build Katapult deployment application" is configured** with the properly bootloader offset (same as the "Application start offset" that is relevant for your toolhead). Make sure all the rest of your settings are correct for your toolhead.

You can find screenshots of settings for common toolheads in the [Common Toolhead Hardware](./toolhead_flashing/common_hardware) section, but once again, **make sure "Build Katapult deployment application" is set**

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/e0482b4c-7a6b-4b6d-94bd-76e50a917f66)


This time when you run `make`, along with the normal katapult.bin file it will also generate a deployer.bin file. This deployer.bin is a fancy little tool that uses the existing bootloader (Katapult, or stock, or whatever) to "update" itself into the Katapult you just compiled.

So to update your Katapult, you just need to flash this deployer.bin file via your existing Katapult (in a very similar way you would flash klipper via Katapult).

**Step 2**

If you already have a functioning CAN setup, and your [mcu toolhead] canbus_uuid is in your printer.cfg, then you can force Katapult to reboot into Katapult mode by running:

```bash
python3 ~/katapult/scripts/flashtool.py -i can0 -u yourtoolheaduuid -r
```

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/eda51419-6ab4-49c5-9c33-a581b08d085c)

If will probably say "Flash success" **THIS IS NOT ACTUALLY FLASHING ANYTHING, YOU NEED TO CONTINUE WITH THE STEPS BELOW**

**Step 3**

If you don't have the UUID (or something has gone wrong with the klipper firmware and your toolboard is hung) then you can also double-press the RESET button on your toolhead to force Katapult to reboot into Katapult mode.

You can verify it is in the proper mode by running `python3 ~/katapult/scripts/flashtool.py -q`. If you see a "Detected UUID: xxxxxxxxx, Application: Katapult" device then it is good to go.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/ff9dcbb3-0456-4d87-8091-41d5d6050c02)

**Step4**

Once you are at this stage you can flash the deployer.bin by running:

```bash
python3 ~/katapult/scripts/flashtool.py -i can0 -u yourtoolheaduuid -f ~/katapult/out/deployer.bin
```

and your Katapult should update.

## Updating Mainboard Katapult

Again, it is very rare to ever need to update a working Katapult firmware on a USB-CAN-Bridge mainboard, because even if you are changing CAN speeds this won't affect the Katapult on a mainboard as it communicates over USB and doesn't actually care about the CANBus.

However, **if** you need to update katapult for whatever reason then follow the steps below.

**Step 1**

Change to your Katapult directory with `cd ~/katapult`
then go into the Katapult firmware config menu with `make menuconfig`

This time **make sure "Build Katapult deployment application" is configured** with the properly bootloader offset (same as the "Application start offset" that is relevant for your mainboard). Make sure all the rest of your settings are correct for your mainboard.

You can find screenshots of settings for common mainboards in the [Common Mainboard Hardware](./mainboard_flashing/common_hardware) section, but once again, **make sure "Build Katapult deployment application" is set**

If your board doesn't exist in the common_hardware folder already, then you want the Processor, Clock Reference, and Application Start offset to be set as per whatever board you are running. Set the "Build Katapult deployment application", and make sure "Communication Interface" is set to USB. Also make sure the "Support bootloader entry on rapid double click of reset button" is marked. It makes it so a double press of the reset button will force the board into Katapult mode. Makes re-flashing after a mistake a lot easier.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/7726b137-0079-4191-bd22-1b084345809f)

This time when you run `make`, along with the normal katapult.bin file it will also generate a deployer.bin file. This deployer.bin is a fancy little tool that uses the existing bootloader (Katapult, or stock, or whatever) to "update" itself into the Katapult you just compiled.

So to update your Katapult, you just need to flash this deployer.bin file via your existing Katapult (in a very similar way you would flash klipper via Katapult).

**Step 2**

If you already have a functioning CAN setup, and your [mcu] canbus_uuid is in your printer.cfg, then you can force Katapult to reboot into Katapult mode by running:

```bash
python3 ~/katapult/scripts/flashtool.py -i can0 -u yourmainboarduuid -r
```

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/eda51419-6ab4-49c5-9c33-a581b08d085c)

If will probably say "Flash success" **THIS IS NOT ACTUALLY FLASHING ANYTHING, YOU NEED TO CONTINUE WITH THE STEPS BELOW**

**Step 3**

If you don't have the UUID (or something has gone wrong with the klipper firmware and your mainboard is hung) then you can also double-press the RESET button on your mainboard to force Katapult to reboot into Katapult mode.

You can verify it is in the proper mode by running `ls /dev/serial/by-id`. If you see a "usb-katapult-......" device then it is good to go.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/1e9f0f7c-ada3-490b-bd62-bde25b67c362)

**Step4**

Once you are at this stage you can flash the deployer.bin by running:

```bash
python3 ~/katapult/scripts/flashtool.py -f ~/katapult/out/deployer.bin -d /dev/serial/by-id/usb-katapult_your_mainboard_usb_id
```

and your Katapult should update.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/aa644018-861e-473c-83f9-4f2a423aa44b)

