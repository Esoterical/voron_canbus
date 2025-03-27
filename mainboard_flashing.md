---
layout: default 
title: Mainboard Flashing
has_children: true
nav_order: 41
has_toc: false
---

# General Info

The following should be taken as an overall guide on what you are going to be achieving.

**PLEASE DO NOT TAKE THE SCREENSHOTS/CONFIGURATIONS ON THIS PAGE EXACTLY AS WRTTEN AS THEY MAY NOT BE COMPATIBLE WITH YOUR PARTICULAR MAINBOARD**

Before doing anything it is good to have some dependencies installed. Do this by running these on your Pi:

```bash
sudo apt update
sudo apt upgrade
sudo apt install python3 python3-serial
```

{: .note }
> If you get an error along the lines of "unable to locate package python3-serial" then you may be on an older version of linux.
> 
> In that case, run:
> 
> `sudo apt install python3-pip`
> 
> then
> 
> `pip3 install pyserial`


# Installing Katapult

First you need to clone the Katapult repo onto your pi. Run the following commands to clone (or update) the repo:

```bash
test -e ~/katapult && (cd ~/katapult && git pull) || (cd ~ && git clone https://github.com/Arksine/katapult) ; cd ~
```

This will clone the Katapult repo into a new folder in your home directory called "katapult" if you don't already have it, or it will update your Katapult folder to the latest version if you did already have it.

To configure the Katapult firmware, run these commands to change into the katapult directory and then modify the firmware menu:

```bash
cd ~/katapult
make menuconfig
```


You will need to adapt the below instructions so they cover _your_ board's specicific configuration. You can find screenshots of settings for common toolheads in the [Common Mainboard Hardware](./mainboard_flashing/common_hardware) section.

If your board doesn't exist in the common_hardware folder already, then you want the Processor, Clock Reference, and Application Start offset to be set as per whatever board you are running. Set the "Build Katapult deployment application" (this is really only for updating but doesn't hurt having it enabled at this stage), and make sure "Communication Interface" is set to USB. Also make sure the "Support bootloader entry on rapid double click of reset button" is marked. It makes it so a double press of the reset button will force the board into Katapult mode. Makes re-flashing after a mistake a lot easier. Lastly, setting the Status LED GPIO Pin won't affect how katapult functions, but it will give a nice visual indicator (of an LED flashing on and off once a second) on the toolhead to show the board is sitting in Katapult mode.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/5434691f-2d97-4d75-9067-d7501c2a2214)

Press Q to quit the menu (it will ask to save, choose yes).

Compile the firmware with `make`. You will now have a katapult.bin at ~/katapult/out/katapult.bin.
```bash
make clean
make
```

To flash, connect your mainboard to the Pi via USB then put the mainboard into DFU/BOOT mode (your mainboard user manual should have instructions on doing this).

If your mainboard board uses an STM32 based MCU use [these flashing steps](#stm32-based-boards)

If your mainboard board uses an RP2040 MCU, use [these flashing steps](#rp2040-based-boards)

## STM32 based boards

To confirm it's in DFU mode you can run the command `lsusb` and look for an entry of "STMicroelectronics STM Device in DFU mode"
```bash
lsusb
```

![image](https://github.com/user-attachments/assets/cde7138d-588b-4381-82ad-699cde37e0a8)

You can then flash the Katapult firmware to your mainboard by running

```bash
cd ~/katapult
make
sudo dfu-util -R -a 0 -s 0x08000000:leave -D ~/katapult/out/katapult.bin -d 0483:df11
```

If the result shows an "Error during download get_status" or something, but above it it still has "File downloaded successfully" then it still flashed OK and you can ignore that error.

![image](https://user-images.githubusercontent.com/124253477/225469341-46f3478a-aa96-4378-8d73-96faa90d561c.png)

Katapult is now installed, [click here](#katapult-is-now-installed) for the next steps.

## RP2040 based boards

To confirm it's in BOOT mode, run an `lsusb` command and you should see the device as a "Raspberry Pi boot" device (or similar)
```bash
lsusb
```

![image](https://user-images.githubusercontent.com/124253477/221344712-500b3c36-8e96-4f23-88ed-5e13ee79535f.png)

> Note the address of the usb device => 2e8a:0003

You can then flash the Katapult firmware to your toolhead board by running

```bash
cd ~/katapult
make flash FLASH_DEVICE=2e8a:0003
```

where the FLASH_DEVICE ID is what you noted down from the `lsusb` command.

It should look something like this if the download was successfull

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/34c4ca36-d03d-4eb3-a426-8be7751602fc)

Katapult is now installed, [click here](#katapult-is-now-installed) for the next steps.

## Katapult is now installed

Katapult should now be successfully flashed. Take out any DFU jumpers on your mainboard (if it needed them) and double-click the reset button on your board. Check that the board is in Katapult mode by running 

```bash
ls /dev/serial/by-id
```

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/1e9f0f7c-ada3-490b-bd62-bde25b67c362)

You should see a "usb-katapult_..." device there. If you don't, then double-click the RESET button on your board and `ls /dev/serial/by-id` again.

{: .note }
> If you keep seeing the board, but it shows as "usb-Klipper_..." instead of "usb-katapult_..." even after double-clicking the reset button then you may have a dodgy reset button or aren't getting the double-click
> timing correct. Either way, another method to kick the board into Katapult mode (assuming the Katapult install from further above was successful) is to run:
> 
> ```bash
> cd ~/klipper/scripts
> ```
> 
> then
> 
> ```bash
> ~/klippy-env/bin/python -c 'import flash_usb as u; u.enter_bootloader("<serialID>")'
> ```
> 
> replacing `<serialID>` with the usb_Klipper full path name that your board is showing up as.
> eg: 
> `~/klippy-env/bin/python -c 'import flash_usb as u; u.enter_bootloader("/dev/serial/by-id/usb-Klipper_stm32h723xx_110032000D51323532393433-if00")'`


{: .stop }
>
><p align="center">
>  <img src="https://github.com/Esoterical/voron_canbus/assets/124253477/36065239-009c-4195-8e13-a43959acac7b" />
></p>
>
>If you do *not* see a Katapult device listed in your /dev/serial/by-id, or if you get a `cannot access '/dev/serial/by-id': No such file or directory` then your mainboard *isn't* currently sitting in Katapult mode. Double-click the reset button on your mainboard then `ls /dev/serial/by-id` again. If you still don't see a Katapult device then either the flash didn't work or you had incorrect settings in the Katapult `make menuconfig` screen. Go [back](#installing-katapult) and try again.




As you are installing Katapult onto the mainboard that you are also going to use for USB-CAN-Bridge mode klipper, you still will _not_ have a working CAN network at this stage. You can flash klipper to your mainboard via Katapult, but in reality it is flashing over USB and not flashing over CAN.

Flashing klipper via Katapult will be covered shortly.

# Installing USB-CAN-Bridge Klipper

Move into the klipper directory on the Pi by running:

```bash
cd ~/klipper
```

Then go into the klipper configuration menu by running:

```bash
make menuconfig
```

Again, if your mainboard is already in [Common Mainboard Hardware](./mainboard_flashing/common_hardware) then you can copy the Klipper settings from there. 

Otherwise, you want the Processor and Clock Reference to be set as per whatever board you are running. Set Communication interface to 'USB to CAN bus bridge' then set the CAN Bus interface to use the pins that are specific to your mainboard. Also set the CAN bus speed to the same as the speed in your can0 file. In this guide it is set to 1000000.

Once you have the firmware configured, run a `make clean` to make sure there are no old files hanging around, then `make` to compile the firmware. It will save the firmware to ~/klipper/out/klipper.bin
```bash
make clean
make
```

## Using Katapult to flash Klipper

Stop the Klipper service on the Pi by running:

```bash
sudo service klipper stop
```

Run an `ls /dev/serial/by-id/` and take note of the Katapult device that it shows:
```bash
ls /dev/serial/by-id/
```

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/f836fa8d-fb26-4ccd-b1e1-50f010596852)

If the above command didn't show a 'katapult' device, or threw a "no such file or directory" error, then quickly double-click the RESET button on your mainboard and run the command again. Until you get a result from a `ls /dev/serial/by-id/` there is no point doing further steps below.

Run this command to install klipper firmware via Katapult via USB. Use the device ID you just retrieved in the above ls command.

```bash
python3 ~/katapult/scripts/flashtool.py -f ~/klipper/out/klipper.bin -d /dev/serial/by-id/usb-katapult_your_board_id
```


## Klipper is now installed

This should have now installed klipper firmware to your mainboard. You can verify by running `lsusb` and you should see a "Geschwister Schneider CAN adapter" or similar device.

![image](https://user-images.githubusercontent.com/124253477/221329262-d8758abd-62cb-4bb6-9b4f-7bc0f615b5de.png)

Check that the can0 interface is up by running `ip -s -d link show can0` . If everything is correct you will see something like this:
```bash
ip -s -d link show can0
```

![image](https://github.com/user-attachments/assets/c211da71-a0e3-4c47-b4a2-fdef3b717999)

You see a can0 interface, the "qlen" will be 128, and the bitrate will be 1000000


{: .stop }
>
><p align="center">
>  <img src="https://github.com/Esoterical/voron_canbus/assets/124253477/36065239-009c-4195-8e13-a43959acac7b" />
></p>
>
>If the `ip -s -d link show can0` command returns an error (eg. "Device can0 does not exist) then reboot your Pi with `sudo reboot now` and once the Pi is back up check `ip -s -d link show can0` again. If you still get the error then your mainboard isn't showing as a CAN adapter and you need to go back to the [Installing USB-CAN-Bridge Klipper](#installing-usb-can-bridge-klipper) and try again, making sure the Klipper `make menuconfig` settings are absolutely correct.
>
>If the can0 network shows up, but the qlen *isn't* 128 or the bitrate *isn't* 1000000 then go back to [Getting_Started](./Getting_Started.md) and check the can0 file settigns in both the ifupdown section and the netplan section.


You can now run the Klipper canbus query to retrieve the canbus_uuid of your mainboard:

```bash
~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0
```

![image](https://user-images.githubusercontent.com/124253477/221332914-c612d996-f9c3-444d-aa41-22b8eda96eba.png)

Use this UUID in the [mcu] section of your printer.cfg in order for Klipper (on Pi) to connect to the mainboard.

Start the Klipper service on the Pi again by running:

```bash
sudo service klipper start
```

{: .highlight } 
> ## Dissappearing Mainboard UUID
> There is a quirk with USB-CAN-Bridge klipper if you don't have any second/other CAN nodes connected up (either due to not having done that step yet, or if there is
> something wrong with the toolhead/other CAN device or wiring) where the Mainboard UUID will stop showing up to a query and can cause your web interface/klipper logs
> to show connection errors to 'mcu'.
>
>![image](https://github.com/user-attachments/assets/cf5be037-c1ae-445a-81b4-f667d6105455)
>
> If you are still at this early stage of your flashing journey where you haven't yet set up/connected the toolhead, all it means is if you keep doing a CAN
> query the mainboard UUID will stop showing. Don't be alarmed, it's normal. Once you have the second CAN device connect you won't see this behaviour, and it won't
> stop the mainboard from still acting as a USB-CAN-Bridge for your Pi.
>
> However, if you already *had* a working CAN toolhead setup and you see this problem, then the dissappearing UUID is **not** the cause of any errors/issues with
> your system. It can be a *symptom* of a problem, **not** the cause. Don't get lost trying to troubleshoot why the mainboard UUID dissappears. It's fine. Just hit
> the reset button on your mainboard (once), or power cycle the printer, and the mainboard UUID will return for at least a bit.


# Next Step

Now that your mainboard is fully flashed, and you have a working can0 CANBus network, the next step is to [flash your toolhead board](../toolhead_flashing).

