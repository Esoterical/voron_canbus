---
layout: default 
title: Mellow Fly SHT36v2
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

*Note, SHT-36 V2 units shipped before 2022-10-18 will use the GD32F103 CPU, later shipments will use the APM32F072 CPU. The settings are exactly the same except for the processor model. Make sure the chosen processor model STM32F072 or STM32F103 matches with your board*

# 120 ohm Termination Resistor

The header for the 120R termination resistor is circled in purple

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/18e2c705-41be-4d99-a1c3-7ebcc2c76751)


# DFU Mode
1.  Add a jumper as shown in the image below to enable DFU mode
  
    ![image](https://github.com/Esoterical/voron_canbus/assets/124253477/d5e77aa8-8cbd-4766-b21f-52053d1bc16a)

2. Connect your device to your Pi via USB
3. The device should now be in DFU mode. Verify this via the `lsusb` command, which should look something like this:
    ```
    Bus 001 Device 005: ID 0483:df11 STMicroelectronics STM Device in DFU Mode
    ```
**The SHT36v2 comes with two different versions of STM32 MCU chips. Make sure you pick the correct config for the MCU chip you have**

# STM32F103 (GD32F103)

## Katapult Config

![image](https://user-images.githubusercontent.com/124253477/228767706-e14d572a-b0de-4445-9c7c-11276fc8c4a7.png)

## Klipper Config

![image](https://user-images.githubusercontent.com/124253477/221396540-52695957-90f7-4f01-9d7d-130a76a81ee8.png)

# STM32F072 (APM32F072)

## Katapult Config

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/63ca392a-16b8-4516-8fa8-bb22b6c9f7a0)

## Klipper Config

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/21f25ff7-a775-4081-a4b0-47e42076f969)


# Sample Configuration

A sample config file can be found at https://mellow-3d.github.io/fly-sht36_v2_klipper_config.html

# More Info

https://mellow-3d.github.io/fly-sht36_v2_general.html
