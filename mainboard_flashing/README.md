
# General Info

The following should be taken as an overall guide on what you are going to be achieving. 

**PLEASE DO NOT TAKE THE SCREENSHOTS/CONFIGURATIONS ON THIS PAGE EXACTLY AS WRTTEN AS THEY MAY NOT BE COMPATIBLE WITH YOUR PARTICULAR MAINBOARD**

You will need to adapt the below instructions so they cover *your* board's specicific configuration. There are also some included configurations for specific popular boards in the https://github.com/Esoterical/voron_canbus/tree/main/toolhead_flashing/common_hardware folder.


Before doing anything it is good to have some dependencies installed. Do this by running these on your Pi:
```
sudo apt update
sudo apt upgrade
sudo apt install python3 python3-pip python3-can
pip3 install pyserial
```

As mentioned in the main guide, you can either use CanBOOT on your mainboard to facilitate flashing over CAN, or you can go without and have the board boot straight into klipper.

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

Compile the firmware with `make`. You will now have a canboot.bin at in your ~/CanBoot/out/canboot.bin.

To flash, connect your mainboard to the Pi via USB then put the mainboard into DFU mode (your mainboard user manual should have instructions on doing this).
To confirm it's in DFU mode you can run the command `dfu-util -l` and it will show any devices connected to your Pi in DFU mode.

![image](https://user-images.githubusercontent.com/124253477/221337550-560128dd-b5fd-41ba-8881-48d24b2215ef.png)

> Note the address of *Internal Flash* => 0x08000000
>
> Note the address of the usb device => 0483:df11

You can then flash the CanBOOT firmware to your mainboard by running
```
cd ~/CanBoot
make
dfu-util -R -a 0 -s 0x08000000:force:mass-erase:leave -D ~/CanBoot/out/canboot.bin -d 0483:df11
```

where the --dfuse-address is the *Internal Flash* and the -d is the USB Device ID is the that you grabbed from the `dfu-util -l` command.

If the result shows an "Error during download get_status" or something, but above it it still has "File downloaded successfullY" then it still flashed OK and you can ignore that error.

![image](https://user-images.githubusercontent.com/124253477/225469341-46f3478a-aa96-4378-8d73-96faa90d561c.png)


CanBOOT should now be successfully flashed. Take your mainboard out of DFU mode (it might require removing jumpers and rebooting, or just rebooting).

As you are installing CanBOOT onto the mainboard that you are also going to use for USB-CAN-Bridge mode klipper, you still will *not* have a working CAN network at this stage. You can flash klipper to your mainboard via CanBOOT, but in reality it is flashing over USB and not flashing over CAN.

Flashing klipper via CanBOOT will be covered shortly.



# Installing USB-CAN-Bridge Klipper

Move into the klipper directory on the Pi by running:
`cd ~/klipper`
Then go into the klipper configuration menu by running:
`make menuconfig`

You want the Processor and Clock Reference to be set as per whatever board you are running. Set Communication interface to 'USB to CAN bus bridge' then set the CAN Bus interface to use the pins that are specific to your mainboard. Also set the CAN bus speed to the same as the speed in your can0 file. In this guide it is set to 1000000.

**NOTE: The Bootloader offset will be determined by if you are using a bootloader or not. If you are keeping the stock bootloader, or have installed canboot, then set the bootloader offset to the recommendation in the manual. If you are going to run without a bootloader then set the bootloader offset to "No Bootloader"**

Once you have the firmware configured, run a `make clean` to make sure there are no old files hanging around, then `make` to compile the firmware. It will save the firmware to ~/klipper/out/klipper.bin


## If you have CanBOOT installed

Run an `ls /dev/serial/by-id/` and take note of the CanBoot device that it shows:

![image](https://user-images.githubusercontent.com/124253477/221342447-a98e6bee-050b-4f82-a4cb-1265e92d0752.png)

If the above command didn't show a 'canboot' device, or threw a "no such file or directory" error, then quickly double-click the RESET button on your mainboard and run the command again. Until you get a result from a `ls /dev/serial/by-id/` there is no point doing further steps below.

Run this command to install klipper firmware via canboot via USB. Use the device ID you just retrieved in the above ls command.

`python3 ~/CanBoot/scripts/flash_can.py -f ~/klipper/out/klipper.bin -d /dev/serial/by-id/usb-CanBoot_stm32f446xx_37001A001851303439363932-if00`


## If you are running a stock bootloader and flashing via SD card INSTEAD of CanBOOT

Simply follow the mainboard user manual to copy the ~/klipper/out/klipper.bin file to an SD card (renaming it if needed) and flash the mainboard as per user manual.

## If you are flashing via DFU mode (no CanBOOT or stock bootloader)

To flash, connect your mainboard to the Pi via USB then put the mainboard into DFU mode (your mainboard user manual should have instructions on doing this).
To confirm it's in DFU mode you can run the command `dfu-util -l` and it will show any devices connected to your Pi in DFU mode.

![image](https://user-images.githubusercontent.com/124253477/221337550-560128dd-b5fd-41ba-8881-48d24b2215ef.png)

> Note the address of the usb device => 0483:df11

Then simply run the following commands to change to the klipper directory then flash the mainboard.
```
cd ~/klipper
make flash FLASH_DEVICE=0483:df11
```

where the FLASH_DEVICE ID is the address of the USB device you noted down from the `dfu-util -l` command.

## Klipper is now installed

This should have now installed klipper firmware to your mainboard. You can verify by running `lsusb` and you should see a "Geschwister Schneider CAN adapter" or similar device.

![image](https://user-images.githubusercontent.com/124253477/221329262-d8758abd-62cb-4bb6-9b4f-7bc0f615b5de.png)

You can also check by running an 'interface config' command `ifconfig`. If the USB-CAN-Bridge klipper is up and happy (and you have created the can0 file mentioned in the main page) then you will see a can0 interface:

![image](https://user-images.githubusercontent.com/124253477/221329326-efa1437e-839d-4a6b-9648-89412791b819.png)

You can now run the Klipper canbus query to retrieve the canbus_uuid of your mainboard:

`~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0`

![image](https://user-images.githubusercontent.com/124253477/221332914-c612d996-f9c3-444d-aa41-22b8eda96eba.png)

Use this UUID in the [mcu] section of your printer.cfg in order for Klipper (on Pi) to connect to the mainboard.




# UPDATING

## Updating CanBOOT

You should never really have to update your CanBOOT on the mainboard. Even if you wish to change your CanBUS speeds you don't need to change CanBOOT **On the Mainboard** as it only communicates via USB and not via CAN.

However, if you need to update CanBOOT for whatever reason, then:  
Change to your CanBoot directory with `cd ~/CanBoot`  
then go into the CanBoot firmware config menu with `make menuconfig`  
This time **make sure "Build CanBoot deployment application" is configured** with the properly bootloader offset (same as the "Application start offset" that is relevant for your mainboard). Make sure all the rest of your settings are correct for your mainboard.

![image](https://user-images.githubusercontent.com/124253477/223301620-c1fd3d16-04e3-49ce-8d48-5498811f4c46.png)

This time when you run `make`, along with the normal canboot.bin file it will also generate a deployer.bin file. This deployer.bin is a fancy little tool that uses the existing bootloader (canboot, or stock, or whatever) to "update" itself into the canboot you just compiled.

So to update your canboot, you just need to flash this deployer.bin file via your existing canboot (in a very similar way you would flash klipper via canboot).

If you already have a functioning CAN setup, and your [mcu] canbus_uuid is in your printer.cfg, then you can force CanBOOT to reboot into canboot mode by running:

`python3 ~/CanBoot/scripts/flash_can.py -i can0 -u yourmainboarduuid -r`

![image](https://user-images.githubusercontent.com/124253477/223303347-385ec07c-5211-42d3-b985-4dc38c2864ec.png)

If you don't have the UUID (or something has gone wrong with the klipper firmware and your mainboard is hung) then you can also double-press the RESET button on your mainboard to force CanBOOT to reboot into canboot mode.

You can verify it is in the proper mode by running `ls /dev/serial/by-id`. If you see a "usb-CanBoot-......" device then it is good to go.

![image](https://user-images.githubusercontent.com/124253477/223303596-f7709d3c-d652-401c-959d-560381a39cff.png)

Once you are at this stage you can flash the deployer.bin by running:

`python3 ~/CanBoot/scripts/flash_can.py -f ~/CanBoot/out/deployer.bin -d /dev/serial/by-id/usb-CanBoot_stm32f446xx_37001A001851303439363932-if00`

and your CanBoot should update.

![image](https://user-images.githubusercontent.com/124253477/223303940-e7c19b00-04bb-47b3-9230-458e9f2de251.png)

## Updating Klipper Firmware via CanBOOT

To update Klipper, first compile the new Klipper firmware by running the same way you did in the "Installing USB-CAN-Bridge Klipper" section above, but with your new settings (if you are changing settings). Then you need to get CanBOOT back into canboot mode.

If you already have a functioning CAN setup, and your [mcu] canbus_uuid is in your printer.cfg, then you can force CanBOOT to reboot into canboot mode by running:

`python3 ~/CanBoot/scripts/flash_can.py -i can0 -u yourmainboarduuid -r`

![image](https://user-images.githubusercontent.com/124253477/223303347-385ec07c-5211-42d3-b985-4dc38c2864ec.png)

If you don't have the UUID (or something has gone wrong with the klipper firmware and your mainboard is hung) then you can also double-press the RESET button on your mainboard to force CanBOOT to reboot into canboot mode.

You can verify it is in the proper mode by running `ls /dev/serial/by-id`. If you see a "usb-CanBoot-......" device then it is good to go.

![image](https://user-images.githubusercontent.com/124253477/223303596-f7709d3c-d652-401c-959d-560381a39cff.png)

Then you can run the same command you used to initially flash Klipper:

`python3 ~/CanBoot/scripts/flash_can.py -f ~/klipper/out/klipper.bin -d /dev/serial/by-id/usb-CanBoot_stm32f446xx_37001A001851303439363932-if00`

## Updating Klipper Firmware via other methods

Updating klipper via SD card flash or straight DFU mode is the exact same as initially installing it as outlined in the main Installing section above.











