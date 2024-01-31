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

As mentioned in the main guide, you can either use Katapult on your toolhead to facilitate flashing over CAN, or you can go without and have the board boot straight into klipper.

# Installing Katapult

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

You will need to adapt the below instructions so they cover _your_ board's specicific configuration. You can find screenshots of settings for common toolheads in the [commmon_hardware](./common_hardware) folder.

If your board doesn't exist in the common_hardware folder already, then you want the Processor, Clock Reference, and Application Start offset to be set as per whatever board you are running. You can leave the  "Build Katapult deployment application" set or not set (it makes not difference at this flashing stage, it's only for updating), and make sure "Communication Interface" is set to "CAN Bus" with the correct pins for your toolhead board. Also make sure the "Support bootloader entry on rapid double click of reset button" is marked. It makes it so a double press of the reset button will force the board into Katapult mode. Makes re-flashing after a mistake a lot easier. Lastly, setting the Status LED GPIO Pin won't affect how katapult functions, but it will give a nice visual indicator (of an LED flashing on and off once a second) on the toolhead to show the board is sitting in Katapult mode.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/4f56422c-c451-4036-afc1-c67475ecd380)



Compile the firmware with `make`. You will now have a katapult.bin (or katapult.uf2) in your ~/katapult/out/ directory.

To flash, connect your toolhead board to the Pi via USB then put the toolhead board into DFU/BOOT mode (your toolhead board user manual should have instructions on doing this).

If your toolhead board uses an STM32 based MCU use [these flashing steps](#stm32-based-boards)

If your toolhead board uses an RP2040 MCU, use [these flashing steps](#rp2040-based-boards)

## STM32 based boards

To confirm it's in DFU mode you can run the command `sudo dfu-util -l` and it will show any devices connected to your Pi in DFU mode.

![image](https://user-images.githubusercontent.com/124253477/221337550-560128dd-b5fd-41ba-8881-48d24b2215ef.png)

> Note the address of _Internal Flash_ => 0x08000000
>
> Note the address of the usb device => 0483:df11

You can then flash the Katapult firmware to your toolhead board by running

```
sudo dfu-util -R -a 0 -s 0x08000000:force:mass-erase:leave -D ~/katapult/out/katapult.bin -d 0483:df11
```

where the --dfuse-address is the _Internal Flash_ and the -d is the USB Device ID is the that you grabbed from the `sudo dfu-util -l` command.

If the result shows an "Error during download get_status" or something, but above it it still has "File downloaded successfullY" then it still flashed OK and you can ignore that error.

![image](https://user-images.githubusercontent.com/124253477/225469341-46f3478a-aa96-4378-8d73-96faa90d561c.png)

[Katapult is now installed, click here](##Katapult-is-now-installed)


## RP2040 based boards

To confirm it's in BOOT mode, run an `lsusb` command and you should see the device as a "Raspberry Pi boot" device (or similar)

![image](https://user-images.githubusercontent.com/124253477/221344712-500b3c36-8e96-4f23-88ed-5e13ee79535f.png)

> Note the address of the usb device => 2e8a:0003

You can then flash the Katapult firmware to your toolhead board by running

```
cd ~/katapult
make flash FLASH_DEVICE=2e8a:0003
```

where the FLASH_DEVICE ID is what you noted down from the `lsusb` command.

It should look something like this if the download was successfull

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/34c4ca36-d03d-4eb3-a426-8be7751602fc)

[Katapult is now installed, click here](##Katapult-is-now-installed)

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

Again, if your mainboard is already in [commmon_hardware](./common_hardware) then you can copy the Klipper settings from there. 


Otherwise, you want the Processor and Clock Reference to be set as per whatever board you are running. Set Communication interface to"CAN Bus" with the correct pins for your toolhead board. Also set the CAN bus speed to the same as the speed in your can0 file. In this guide it is set to 1000000.


Once you have the firmware configured, run a `make clean` to make sure there are no old files hanging around, then `make` to compile the firmware. It will save the firmware to ~/klipper/out/klipper.bin

## Using Katapult to flash Klipper

Run a `python3 ~/katapult/scripts/flashtool.py -i can0 -q` and take note of the Katapult device that it shows:

![image](https://user-images.githubusercontent.com/124253477/221345166-bd920eef-8ce9-48ff-9f31-8ebe8da48225.png)

Then run the following command to install klipper firmware via Katapult. Use the UUID you just retrieved in the above query.

`python3 ~/katapult/scripts/flashtool.py -i can0 -u b6d9de35f24f -f ~/klipper/out/klipper.bin`

where the "-u" ID is what you found from the "flashtool.py -i can0 -q" query.

One the flash has been completed you can run the `python3 ~/katapult/scripts/flashtool.py -i can0 -q` command again. This time you should see the same UUID but with "Application: Klipper" instead of "Application: Katapult"

![image](https://user-images.githubusercontent.com/124253477/221346236-5633f522-97b6-43e7-a675-82f3e483e3a4.png)


# Klipper is now installed

You can now run the Klipper canbus query to retrieve the canbus_uuid of your toolhead board:

`~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0`

![image](https://user-images.githubusercontent.com/124253477/221332914-c612d996-f9c3-444d-aa41-22b8eda96eba.png)

Use this UUID in the [mcu] section of your printer.cfg in order for Klipper (on Pi) to connect to the toolhead board.

# Next Step

Congratulations! Everything is now flashed. Time to move on to the [final steps](../Final_Steps.md).


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

**Step 1**

To update Klipper, you first need to compile a new klipper.bin with the correct settings.

Move into the klipper directory on the Pi by running:
`cd ~/klipper`
Then go into the klipper configuration menu by running:
`make menuconfig`

You can find screenshots of settings for comomon toolheads in the [commmon_hardware](./common_hardware) folder.

You want the Processor and Clock Reference to be set as per whatever board you are running. Set Communication interface to 'CAN bus' with the pins that are specific to your toolhead board. Also set the CAN bus speed to the same as the speed in your can0 file. In this guide it is set to 1000000.

Once you have the firmware configured, hit Q to save and quit from the makemenu screen, then run a `make clean` to make sure there are no old files hanging around, then `make` to compile the firmware. It will save the firmware to ~/klipper/out/klipper.bin

**Step 2**

If you already have a functioning CAN setup, and your [mcu toolhead] canbus_uuid is in your printer.cfg, then you can force Katapult to reboot into Katapult mode by running:

`python3 ~/katapult/scripts/flashtool.py -i can0 -u yourtoolheaduuid -r`

![image](https://user-images.githubusercontent.com/124253477/223307559-1da6a2dd-d572-456c-9ee6-0565e9192fea.png)

If will probably say "Flash success" **THIS IS NOT ACTUALLY FLASHING ANYTHING, YOU NEED TO CONTINUE WITH THE STEPS BELOW**

**Step 3**

If you don't have the UUID (or something has gone wrong with the klipper firmware and your toolboard is hung) then you can also double-press the RESET button on your toolhead to force Katapult to reboot into Katapult mode.

You can verify it is in the proper mode by running `python3 ~/katapult/scripts/flashtool.py -q`. If you see a "Detected UUID: xxxxxxxxx, Application: Katapult" device then it is good to go.

![image](https://user-images.githubusercontent.com/124253477/223307593-b96dc642-9fa0-494b-93b8-a155d14bb535.png)

**Step4**

Then you can run the same command you used to initially flash Klipper:

`python3 ~/katapult/scripts/flashtool.py -i can0 -u b6d9de35f24f -f ~/klipper/out/klipper.bin`

One the flash has been completed you can run the `python3 ~/katapult/scripts/flashtool.py -i can0 -q` command again. This time you should see the same UUID but with "Application: Klipper" instead of "Application: Katapult"

![image](https://user-images.githubusercontent.com/124253477/221346236-5633f522-97b6-43e7-a675-82f3e483e3a4.png)

If you can't connect to your tooolhead after these steps (assuming all the ouputs look similar in success to the screenshots) then there is a good chance your klipper.bin settings were incorrect. Go back to Step 1 and check *all* the settings in the `make menuconfig` screen then recompile with `make clean` and `make`.

Then double-click the reset button on your toolhead to kick it back to katapult mode then go from Step 3.

## Updating Klipper Firmware via other methods

