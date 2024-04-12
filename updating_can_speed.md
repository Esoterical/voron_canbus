---
layout: default 
title: Updating your CANBUS speed
parent: Updating
nav_order: 30
---

# Updating your CANBUS Speed

If you are trying to modify the speed of your existing CAN network then there is an order of operations to make it as seamless as possible. If you don't use this order then you can get in to a state where you need to hook things up with USB cables and flash them as if it was the first time again.

**UNLESS YOU ARE CHANGING YOUR CANBUS SPEED YOU DON'T NEED TO USE THESE STEPS. FOR NORMAL UPDATING GO TO [TOOLHEAD UPDATING](./toolhead_updating.md) OR [MAINBOARD UPDATING](./mainboard_updating.md)**

I am going to use the scenario of changing from a speed of 500K to a speed of 1M. The steps are slightly different depending on if you are using a dedicated CAN adapter (U2C/UTOC/etc) or if you are using a USB-CAN-BRIDGE Mainboard. Make sure to choose the proper steps for your setup.

I'm also not going to go into each command to run, you can find the specific commmands in the main updating pages.

# If you are running a dedicated CAN adapter (U2C/UTOC/etc)

1. Put your toolhead into katapult mode
2. Compile new katapult firmware (`make menuconfig` and `make`) with the new speed and make sure the "Build Katapult deployment application" option is enabled
3. Flash the katapult deployer.bin to your toolhead

Once flashed we will no longer have access to your toolhead in Katapult mode. If your toolhead stays in katapult mode after flashing the deployer.bin just reboot the toolhead with the reset button (if it has one) or power cycle the printer.

4. Your toolhead should still boot into Klipper firmware fine at this stage(still with the old firmware)
5. Force the toolhead back into Katapult mode, either with a double-click of the reset button or with `python3 ~/katapult/scripts/flashtool.py -i can0 -u yourtoolheaduuid -r`
6. Temporarily change your CAN network speed by running `sudo ip link set can0 down type can` to drop the network and then `sudo ip link set can0 up type can bitrate 1000000` to bring it back up with your new desired speed.
7. Now with the CAN network temporarily at your new speed you should be able to see your toolhead again in katapult mode with a `python3 ~/katapult/scripts/flashtool.py -i can0 -q` If you can't see your toolhead with `application: katapult` then double-click the reset button on the toolhead until you can, or if your toolhead doesn't have that option you need to power cycle your whole printer then go back to step 5
8. If you can see your toolhead in katapult mode, you can `cd ~/klipper` and `make menuconfig` a new klipper firmware with your new speed, then Q to save and quit and `make` to compile, then flash this klipper.bin to your toolhead via katapult.
9. With both Katapult and Klipper flashed to your toolhead with your new speed, and your CAN interface still temporarily running at your new speed, you should be able to see your toolhead as normal in Klipper mode (either via a query or in your Mainsail/whatever GUI)
10. To permanently change your can0 network speed, go through the [Getting Started](./Getting_Started.md) instructions but using your new desired speed.


# If you are running a USB-CAN-BRIDGE Mainboard

1. Put your toolhead into katapult mode
2. Compile new katapult firmware (`make menuconfig` and `make`) with the new speed and make sure the "Build Katapult deployment application" option is enabled
3. Flash the katapult deployer.bin to your toolhead

Once flashed we will no longer have access to your toolhead in Katapult mode. If your toolhead stays in katapult mode after flashing the deployer.bin just reboot the toolhead with the reset button (if it has one) or power cycle the printer.

4. Your toolhead should still boot into Klipper firmware fine at this stage(still with the old firmware)
5. Force the toolhead back into Katapult mode, either with a double-click of the reset button or with `python3 ~/katapult/scripts/flashtool.py -i can0 -u yourtoolheaduuid -r`

We are now going to update your usb-can-bridge mainboard. Note that you **do not** need to reflash the katapult on your mainboard as this Katapult talks to the Pi over USB and so doesn't care what the CANBUS speed is set to.

6. Put your Mainboard into katapult mode `python3 ~/katapult/scripts/flashtool.py -i can0 -u yourmainboarduuid -r` and confirm you can see it in katapult mode with `ls /dev/serial/by-id`
7. `cd ~/klipper` and `make menuconfig` and put the settings for your mainboard usb-can-bridge mode with the new speed selected. Q to save and quit, then `make` to compile
8. Flash the new klipper.bin to your mainboard with `python3 ~/katapult/scripts/flashtool.py -f ~/klipper/out/klipper.bin -d /dev/serial/by-id/usb-katapult_your_mainboard_usb_id`
9. Temporarily change your CAN network speed by running `sudo ip link set can0 down type can` to drop the network and then `sudo ip link set can0 up type can bitrate 1000000` to bring it back up with your new desired speed.
10. Run `python3 ~/katapult/scripts/flashtool.py -i can0 -q` and you should see your toolhead in katapult mode as your CAN network is now running on the new speed.
11. If you can see your toolhead in katapult mode, you can `cd ~/klipper` and `make menuconfig` a new klipper firmware with your new speed, then Q to save and quit and `make` to compile, then flash this klipper.bin to your toolhead via katapult.
12. To permanently change your can0 network speed, go through the [Getting Started](./Getting_Started.md) instructions but using your new desired speed.


