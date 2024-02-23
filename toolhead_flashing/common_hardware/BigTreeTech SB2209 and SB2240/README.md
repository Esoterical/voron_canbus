---
layout: default 
title: BigTreeTech SB2209 and SB2240
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# 120 ohm Termination Resistor

The header for the 120R termination resistor is circled in purple

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/2eddc105-c64f-4d00-9b8d-6f0ba0c23a82)


# DFU mode
1.  Add a jumper as shown in the image below so the board can be powered via a USB connection
    ![image](https://user-images.githubusercontent.com/124253477/226155311-c90b3571-72db-4f77-8b35-5e825cba9937.png)

2. Connect your device to your Pi via USB
3. Press and hold the `RESET` and `BOOT` buttons down (button locations shown in step 1)
    1. Release `RESET` button
    2. Release `BOOT` button
4. The device should now be in DFU mode. Verify this via the `lsusb` command, which should look something like this:
    ```
    Bus 001 Device 005: ID 0483:df11 STMicroelectronics STM Device in DFU Mode
    ```

# Katapult Config

![image](https://user-images.githubusercontent.com/124253477/228764307-36da2c3a-393d-43d9-b370-4eb31d231c27.png)


# Klipper Config

![image](https://user-images.githubusercontent.com/124253477/221349102-cd2f4060-9c29-44aa-b722-9883262b2fc3.png)

# Sample Configuration

A sample configuration file can be found at https://github.com/bigtreetech/EBB/tree/master/EBB%20SB2240_2209%20CAN
