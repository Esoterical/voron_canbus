---
layout: default  
title: CAN-Bridge Mainboard Updating
parent: Updating
nav_order: 20
---

# Updating Mainboard Klipper

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

```bash
sudo service klipper stop
````

If you already have a functioning CAN setup, and your [mcu] canbus_uuid is in your printer.cfg, then you can force Katapult to reboot into Katapult mode by running:

```bash
python3 ~/katapult/scripts/flashtool.py -i can0 -u yourmainboarduuid -r
```

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/eda51419-6ab4-49c5-9c33-a581b08d085c)

If will probably say "Flash success" **THIS IS NOT ACTUALLY FLASHING ANYTHING, YOU NEED TO CONTINUE WITH THE STEPS BELOW**

If you don't have the UUID (or something has gone wrong with the klipper firmware and your mainboard is hung) then you can also double-press the RESET button on your mainboard to force Katapult to reboot into Katapult mode.


**Step 3**

You can verify it is in the proper mode by running `ls /dev/serial/by-id/*`. If you see a "usb-katapult-......" device then it is good to go.

![image](https://github.com/user-attachments/assets/2ed240e4-1347-403f-be18-d55327049708)


**Step4**

Then you can run the same command you used to initially flash Klipper, using the out from the `ls /dev/serial/by-id/*` command you ran above:

```bash
python3 ~/katapult/scripts/flashtool.py -f ~/klipper/out/klipper.bin -d /dev/serial/by-id/usb-katapult_yourmainboardusbid
```

![image](https://github.com/user-attachments/assets/8fb111ae-2b52-4d75-b7bf-0e565c239ed2)


**If** an `lsusb` doesn't show up your mainboard as a CAN adapter (or if `ip a` doesn't show your can0 network), or if the can0 network shows fine but you can't connect to your tooolhead that was previously working (and that you haven't flashed anything new to yet) then there is a good chance your klipper.bin settings were incorrect. Go back to Step 1 and check *all* the settings in the `make menuconfig` screen then recompile with `make clean` and `make`, and hen double-click the reset button on your toolhead to kick it back to katapult mode then go from Step 3.

However, **if** the `lsusb` and `ip a` show the correct things then your mainboard is now updated, run `sudo service klipper start` to start the klipper service on your Pi again.

