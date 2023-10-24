# General Info

The following should be taken as an overall guide on what you are going to be achieving.

**PLEASE DO NOT TAKE THE SCREENSHOTS/CONFIGURATIONS ON THIS PAGE EXACTLY AS WRTTEN AS THEY MAY NOT BE COMPATIBLE WITH YOUR PARTICULAR MAINBOARD**

You will need to adapt the below instructions so they cover _your_ board's specicific configuration. There are also some included configurations for specific popular boards in the https://github.com/Esoterical/voron_canbus/tree/main/toolhead_flashing/common_hardware folder.

Before doing anything it is good to have some dependencies installed. Do this by running these on your Pi:

```
sudo apt update
sudo apt upgrade
sudo apt install python3 python3-pip python3-can
pip3 install pyserial
```
**It looks like the pip3 command may not be needed on latest versions of raspiOS (Bookworm). If you get "error: externally-managed-environment" then just move on and it'll probably be fine**

As mentioned in the main guide, you can either use Katapult on your toolhead to facilitate flashing over CAN, or you can go without and have the board boot straight into klipper.

# Installing Katapult

(The following is a lot of copy-paste from MastahFR's excellent "Octopus and SB2040" install guide https://github.com/akhamar/voron_canbus_octopus_sb2040. Give all kudus to them)

First you need to clone the Katapult repo onto your pi. Run the following commands to clone the repo:

```
cd ~
git clone https://github.com/Arksine/katapult
```

This will clone the Katapult repo into a new folder in your home directory called "katapult".

To configure the Katapult firmware, run these commands to change into the katapult directory and then modify the firmware menu:

```
cd ~/katapult
make menuconfig
```

You want the Processor, Clock Reference, and Application Start offset to be set as per whatever board you are running. Make sure "Communication Interface" is set to "CAN bus" with the appropriate pins for your board. Also make sure the "Support bootloader entry on rapid double click of reset button" is marked. It makes it so a double press of the reset button will force the board into Katapult mode. Makes re-flashing after a mistake a lot easier.

![image](https://user-images.githubusercontent.com/124253477/221349624-69abcf3e-dfd8-48d0-b4f6-0ebd620f6b42.png)

Compile the firmware with `make`. You will now have a katapult.bin (or katapult.uf2) in your ~/katapult/out/ directory.

To flash, connect your toolhead board to the Pi via USB then put the toolhead board into DFU/BOOT mode (your toolhead board user manual should have instructions on doing this).

**STM32 based board:**

To confirm it's in DFU mode you can run the command `dfu-util -l` and it will show any devices connected to your Pi in DFU mode.

![image](https://user-images.githubusercontent.com/124253477/221337550-560128dd-b5fd-41ba-8881-48d24b2215ef.png)

> Note the address of _Internal Flash_ => 0x08000000
>
> Note the address of the usb device => 0483:df11

You can then flash the Katapult firmware to your toolhead board by running

```
dfu-util -R -a 0 -s 0x08000000:force:mass-erase:leave -D ~/katapult/out/katapult.bin -d 0483:df11
```

where the --dfuse-address is the _Internal Flash_ and the -d is the USB Device ID is the that you grabbed from the `dfu-util -l` command.

If the result shows an "Error during download get_status" or something, but above it it still has "File downloaded successfullY" then it still flashed OK and you can ignore that error.

![image](https://user-images.githubusercontent.com/124253477/225469341-46f3478a-aa96-4378-8d73-96faa90d561c.png)

**RP2040 based boards:**

To confirm it's in BOOT mode, run an `lsusb` command and you should see the device as a "Raspberry Pi boot" device (or similar)

![image](https://user-images.githubusercontent.com/124253477/221344712-500b3c36-8e96-4f23-88ed-5e13ee79535f.png)

> Note the address of the usb device => 2e8a:0003

You can then flash the Katapult firmware to your toolhead board by running

```
cd ~/katapult
make flash FLASH_DEVICE=2e8a:0003
```

where the FLASH_DEVICE ID is what you noted down from the `lsusb` command.

If the result shows an "Error during download get_status" or something, but above it it still has "File downloaded successfullY" then it still flashed OK and you can ignore that error.

![image](https://user-images.githubusercontent.com/124253477/225469341-46f3478a-aa96-4378-8d73-96faa90d561c.png)

## Katapult is now installed

Katapult should now be successfully flashed. Take your toolhead out of DFU mode (it might require removing jumpers and rebooting, or just rebooting).

Wire up your toolhead power (24v and gnd) and CAN (CANH/CANL) wires, then the following command to see if the toolhead board is on the CAN network and waiting in Katapult mode

`python3 ~/katapult/scripts/flashtool.py -i can0 -q`

You should see a "Found UUID" with "Application: Katapult"

![image](https://github.com/Esoterical/voron_canbus/assets/2089/47589b13-1543-4eae-ba44-59c5761e4d75)

If you see the above, take note of the UUID and move on to flashing Klipper to the toolhead board.

# Installing Klipper

Move into the klipper directory on the Pi by running:
`cd ~/klipper`
Then go into the klipper configuration menu by running:
`make menuconfig`

You want the Processor and Clock Reference to be set as per whatever board you are running. Set Communication interface to 'CAN bus' with the pins that are specific to your toolhead board. Also set the CAN bus speed to the same as the speed in your can0 file. In this guide it is set to 1000000.

**NOTE: The Bootloader offset will be determined by if you are using a bootloader or not. If you are using Katapult then set the bootloader offset to the same you sset it when building the Katapult firmware. If you are going to run without a bootloader then set the bootloader offset to "No Bootloader"**

Once you have the firmware configured, run a `make clean` to make sure there are no old files hanging around, then `make` to compile the firmware. It will save the firmware to ~/klipper/out/klipper.bin

## If you have Katapult installed

Run a `python3 ~/katapult/scripts/flashtool.py -i can0 -q` and take note of the Katapult device that it shows:

![image](https://user-images.githubusercontent.com/124253477/221345166-bd920eef-8ce9-48ff-9f31-8ebe8da48225.png)

Then run the following command to install klipper firmware via Katapult. Use the UUID you just retrieved in the above query.

`python3 ~/katapult/scripts/flashtool.py -i can0 -u b6d9de35f24f -f ~/klipper/out/klipper.bin`

where the "-u" ID is what you found from the "flashtool.py -i can0 -q" query.

One the flash has been completed you can run the `python3 ~/katapult/scripts/flashtool.py -i can0 -q` command again. This time you should see the same UUID but with "Application: Klipper" instead of "Application: Katapult"

![image](https://user-images.githubusercontent.com/124253477/221346236-5633f522-97b6-43e7-a675-82f3e483e3a4.png)

## If you don't have Katapult installed

To flash, connect your toolhead board to the Pi via USB and put it into DFU/BOOT mode (your toolhead board user manual should have instructions on doing this).

**STM32 based board:**

To confirm it's in DFU mode you can run the command `dfu-util -l` and it will show any devices connected to your Pi in DFU mode.

![image](https://user-images.githubusercontent.com/124253477/221337550-560128dd-b5fd-41ba-8881-48d24b2215ef.png)

> Note the address of the usb device => 0483:df11

**RP2040 based boards:**

To confirm it's in BOOT mode, run an `lsusb` command and you should see the device as a "Raspberry Pi boot" device (or similar)

![image](https://user-images.githubusercontent.com/124253477/221344712-500b3c36-8e96-4f23-88ed-5e13ee79535f.png)

> Note the address of the usb device => 2e8a:0003

Then simply run the following commands to change to the klipper directory then flash the toolhead board.

```
cd ~/klipper
make flash FLASH_DEVICE=0483:df11
```

where the FLASH_DEVICE ID is the address of the USB device you noted down above.

## Klipper is now installed

You can now run the Klipper canbus query to retrieve the canbus_uuid of your toolhead board:

`~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0`

![image](https://user-images.githubusercontent.com/124253477/221332914-c612d996-f9c3-444d-aa41-22b8eda96eba.png)

Use this UUID in the [mcu] section of your printer.cfg in order for Klipper (on Pi) to connect to the toolhead board.

# UPDATING

If you are planning on updating both Katapult and Klipper (ie. for changing CAN speeds) then it's recommended to update Katapult first. Otherwise you may get stuck in a situation where you need to connect your toolhead back up via USB and flash as if from scratch.

## Updating Katapult

Change to your Katapult directory with `cd ~/katapult`
then go into the Katapult firmware config menu with `make menuconfig`
This time **make sure "Build Katapult deployment application" is configured** with the properly bootloader offset (same as the "Application start offset" that is relevant for your toolhead). Make sure all the rest of your settings are correct for your toolhead.

![image](https://user-images.githubusercontent.com/124253477/223301620-c1fd3d16-04e3-49ce-8d48-5498811f4c46.png)

This time when you run `make`, along with the normal katapult.bin file it will also generate a deployer.bin file. This deployer.bin is a fancy little tool that uses the existing bootloader (Katapult, or stock, or whatever) to "update" itself into the Katapult you just compiled.

So to update your Katapult, you just need to flash this deployer.bin file via your existing Katapult (in a very similar way you would flash klipper via Katapult).

If you already have a functioning CAN setup, and your [mcu toolhead] canbus_uuid is in your printer.cfg, then you can force Katapult to reboot into Katapult mode by running:

`python3 ~/katapult/scripts/flashtool.py -i can0 -u yourtoolheaduuid -r`

![image](https://user-images.githubusercontent.com/124253477/223307559-1da6a2dd-d572-456c-9ee6-0565e9192fea.png)

If you don't have the UUID (or something has gone wrong with the klipper firmware and your toolboard is hung) then you can also double-press the RESET button on your toolhead to force Katapult to reboot into Katapult mode.

You can verify it is in the proper mode by running `python3 ~/katapult/scripts/flashtool.py -q`. If you see a "Detected UUID: xxxxxxxxx, Application: Katapult" device then it is good to go.

![image](https://user-images.githubusercontent.com/124253477/223307593-b96dc642-9fa0-494b-93b8-a155d14bb535.png)

Once you are at this stage you can flash the deployer.bin by running:

`python3 ~/katapult/scripts/flashtool.py -i can0 -u b6d9de35f24f -f ~/katapult/out/deployer.bin`

and your Katapult should update.

## Updating Klipper Firmware via Katapult

To update Klipper, first compile the new Klipper firmware by running the same way you did in the "Installing Klipper" section above, but with your new settings (if you are changing settings). Then you need to get Katapult back into Katapult mode.

If you already have a functioning CAN setup, and your [mcu toolhead] canbus_uuid is in your printer.cfg, then you can force Katapult to reboot into Katapult mode by running:

`python3 ~/katapult/scripts/flashtool.py -i can0 -u yourtoolheaduuid -r`

![image](https://user-images.githubusercontent.com/124253477/223307559-1da6a2dd-d572-456c-9ee6-0565e9192fea.png)

If you don't have the UUID (or something has gone wrong with the klipper firmware and your toolboard is hung) then you can also double-press the RESET button on your toolhead to force Katapult to reboot into Katapult mode.

You can verify it is in the proper mode by running `python3 ~/katapult/scripts/flashtool.py -q`. If you see a "Detected UUID: xxxxxxxxx, Application: Katapult" device then it is good to go.

![image](https://user-images.githubusercontent.com/124253477/223307593-b96dc642-9fa0-494b-93b8-a155d14bb535.png)

Then you can run the same command you used to initially flash Klipper:

`python3 ~/katapult/scripts/flashtool.py -i can0 -u b6d9de35f24f -f ~/klipper/out/klipper.bin`

One the flash has been completed you can run the `python3 ~/katapult/scripts/flashtool.py -i can0 -q` command again. This time you should see the same UUID but with "Application: Klipper" instead of "Application: Katapult"

![image](https://user-images.githubusercontent.com/124253477/221346236-5633f522-97b6-43e7-a675-82f3e483e3a4.png)

## Updating Klipper Firmware via other methods

If you don't use Katapult, then updating klipper is the same process as a first-time flash as outlined in the above "If you don't have Katapult installed" section.
