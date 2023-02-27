**Big thanks to @terranx#9681 on the Voron Discord for investigating this issue and writing up these instructions**

# Fixing the Makerbase UTC 1.0

*Background:*

Makerbase recently released a STM32G0B1 based USB can device. It comes factory flashed with
klipper in USB CanBridge mode at a default bitrate of 250k. With the way klipper’s USB Can
Bridge mode works, you can’t change the bitrate without reflashing the device, no matter what
your Can0 file shows. Unfortunately makerbase set the CPU configuration of the STM32g0b1
such that you can’t actually enter bootmode to do a USB reflash. However if you grab an STLink
you can reflash it. This guide assumes you have an stlink device and updated. A clone or
legitimate st-link is acceptable.


Identify the SWD header on your board, highlighted below:

![image](https://user-images.githubusercontent.com/124253477/221704780-4e5a6603-b258-4876-9fb6-516029574300.png)

Note that Pin 1 is on the top right.  
You want to connect to your STLink it like such:  
Pin 1: SWDIO  
Pin 2: +3.3V  
Pin 3: SWCLK  
Pin 4: Ground  
Pin 5: Reset  
Once that is all connected. Connect your STLink device to your USB port and open up
STM32CubeProgrammer. Set the interface to ST-Link, setup the configuration like
below, and hit connect. If you’ve never connected this STLink before, reset mode is the
only option that is changed from default.

![image](https://user-images.githubusercontent.com/124253477/221705555-494ff0a7-22db-4fef-b391-5c34c99d0809.png)

Your board should be connected now. Your window should look something like this
(don’t worry about the exact values within Device Memory)

![image](https://user-images.githubusercontent.com/124253477/221705667-d373c26d-cbb9-41d0-8435-924a181ee096.png)

Now you need to click on the “OB” button on the left. Expand the User Configuration
setting and scroll down until you find the nBOOT_SEL option. You will need to uncheck
that, and then hit Apply

![image](https://user-images.githubusercontent.com/124253477/221705775-6e8ba9e9-f2d5-447f-b9a6-e1eb7a3f61c2.png)

If all goes well, you should get a message the option bytes were successfully
programmed. Now your boot button should work as expected.

From here you can flash whatever you want to the device. Your choices are to either use
klipper’s USB Can Bridge mode or flash a CandleLight variant. I personally think
CandleLight is better for this sort of thing. We will be using marckleinebudde’s
multichannel fork – note that it is still a WIP fork, so there may be bugs, but it seems to
work well enough for our purposes

cd ~ 
sudo apt-get install gcc-arm-none-eabi  
git clone https://github.com/marckleinebudde/candleLight_fw  
cd ~/candleLight_fw  
git checkout multichannel  
mkdir build  
cd build  
cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake/gcc-arm-none-eabi-8-2019-q3-update.cmake  
make budgetcan_fw  

now plugin your UTC in boot mode and type:  
make flash-budgetcan_fw  

After that you can reset your UTC and you can setup your can-bus similarly to a U2C or
UTOC setup.  
If you do wish to use klipper instead of CandelLight, you can use the following settings
for CanBoot and klipper respectively

![image](https://user-images.githubusercontent.com/124253477/221706131-6c538194-5a92-42e4-8078-e6ae88f78028.png)

![image](https://user-images.githubusercontent.com/124253477/221706218-a8f03655-0ce1-4008-874b-3466cb90f9c1.png)
