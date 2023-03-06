
The U2C came stock with bad firmware that would cause flashing problems down the line. A fixed firmware can be downloaded from:  
https://github.com/Arksine/CanBoot/files/10410265/G0B1_U2C_V2.zip  
(you can read about the error at https://github.com/Arksine/CanBoot/issues/44)

Download the .zip file, then extract the G0B1_U2C_V2.bin file and upload the file to your home directory (/home/pi/G0B1_U2C_V2.bin). Then press the boot button on the U2C while plugging it in to your Pi to put it into DFU mode.

![image](https://user-images.githubusercontent.com/124253477/221551674-3e5754de-5965-40fa-8474-cde8f5790fc5.png)

Confirm it is connected in DFU mode by running `dfu-util -l`. You should see the devive:

![image](https://user-images.githubusercontent.com/124253477/221551890-3205eafb-9f16-41b5-8020-ebb1ebbf5ded.png)

If you can see it there then just run this command to flash the fixed firmware to the U2C:

`dfu-util -D ~/G0B1_U2C_V2.bin -a 0 -s 0x08000000:leave`

![image](https://user-images.githubusercontent.com/124253477/221552152-89f14967-b807-4e54-9159-003b19eed784.png)

You may see an "error during download get-status" down the bottom. You can ignore that as long as everything else is successful.

Once flashed, unplug the U2C from the Pi then plug it back in. Run an `ifconfig` and you should see a "can0" interface (assuming you have already set the /etc/network/interfaces.d/can0 file). If so, then congratulations your U2C is succesfully flashed with the fixed firmware.
