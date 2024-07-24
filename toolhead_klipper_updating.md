---
layout: default 
title: Toolhead Updating
parent: Updating
nav_order: 10
---

# Updating Toolhead Klipper

**Step 1**

To update Klipper, you first need to compile a new klipper.bin with the correct settings.

Move into the klipper directory on the Pi by running:
```bash
cd ~/klipper
```
Then go into the klipper configuration menu by running:
```bash
make menuconfig
```

You can find screenshots of settings for common toolheads in the [Common Toolhead Hardware](./toolhead_flashing/common_hardware) section.

You want the Processor and Clock Reference to be set as per whatever board you are running. Set Communication interface to 'CAN bus' with the pins that are specific to your toolhead board. Also set the CAN bus speed to the same as the speed in your can0 file. In this guide it is set to 1000000.

Once you have the firmware configured, hit Q to save and quit from the makemenu screen, then run a `make clean` to make sure there are no old files hanging around, then `make` to compile the firmware. It will save the firmware to ~/klipper/out/klipper.bin

**Step 2**

First, stop the Klipper service on the Pi by running:

```bash
sudo service klipper stop
```

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

Then you can run the same command you used to initially flash Klipper:

```bash
python3 ~/katapult/scripts/flashtool.py -i can0 -u yourtooolheaduuid -f ~/klipper/out/klipper.bin
```

Once the flash has been completed you can run the `python3 ~/katapult/scripts/flashtool.py -i can0 -q` command again. This time you should see the same UUID but with "Application: Klipper" instead of "Application: Katapult"

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/1e01f858-71f3-45b4-a69f-1f704dce80d4)


**If** you can't connect to your tooolhead after these steps (assuming all the ouputs look similar in success to the screenshots) then there is a good chance your klipper.bin settings were incorrect. Go back to Step 1 and check *all* the settings in the `make menuconfig` screen then recompile with `make clean` and `make`, and then double-click the reset button on your toolhead to kick it back to katapult mode then go from Step 3.

However, **if** the CAN query *does* return your UUID with "Application: Klipper" then start the Klipper service on the Pi again with `sudo service klipper start` and then do a 

firmware_restart and confirm that Klipper starts without errors.

## Updating Toolhead Klipper on USB

There is an option to flash the USB boards in a manner similar to CAN devices: `flashtool.py -i can0 -u yourtoolheaduuid -r`

First, obtain the serial ID of the board receiving the update:
```bash
ls /dev/serial/by-id
```
It should return `usb-Klipper_rp2040_YourBoardId-if00`. Next, run Klipper's "make flash" as follows: (replace `YourBoardId` with the output of `ls /dev/serial/by-id`)
```bash
make flash FLASH_DEVICE=/dev/serial/by-id/usb-Klipper_rp2040_YourBoardId-if00
```
If all goes well, the output on the screen should be similar to this:
```
~/klipper $ make flash FLASH_DEVICE=/dev/serial/by-id/usb-Klipper_rp2040_YourBoardId-if00 KCONFIG_CONFIG=config.skrpico
  Flashing out/klipper.bin to /dev/serial/by-id/usb-Klipper_rp2040_YourBoardId-if00
Entering bootloader on /dev/serial/by-id/usb-Klipper_rp2040_YourBoardId-if00
Device reconnect on /sys/devices/platform/axi/1000120000.pcie/1f00300000.usb/xhci-hcd.1/usb3/3-2
/usr/bin/python3 lib/canboot/flash_can.py -d /dev/serial/by-path/platform-xhci-hcd.1-usb-0:2:1.0 -f out/klipper.bin

Attempting to connect to bootloader
CanBoot Connected
Protocol Version: 1.0.0
Block Size: 64 bytes
Application Start: 0x10004000
MCU type: rp2040
Flashing '/home/username/klipper/out/klipper.bin'...

[##################################################]

Write complete: 132 pages
Verifying (block count = 528)...

[##################################################]

Verification Complete: SHA = 605441E7D51932AE153FEA1E7716AADA6457043A
CAN Flash Success
```
If it doesn't work initially, try rebooting your board. The technical part: Klipper's `make flash` with FLASH_DEVICE=/dev/serial/by-id options invokes the Katapult on USB boards, similar to the `-r` option of flash_can.py used for CAN boards.
