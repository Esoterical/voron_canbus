# General Info

The following should be taken as an overall guide on what you are going to be achieving.

**PLEASE DO NOT TAKE THE SCREENSHOTS/CONFIGURATIONS ON THIS PAGE EXACTLY AS WRTTEN AS THEY MAY NOT BE COMPATIBLE WITH YOUR PARTICULAR MAINBOARD**

Before doing anything it is good to have some dependencies installed. Do this by running these on your Pi:

```
sudo apt update
sudo apt upgrade
sudo apt install python3 python3-pip python3-can
pip3 install pyserial
```

**It looks like the pip3 command may not be needed on latest versions of raspiOS (Bookworm). If you get "error: externally-managed-environment" then just move on and it'll probably be fine**

As mentioned in the main guide, you can either use Katapult on your mainboard to facilitate flashing over CAN, or you can go without and have the board boot straight into klipper.

# Installing Katapult

(The following is a lot of copy-paste from MastahFR's excellent ["Octopus and SB2040" install guide](https://github.com/akhamar/voron_canbus_octopus_sb2040). Give all kudus to them)

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


You will need to adapt the below instructions so they cover _your_ board's specicific configuration. You can find screenshots of settings for comomon toolheads in the [commmon_hardware](./common_hardware) folder.

If your board doesn't exist in the common_hardware folder already, then you want the Processor, Clock Reference, and Application Start offset to be set as per whatever board you are running. Set the "Build Katapult deployment application" (this is really only for updating but doesn't hurt having it enabled at this stage), and make sure "Communication Interface" is set to USB. Also make sure the "Support bootloader entry on rapid double click of reset button" is marked. It makes it so a double press of the reset button will force the board into Katapult mode. Makes re-flashing after a mistake a lot easier. Also, setting the Stus LED GPIO Pin won't affect how katapult functions, but it will give a nice visual indicator (of an LED flashing on and off once a second) on the toolhead to show the board is sitting in Katapult mode.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/5434691f-2d97-4d75-9067-d7501c2a2214)

Press Q to quit the menu (it will ask to save, choose yes).

Compile the firmware with `make`. You will now have a katapult.bin at in your ~/katapult/out/katapult.bin.

To flash, connect your mainboard to the Pi via USB then put the mainboard into DFU mode (your mainboard user manual should have instructions on doing this).
To confirm it's in DFU mode you can run the command `sudo dfu-util -l` and it will show any devices connected to your Pi in DFU mode.

![image](https://user-images.githubusercontent.com/124253477/221337550-560128dd-b5fd-41ba-8881-48d24b2215ef.png)

> Note the address of _Internal Flash_ => 0x08000000
>
> Note the address of the usb device => 0483:df11

You can then flash the Katapult firmware to your mainboard by running

```
cd ~/katapult
make
sudo dfu-util -R -a 0 -s 0x08000000:force:mass-erase:leave -D ~/katapult/out/katapult.bin -d 0483:df11
```

where the --dfuse-address is the _Internal Flash_ and the -d is the USB Device ID is the that you grabbed from the `sudo dfu-util -l` command.

If the result shows an "Error during download get_status" or something, but above it it still has "File downloaded successfullY" then it still flashed OK and you can ignore that error.

![image](https://user-images.githubusercontent.com/124253477/225469341-46f3478a-aa96-4378-8d73-96faa90d561c.png)

Katapult should now be successfully flashed. Take your mainboard out of DFU mode (it might require removing jumpers and rebooting, or just rebooting).

As you are installing Katapult onto the mainboard that you are also going to use for USB-CAN-Bridge mode klipper, you still will _not_ have a working CAN network at this stage. You can flash klipper to your mainboard via Katapult, but in reality it is flashing over USB and not flashing over CAN.

Flashing klipper via Katapult will be covered shortly.

# Installing USB-CAN-Bridge Klipper

Move into the klipper directory on the Pi by running:
`cd ~/klipper`
Then go into the klipper configuration menu by running:
`make menuconfig`

Again, if your mainboard is already in [commmon_hardware](./common_hardware) then you can copy the Klipper settings from there. 

Otherwise, you want the Processor and Clock Reference to be set as per whatever board you are running. Set Communication interface to 'USB to CAN bus bridge' then set the CAN Bus interface to use the pins that are specific to your mainboard. Also set the CAN bus speed to the same as the speed in your can0 file. In this guide it is set to 1000000.

Once you have the firmware configured, run a `make clean` to make sure there are no old files hanging around, then `make` to compile the firmware. It will save the firmware to ~/klipper/out/klipper.bin

## Using Katapult to flash Klipper

Run an `ls /dev/serial/by-id/` and take note of the Katapult device that it shows:

![image](https://user-images.githubusercontent.com/124253477/221342447-a98e6bee-050b-4f82-a4cb-1265e92d0752.png)

If the above command didn't show a 'katapult' device, or threw a "no such file or directory" error, then quickly double-click the RESET button on your mainboard and run the command again. Until you get a result from a `ls /dev/serial/by-id/` there is no point doing further steps below.

Run this command to install klipper firmware via Katapult via USB. Use the device ID you just retrieved in the above ls command.

`python3 ~/katapult/scripts/flashtool.py -f ~/klipper/out/klipper.bin -d /dev/serial/by-id/usb-katapult_stm32f446xx_37001A001851303439363932-if00`


## Klipper is now installed

This should have now installed klipper firmware to your mainboard. You can verify by running `lsusb` and you should see a "Geschwister Schneider CAN adapter" or similar device.

![image](https://user-images.githubusercontent.com/124253477/221329262-d8758abd-62cb-4bb6-9b4f-7bc0f615b5de.png)

You can also check by running an 'interface config' command `ifconfig`. If the USB-CAN-Bridge klipper is up and happy (and you have created the can0 file mentioned in the main page) then you will see a can0 interface:

![image](https://user-images.githubusercontent.com/124253477/221329326-efa1437e-839d-4a6b-9648-89412791b819.png)

You can now run the Klipper canbus query to retrieve the canbus_uuid of your mainboard:

`~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0`

![image](https://user-images.githubusercontent.com/124253477/221332914-c612d996-f9c3-444d-aa41-22b8eda96eba.png)

Use this UUID in the [mcu] section of your printer.cfg in order for Klipper (on Pi) to connect to the mainboard.

# Next Step

Now that your mainboard is fully flashed, and you have a working can0 CANBus network, the next step is to [flash your toolhead board](../toolhead_flashing).

