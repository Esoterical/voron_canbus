---
layout: default 
title: CAN-Bridge Mainboard Updating
parent: Updating
nav_order: 10
---

# Updating your USB-CAN-Bridge Mainboard

## Updating Mainboard Katapult

This is only if you need to update katapult as well. If you are just doing a Klipper firmware update (because you updated Klipper on your Pi and now it is yelling at you or something) then skip to [here](#updating-mainboard-klipper)

You should never really have to update your Katapult on the mainboard. Even if you wish to change your CanBUS speeds you don't need to change Katapult **On the Mainboard** as it only communicates via USB and not via CAN.

However, if you need to update Katapult for whatever reason, then:

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

`python3 ~/katapult/scripts/flashtool.py -i can0 -u yourmainboarduuid -r`

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/eda51419-6ab4-49c5-9c33-a581b08d085c)

If will probably say "Flash success" **THIS IS NOT ACTUALLY FLASHING ANYTHING, YOU NEED TO CONTINUE WITH THE STEPS BELOW**

**Step 3**

If you don't have the UUID (or something has gone wrong with the klipper firmware and your mainboard is hung) then you can also double-press the RESET button on your mainboard to force Katapult to reboot into Katapult mode.

You can verify it is in the proper mode by running `ls /dev/serial/by-id`. If you see a "usb-katapult-......" device then it is good to go.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/1e9f0f7c-ada3-490b-bd62-bde25b67c362)

**Step4**

Once you are at this stage you can flash the deployer.bin by running:

`python3 ~/katapult/scripts/flashtool.py -f ~/katapult/out/deployer.bin -d /dev/serial/by-id/usb-katapult_your_mainboard_usb_id`

and your Katapult should update.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/aa644018-861e-473c-83f9-4f2a423aa44b)


## Updating Mainboard Klipper

**Step 1**

To update Klipper, you first need to compile a new klipper.bin with the correct settings.

Move into the klipper directory on the Pi by running:
`cd ~/klipper`
Then go into the klipper configuration menu by running:
`make menuconfig`

You can find screenshots of settings for common mainboards in the [Common Mainboard Hardware](./mainboard_flashing/common_hardware) section.

Otherwise, you want the Processor and Clock Reference to be set as per whatever board you are running. Set Communication interface to 'USB to CAN bus bridge' then set the CAN Bus interface to use the pins that are specific to your mainboard. Also set the CAN bus speed to the same as the speed in your can0 file. In this guide it is set to 1000000.

Once you have the firmware configured, hit Q to save and quit from the makemenu screen, then run a `make clean` to make sure there are no old files hanging around, then `make` to compile the firmware. It will save the firmware to ~/klipper/out/klipper.bin

**Step 2**

First, stop the Klipper service on the Pi by running:

```
sudo service klipper stop
````

If you already have a functioning CAN setup, and your [mcu] canbus_uuid is in your printer.cfg, then you can force Katapult to reboot into Katapult mode by running:

```
python3 ~/katapult/scripts/flashtool.py -i can0 -u yourmainboarduuid -r
```

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/eda51419-6ab4-49c5-9c33-a581b08d085c)

If will probably say "Flash success" **THIS IS NOT ACTUALLY FLASHING ANYTHING, YOU NEED TO CONTINUE WITH THE STEPS BELOW**

**Step 3**

If you don't have the UUID (or something has gone wrong with the klipper firmware and your mainboard is hung) then you can also double-press the RESET button on your mainboard to force Katapult to reboot into Katapult mode.

You can verify it is in the proper mode by running `ls /dev/serial/by-id`. If you see a "usb-katapult-......" device then it is good to go.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/1e9f0f7c-ada3-490b-bd62-bde25b67c362)

**Step4**

Then you can run the same command you used to initially flash Klipper:

```
python3 ~/katapult/scripts/flashtool.py -f ~/klipper/out/klipper.bin -d /dev/serial/by-id/usb-katapult_yourmainboardusbid
```

**If** an `lsusb` doesn't show up your mainboard as a CAN adapter (or if `ip a` doesn't show your can0 network), or if the can0 network shows fine but you can't connect to your tooolhead that was previously working (and that you haven't flashed anything new to yet) then there is a good chance your klipper.bin settings were incorrect. Go back to Step 1 and check *all* the settings in the `make menuconfig` screen then recompile with `make clean` and `make`, and hen double-click the reset button on your toolhead to kick it back to katapult mode then go from Step 3.

However, **if** the `lsusb` and `ip a` show the correct things then your mainboard is now updated, run `sudo service klipper start` to start the klipper service on your Pi again.

