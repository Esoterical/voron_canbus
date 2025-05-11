---
layout: default 
title: BigTreeTech MMB v2.0
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# 120 ohm Termination Resistor

The header for the 120R termination resistor is circled in purple

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/1e359304-b00f-4e93-a877-5b60beaa5249)


# DFU Mode
1.  Add a jumper as shown in the image below so the board can be powered via a USB connection
    ![image](https://github.com/Esoterical/voron_canbus/assets/124253477/c5f00b2a-c6dc-4f80-b9aa-4b963d21a580)


2. Connect your device to your Pi via USB
3. Press and hold the `Reset` and `BOOT` buttons down (button locations shown in step 1)
    1. Release `Reset` button
    2. Release `BOOT` button
4. The device should now be in DFU mode. Verify this via the `lsusb` command, which should look something like this:
    ```
    Bus 001 Device 005: ID 0483:df11 STMicroelectronics STM Device in DFU Mode
    ```

# Katapult Config

![image](https://github.com/user-attachments/assets/f543775f-5104-486c-ac3f-92e3a38fdbd5)



# Klipper Config

![image](https://github.com/user-attachments/assets/663e79e1-35f9-4638-8e37-7adf5feffee1)



# Sample Configuration

A sample configuration file can be found at [https://github.com/bigtreetech/MMB/tree/master/Firmware
](https://github.com/bigtreetech/MMB/tree/master/Firmware
)
