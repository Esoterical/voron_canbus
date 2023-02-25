
# General Info

The following should be taken as an overall guide on what you are going to be achieving. 

**PLEASE DO NOT TAKE THE SCREENSHOTS/CONFIGURATIONS ON THIS PAGE EXACTLY AS WRTTEN AS THEY MAY NOT BE COMPATIBLE WITH YOUR PARTICULAR MAINBOARD**

You will need to adapt the below instructions so they cover *your* board's specicific configuration. There are also some included configurations for specific popular boards in the https://github.com/Esoterical/voron_canbus/tree/main/toolhead_flashing/canboot and https://github.com/Esoterical/voron_canbus/tree/main/toolhead_flashing/non_canboot folders.


Before doing anything it is good to have some dependencies installed. Do this by running these on your Pi:
```
apt update
apt upgrade
apt install python3 python3-pip python3-can
pip3 install pyserial
```

As mentioned in the main guide, you can either use CanBOOT on your toolhead to facilitate flashing over CAN, or you can go without and have the board boot straight into klipper.

# Installing CanBOOT

(The following is a lot of copy-paste from MastahFR's excellent "Octopus and SB2040" install guide https://github.com/akhamar/voron_canbus_octopus_sb2040. Give all kudus to them)

First you need to clone the CanBOOT repo onto your pi. Run the following commands to clone the repo:
```
cd ~
git clone https://github.com/Arksine/CanBoot
```

This will clone the CanBoot repo into a new folder in your home directory called "CanBoot" (and yes, it's case sensitive on both the C and the B).

To configure the CanBoot firmware, run these commands to change into the CanBoot directory and then modify the firmware menu:
```
cd ~/CanBoot
make menuconfig
```
You want the Processor, Clock Reference, and Application Start offset to be set as per whatever board you are running. Keep the "Build CanBoot Deployment Application" to (do not build), and make sure "Communication Interface" is set to USB. Also make sure the "Support bootloader entry on rapid double click of reset button" is marked. It makes it so a double press of the reset button will force the board into CanBOOT mode. Makes re-flashing after a mistake a lot easier.

![image](https://user-images.githubusercontent.com/124253477/221333924-0a4d3c28-d084-4f8c-b93f-0670114bd090.png)

Compile the firmware with `make`. You will now have a canboot.bin (or canboot.uf2) in your ~/CanBoot/out/ directory.

To flash, connect your toolhead board to the Pi via USB then put the toolhead board into DFU/BOOT mode (your toolhead board user manual should have instructions on doing this).

**STM32 based board:**
To confirm it's in DFU mode you can run the command `dfu-util -l` and it will show any devices connected to your Pi in DFU mode.

![image](https://user-images.githubusercontent.com/124253477/221337550-560128dd-b5fd-41ba-8881-48d24b2215ef.png)

> Note the address of *Internal Flash* => 0x08000000
>
> Note the address of the usb device => 0483:df11

You can then flash the CanBOOT firmware to your toolhead board by running
```
cd ~/CanBoot
make
dfu-util -a 0 -D ~/CanBoot/out/canboot.bin --dfuse-address 0x08000000:force:mass-erase:leave -d 0483:df11
```

where the --dfuse-address is the *Internal Flash* and the -d is the USB Device ID is the that you grabbed from the `dfu-util -l` command.

**RP2040 based boards:**
To confirm it's in BOOT mode, run an `lsusb` command and you should see the device as a "Raspberry Pi boot" device (or similar)

![image](https://user-images.githubusercontent.com/124253477/221344712-500b3c36-8e96-4f23-88ed-5e13ee79535f.png)

> Note the address of the usb device => 2e8a:0003

You can then flash the CanBOOT firmware to your toolhead board by running
```
cd ~/CanBoot
make flash FLASH_DEVICE=2e8a:0003
```

where the FLASH_DEVICE ID is what you noted down from the `lsusb` command.

# Hooray

CanBOOT should now be successfully flashed. Take your toolhead out of DFU mode (it might require removing jumpers and rebooting, or just rebooting).

Wire up your toolhead power (24v and gnd) and CAN (CANH/CANL) wires, then the following command to see if the toolhead board is on the CAN network and waiting in CanBOOT mode

`python3 ~/CanBoot/scripts/flash_can.py -i can0 -q`

You should see a "Detected UUID" with "Application: CanBoot"

![image](https://user-images.githubusercontent.com/124253477/221345166-bd920eef-8ce9-48ff-9f31-8ebe8da48225.png)

If you see the above, take note of the UUID and move on to flashing Klipper to the toolhead board.


# Installing Klipper

Move into the klipper directory on the Pi by running:
`cd ~/klipper`
Then go into the klipper configuration menu by running:
`make menuconfig`

You want the Processor and Clock Reference to be set as per whatever board you are running. Set Communication interface to 'CAN bus' with the pins that are specific to your toolhead board. Also set the CAN bus speed to the same as the speed in your can0 file. In this guide it is set to 1000000.

**NOTE: The Bootloader offset will be determined by if you are using a bootloader or not. If you are using CanBOOT then set the bootloader offset to the same you sset it when building the CanBOOT firmware. If you are going to run without a bootloader then set the bootloader offset to "No Bootloader"**

Once you have the firmware configured, run a `make clean` to make sure there are no old files hanging around, then `make` to compile the firmware. It will save the firmware to ~/klipper/out/klipper.bin


# If you have CanBOOT installed

Run a `python3 ~/CanBoot/scripts/flash_can.py -i can0 -q` and take note of the CanBoot device that it shows:

![image](https://user-images.githubusercontent.com/124253477/221345166-bd920eef-8ce9-48ff-9f31-8ebe8da48225.png)

Then run the following command to install klipper firmware via CanBOOT. Use the UUID you just retrieved in the above query.

`python3 ~/CanBoot/scripts/flash_can.py -i can0 -u b6d9de35f24f -f ~/klipper/out/klipper.bin`

where the "-u" ID is what you found from the "flash_can.py -i can0 -q" query.

One the flash has been completed you can run the `python3 ~/CanBoot/scripts/flash_can.py -i can0 -q` command again. This time you should see the same UUID but with "Application: Klipper" instead of "Application: CanBoot"

![image](https://user-images.githubusercontent.com/124253477/221346236-5633f522-97b6-43e7-a675-82f3e483e3a4.png)


# If you don't have CanBOOT installed

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

# Klipper is now installed

You can now run the Klipper canbus query to retrieve the canbus_uuid of your toolhead board:

`~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0`

![image](https://user-images.githubusercontent.com/124253477/221332914-c612d996-f9c3-444d-aa41-22b8eda96eba.png)

Use this UUID in the [mcu] section of your printer.cfg in order for Klipper (on Pi) to connect to the toolhead board.

















