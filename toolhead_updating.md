---
layout: default 
title: Toolhead Updating
parent: Updating
nav_order: 10
---

# Updating your Toolhead

If you are planning on updating both Katapult and Klipper (ie. for changing CAN speeds) then it's recommended to update Katapult first. Otherwise you may get stuck in a situation where you need to connect your toolhead back up via USB and flash as if from scratch.

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

`python3 ~/katapult/scripts/flashtool.py -i can0 -u yourtoolheaduuid -r`

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/eda51419-6ab4-49c5-9c33-a581b08d085c)

If will probably say "Flash success" **THIS IS NOT ACTUALLY FLASHING ANYTHING, YOU NEED TO CONTINUE WITH THE STEPS BELOW**

**Step 3**

If you don't have the UUID (or something has gone wrong with the klipper firmware and your toolboard is hung) then you can also double-press the RESET button on your toolhead to force Katapult to reboot into Katapult mode.

You can verify it is in the proper mode by running `python3 ~/katapult/scripts/flashtool.py -q`. If you see a "Detected UUID: xxxxxxxxx, Application: Katapult" device then it is good to go.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/ff9dcbb3-0456-4d87-8091-41d5d6050c02)

**Step4**

Once you are at this stage you can flash the deployer.bin by running:

`python3 ~/katapult/scripts/flashtool.py -i can0 -u yourtoolheaduuid -f ~/katapult/out/deployer.bin`

and your Katapult should update.

## Updating Toolhead Klipper

**Step 1**

To update Klipper, you first need to compile a new klipper.bin with the correct settings.

Move into the klipper directory on the Pi by running:
`cd ~/klipper`
Then go into the klipper configuration menu by running:
`make menuconfig`

You can find screenshots of settings for common toolheads in the [Common Toolhead Hardware](./toolhead_flashing/common_hardware) section.

You want the Processor and Clock Reference to be set as per whatever board you are running. Set Communication interface to 'CAN bus' with the pins that are specific to your toolhead board. Also set the CAN bus speed to the same as the speed in your can0 file. In this guide it is set to 1000000.

Once you have the firmware configured, hit Q to save and quit from the makemenu screen, then run a `make clean` to make sure there are no old files hanging around, then `make` to compile the firmware. It will save the firmware to ~/klipper/out/klipper.bin

**Step 2**

First, stop the Klipper service on the Pi by running:

```
sudo service klipper stop
````

If you already have a functioning CAN setup, and your [mcu toolhead] canbus_uuid is in your printer.cfg, then you can force Katapult to reboot into Katapult mode by running:

```
python3 ~/katapult/scripts/flashtool.py -i can0 -u yourtoolheaduuid -r
```

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/eda51419-6ab4-49c5-9c33-a581b08d085c)

If will probably say "Flash success" **THIS IS NOT ACTUALLY FLASHING ANYTHING, YOU NEED TO CONTINUE WITH THE STEPS BELOW**

**Step 3**

If you don't have the UUID (or something has gone wrong with the klipper firmware and your toolboard is hung) then you can also double-press the RESET button on your toolhead to force Katapult to reboot into Katapult mode.

You can verify it is in the proper mode by running `python3 ~/katapult/scripts/flashtool.py -q`. If you see a "Detected UUID: xxxxxxxxx, Application: Katapult" device then it is good to go.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/ff9dcbb3-0456-4d87-8091-41d5d6050c02)

**Step4**

Then you can run the same command you used to initially flash Klipper:

```
python3 ~/katapult/scripts/flashtool.py -i can0 -u yourtooolheaduuid -f ~/klipper/out/klipper.bin
```

Once the flash has been completed you can run the `python3 ~/katapult/scripts/flashtool.py -i can0 -q` command again. This time you should see the same UUID but with "Application: Klipper" instead of "Application: Katapult"

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/1e01f858-71f3-45b4-a69f-1f704dce80d4)


**If** you can't connect to your tooolhead after these steps (assuming all the ouputs look similar in success to the screenshots) then there is a good chance your klipper.bin settings were incorrect. Go back to Step 1 and check *all* the settings in the `make menuconfig` screen then recompile with `make clean` and `make`, and then double-click the reset button on your toolhead to kick it back to katapult mode then go from Step 3.

However, **if** the CAN query *does* return your UUID with "Application: Klipper" then start the Klipper service on the Pi again with `sudo service klipper start` and then do a firmware_restart and confirm that Klipper starts without errors.
