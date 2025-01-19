---
layout: default 
title: Mellow Fly SHT36 and SHT42
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# 120 ohm Termination Resistor

The header for the termination resistor is circled in purple. You need to jumper *both* the header pairs

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/b546bbc3-60c3-459e-b309-4e2d007bfbc7)


# DFU Mode
1.  Add a jumper as shown in the image below to enable DFU mode
  
  ![image](https://github.com/Esoterical/voron_canbus/assets/124253477/0420edcd-512f-4f11-9353-5d8f3fc90e1f)

2. Connect your device to your Pi via USB
3. The device should now be in DFU mode. Verify this via the `lsusb` command, which should look something like this:
    ```
    Bus 001 Device 005: ID 0483:df11 STMicroelectronics STM Device in DFU Mode
    ```

# Katapult Config

![image](https://user-images.githubusercontent.com/124253477/228767194-0ee2d789-13b2-44f4-99aa-f0a7f750c99c.png)

# Klipper Config

![image](https://user-images.githubusercontent.com/124253477/221396323-83dd84e5-b661-4472-8074-ea45aa19dced.png)


# Sample Configuration

A sample config file can be found at [https://mellow-3d.github.io/fly-sht36_klipper_config.html](https://mellow-3d.github.io/fly-sht36_klipper_config.html)
