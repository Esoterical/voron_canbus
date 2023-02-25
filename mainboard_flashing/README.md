
# General Info

The following should be taken as an overall guide on what you are going to be achieving. 

**PLEASE DO NOT TAKE THE SCREENSHOTS/CONFIGURATIONS ON THIS PAGE EXACTLY AS WRTTEN AS THEY MAY NOT BE COMPATIBLE WITH YOUR PARTICULAR MAINBOARD**

You will need to adapt the below instructions so they cover *your* board's specicific configuration. There are also some included configurations for specific popular boards in the https://github.com/Esoterical/voron_canbus/tree/main/mainboard_flashing/canboot and https://github.com/Esoterical/voron_canbus/tree/main/mainboard_flashing/non_canboot folders.


Before doing anything it is good to have some dependencies installed. Do this by running these on your Pi:
```
apt update
apt upgrade
apt install python3 python3-pip python3-can
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
You want the Processor, Clock Reference, and Application Start offset to be set as per whatever board you are running. Keep the "Build CanBoot Deployment Application" to (do not build), and make sure "Communication Interface" is set to USB.

![image](https://user-images.githubusercontent.com/124253477/221333924-0a4d3c28-d084-4f8c-b93f-0670114bd090.png)





