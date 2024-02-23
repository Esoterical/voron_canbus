---
layout: default 
title: BigTreeTech U2C v2.1
parent: Common CAN Adapters
grand_parent: Dedicated USB CAN Device
---


# 120 ohm Termination Resistor

The header for the 120R termination resistor is circled in purple

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/c7044a7f-db00-42a1-b75f-c449c44a13ca)

# Wiring

![CANbus_U2C_Pinout_on_Power_Connector](https://github.com/Esoterical/voron_canbus/assets/124253477/57a4a525-31ea-4565-ad69-6bb50510c090)


# Bad Firmware

The U2C came stock with bad firmware that would cause flashing problems down the line. This was mainly back in early 2023 so if you have purchased a board *recently* this may not be an issue, but flashing this firmware can't hurt anyway and is very simple to do.

I have copied a fixed version of the firmware here, you can download it to your pi by running:
```
cd ~/
wget https://github.com/Esoterical/voron_canbus/raw/main/can_adapter/BigTreeTech%20U2C%20v2.1/G0B1_U2C_V2.bin
```

(you can read about the error at https://github.com/Arksine/katapult/issues/44)

If you used the wget link the firmware should now be in your home directory. Press the boot button on the U2C while plugging it in to your Pi to put it into DFU mode.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/ad3a5d48-fc30-4dea-9b9e-96fb1eec37e3)

Confirm it is connected in DFU mode by running `sudo dfu-util -l`. You should see the devive:

![image](https://user-images.githubusercontent.com/124253477/221551890-3205eafb-9f16-41b5-8020-ebb1ebbf5ded.png)

If you can see it there then just run this command to flash the fixed firmware to the U2C:

`sudo dfu-util -D ~/G0B1_U2C_V2.bin -a 0 -s 0x08000000:leave`

![image](https://user-images.githubusercontent.com/124253477/221552152-89f14967-b807-4e54-9159-003b19eed784.png)

You may see an "error during download get-status" down the bottom. You can ignore that as long as everything else is successful.

Once flashed, unplug the U2C from the Pi then plug it back in. Run an `ifconfig` and you should see a "can0" interface (assuming you have already set the /etc/network/interfaces.d/can0 file). If so, then congratulations your U2C is succesfully flashed with the fixed firmware.
