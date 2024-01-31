# Updating

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/764bf744-7ac3-4955-9cd2-c4d82ceb8df9)

Did you update the Klipper on your Pi, and now it is yelling at you about MCU version being out of date? Or maybe you just want to update the firmware on your boards for the latest features (or fixes). Either way, just follow these steps and it should be pretty painless.

If you only have a CAN Toolhead (ie. if you are running a USB Canbus adapter like a U2C or a UTOC) then go straight [here](#updating-your-toolhead).

If you have a mainboard running USB-CAN-Bridge mode klipper, go to [here](#updating-your-mainboard)

# Updating your Mainboard

## Updating Mainboard Katapult

This is only if you need to update katapult as well. If you are just doing a Klipper firmware update (because you update Klipper on your Pi and now it is yelling at you or something) then skip to [here](#updating-mainboard-klipper)

You should never really have to update your Katapult on the mainboard. Even if you wish to change your CanBUS speeds you don't need to change Katapult **On the Mainboard** as it only communicates via USB and not via CAN.

However, if you need to update Katapult for whatever reason, then:

**Step 1**

Change to your Katapult directory with `cd ~/katapult`
then go into the Katapult firmware config menu with `make menuconfig`

This time **make sure "Build Katapult deployment application" is configured** with the properly bootloader offset (same as the "Application start offset" that is relevant for your mainboard). Make sure all the rest of your settings are correct for your mainboard.

You can find screenshots of settings for comomon toolheads in the [mainboard_flashing/commmon_hardware](../mainboard_flashing/common_hardware) folder, but once again, **make sure "Build Katapult deployment application" is set**

If your board doesn't exist in the common_hardware folder already, then you want the Processor, Clock Reference, and Application Start offset to be set as per whatever board you are running. Set the "Build Katapult deployment application", and make sure "Communication Interface" is set to USB. Also make sure the "Support bootloader entry on rapid double click of reset button" is marked. It makes it so a double press of the reset button will force the board into Katapult mode. Makes re-flashing after a mistake a lot easier.

![image](https://user-images.githubusercontent.com/124253477/223301620-c1fd3d16-04e3-49ce-8d48-5498811f4c46.png)

This time when you run `make`, along with the normal katapult.bin file it will also generate a deployer.bin file. This deployer.bin is a fancy little tool that uses the existing bootloader (Katapult, or stock, or whatever) to "update" itself into the Katapult you just compiled.

So to update your Katapult, you just need to flash this deployer.bin file via your existing Katapult (in a very similar way you would flash klipper via Katapult).

**Step 2**

If you already have a functioning CAN setup, and your [mcu] canbus_uuid is in your printer.cfg, then you can force Katapult to reboot into Katapult mode by running:

`python3 ~/katapult/scripts/flashtool.py -i can0 -u yourmainboarduuid -r`

![image](https://user-images.githubusercontent.com/124253477/223303347-385ec07c-5211-42d3-b985-4dc38c2864ec.png)

If will probably say "Flash success" **THIS IS NOT ACTUALLY FLASHING ANYTHING, YOU NEED TO CONTINUE WITH THE STEPS BELOW**

**Step 3**

If you don't have the UUID (or something has gone wrong with the klipper firmware and your mainboard is hung) then you can also double-press the RESET button on your mainboard to force Katapult to reboot into Katapult mode.

You can verify it is in the proper mode by running `ls /dev/serial/by-id`. If you see a "usb-katapult-......" device then it is good to go.

![image](https://user-images.githubusercontent.com/124253477/223303596-f7709d3c-d652-401c-959d-560381a39cff.png)

**Step4**

Once you are at this stage you can flash the deployer.bin by running:

`python3 ~/katapult/scripts/flashtool.py -f ~/katapult/out/deployer.bin -d /dev/serial/by-id/usb-katapult_stm32f446xx_37001A001851303439363932-if00`

and your Katapult should update.

![image](https://user-images.githubusercontent.com/124253477/223303940-e7c19b00-04bb-47b3-9230-458e9f2de251.png)

## Updating Mainboard Klipper

*Step 1**

To update Klipper, you first need to compile a new klipper.bin with the correct settings.

Move into the klipper directory on the Pi by running:
`cd ~/klipper`
Then go into the klipper configuration menu by running:
`make menuconfig`

You can find screenshots of settings for comomon toolheads in the [mainboard_flashing/commmon_hardware](../mainboard_flashing/common_hardware) folder.

Otherwise, you want the Processor and Clock Reference to be set as per whatever board you are running. Set Communication interface to 'USB to CAN bus bridge' then set the CAN Bus interface to use the pins that are specific to your mainboard. Also set the CAN bus speed to the same as the speed in your can0 file. In this guide it is set to 1000000.

Once you have the firmware configured, hit Q to save and quit from the makemenu screen, then run a `make clean` to make sure there are no old files hanging around, then `make` to compile the firmware. It will save the firmware to ~/klipper/out/klipper.bin

**Step 2**

If you already have a functioning CAN setup, and your [mcu] canbus_uuid is in your printer.cfg, then you can force Katapult to reboot into Katapult mode by running:

`python3 ~/katapult/scripts/flashtool.py -i can0 -u yourmainboarduuid -r`

![image](https://user-images.githubusercontent.com/124253477/223303347-385ec07c-5211-42d3-b985-4dc38c2864ec.png)

**Step 3**

If you don't have the UUID (or something has gone wrong with the klipper firmware and your mainboard is hung) then you can also double-press the RESET button on your mainboard to force Katapult to reboot into Katapult mode.

You can verify it is in the proper mode by running `ls /dev/serial/by-id`. If you see a "usb-katapult-......" device then it is good to go.

![image](https://user-images.githubusercontent.com/124253477/223303596-f7709d3c-d652-401c-959d-560381a39cff.png)

**Step4**

Then you can run the same command you used to initially flash Klipper:

`python3 ~/katapult/scripts/flashtool.py -f ~/klipper/out/klipper.bin -d /dev/serial/by-id/usb-katapult_stm32f446xx_37001A001851303439363932-if00`

If you can't connect to your tooolhead after these steps (assuming all the ouputs look similar in success to the screenshots) then there is a good chance your klipper.bin settings were incorrect. Go back to Step 1 and check *all* the settings in the `make menuconfig` screen then recompile with `make clean` and `make`.

Then double-click the reset button on your toolhead to kick it back to katapult mode then go from Step 3.


# Updating your Toolhead

If you are planning on updating both Katapult and Klipper (ie. for changing CAN speeds) then it's recommended to update Katapult first. Otherwise you may get stuck in a situation where you need to connect your toolhead back up via USB and flash as if from scratch.

## Updating Toolhead Katapult

This is only if you need to update katapult as well. If you are just doing a Klipper firmware update (because you update Klipper on your Pi and now it is yelling at you or something) then skip to [here](#updating-toolhead-klipper)

**Step 1**

Change to your Katapult directory with `cd ~/katapult`
then go into the Katapult firmware config menu with `make menuconfig`
This time **make sure "Build Katapult deployment application" is configured** with the properly bootloader offset (same as the "Application start offset" that is relevant for your toolhead). Make sure all the rest of your settings are correct for your toolhead.

You can find screenshots of settings for comomon toolheads in the [toolhead_flashing/commmon_hardware](../mainboard_flashing/common_hardware) folder, but once again, **make sure "Build Katapult deployment application" is set**


![image](https://user-images.githubusercontent.com/124253477/223301620-c1fd3d16-04e3-49ce-8d48-5498811f4c46.png)

This time when you run `make`, along with the normal katapult.bin file it will also generate a deployer.bin file. This deployer.bin is a fancy little tool that uses the existing bootloader (Katapult, or stock, or whatever) to "update" itself into the Katapult you just compiled.

So to update your Katapult, you just need to flash this deployer.bin file via your existing Katapult (in a very similar way you would flash klipper via Katapult).

**Step 2**

If you already have a functioning CAN setup, and your [mcu toolhead] canbus_uuid is in your printer.cfg, then you can force Katapult to reboot into Katapult mode by running:

`python3 ~/katapult/scripts/flashtool.py -i can0 -u yourtoolheaduuid -r`

![image](https://user-images.githubusercontent.com/124253477/223307559-1da6a2dd-d572-456c-9ee6-0565e9192fea.png)

**Step 3**

If you don't have the UUID (or something has gone wrong with the klipper firmware and your toolboard is hung) then you can also double-press the RESET button on your toolhead to force Katapult to reboot into Katapult mode.

You can verify it is in the proper mode by running `python3 ~/katapult/scripts/flashtool.py -q`. If you see a "Detected UUID: xxxxxxxxx, Application: Katapult" device then it is good to go.

![image](https://user-images.githubusercontent.com/124253477/223307593-b96dc642-9fa0-494b-93b8-a155d14bb535.png)

**Step4**

Once you are at this stage you can flash the deployer.bin by running:

`python3 ~/katapult/scripts/flashtool.py -i can0 -u b6d9de35f24f -f ~/katapult/out/deployer.bin`

and your Katapult should update.

## Updating Toolhead Klipper

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

