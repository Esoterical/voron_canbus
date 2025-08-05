---
layout: default 
title: No can0 Interface
nav_order: 10
parent: Troubleshooting
---

## No CAN network when running a query or flash attempt

If you run a `python3 ~/katapult/scripts/flashtool.py -i can0 -q` or `~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0` or are trying to flash a device with a command like `python3 ~/katapult/scripts/flashtool.py -i can0 -u b6d9de35f24f -f ~/klipper/out/klipper.bin` but you are seeing an error along the lines of "unable to bind socket to can0" or "failed to transmit, network is down" then your can0 "interface" on your Pi isn't running.

![image](https://user-images.githubusercontent.com/124253477/235117239-009ab013-d9ba-4524-81d4-a73c8990c2a7.png)

First thing to check is your `/etc/systemd/network/25-can.network` file. Make sure it exists and you have no typos in it.

### Seperate USB-CAN adapter (U2C/UTOC/etc.)

If you are using a separate USB to CAN adapter (U2C/UTOC/etc.) then double check that the USB cable connecting the devices is plugged in and not loose. If you _never_ get a response to a query (ie. the can0 interface has never shown at all) then you may have a dodgy USB cable. I have personally seen a handful of usb-c cables that don't actually have the data pins hooked up (they are power only). If the adapter doesn't show to an `lsusb` then your cable is probably dodgy.

If it shows up to an `lsusb` but an `ip link show can0` shows "Device can0 does not exist" then you might have a bad firmware, something wrong on your device, or problems with your CAN adapter drivers.

When you suspect problems with the device itself, reflash it with the appropriate firmware either from a manufacturer github repository or other source (like candlelight). If there are instructions back on the voron_canbus/can_adapter folder then follow those.

When you suspect problems with the drivers, it is worth checking whether appropriate driver module is installed and enabled in the OS. You can try looking for CAN-related modules: `lsmod | grep can`. For example, "Geschwister Schneider CAN adapter" based devices require `gs_usb` driver. If the identified required driver is missing, you may need to use a different OS image, recompile the image (eg. when using Armbian and the maintainers decided to disable appropriate module for your board), or compile the module stand-alone and then install it.

### USB-CAN-Bridge mode mainboard

Check that the Pi-to-mainboard USB cable hasn't come loose or anything, and that the mainboard is actually powered up. An `lsusb` should show the mainboard up as a can adapter device. If it's not showing as a can adapter device then do an `ls /dev/serial/by-id`. If you see your mainboard there then either it's still in Katapult mode, or you haven't flashed usb-can-bridge klipper to it (or the flash didn't take). If that is the case then reflash your mainboard as per the voron_canbus/mainboard_flashing instructions and take extra care that the klipper `make menuconfig` settings are 100% correct for your board.

[Return to Troubleshooting](../troubleshooting.md)


