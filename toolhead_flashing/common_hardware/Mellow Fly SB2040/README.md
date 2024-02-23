---
layout: default 
title: Mellow Fly SB2040
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# 120 ohm Termination Resistor

The header for the 120R termination resistor is circled in purple

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/87099ccc-7012-4d90-9147-eec3207b29ff)


# BOOT Mode

To put the SB2040 into boot mode (for initial flashing), unplug any USB and CAN cables from the SB2040, then hold the BOOT button. While continuing to hold the BOOT button plug in the USB cable from the Pi to the SB2040. Keep holding the BOOT button for a few more second, then release. The SB2040 should now show up to an `lsusb` command as Pi RP2 Boot device:

![image](https://user-images.githubusercontent.com/124253477/226155004-2cc63e48-4545-46c0-92ed-b09cd26c8e80.png)


# Katapult Config

![image](https://user-images.githubusercontent.com/124253477/228765757-5a8bab71-6f57-4467-8400-4bbb9d37e2f6.png)

# Klipper Config

![image](https://user-images.githubusercontent.com/124253477/221348650-b9f2749e-0f3b-44b4-b34a-a57bd8beb706.png)

# Sample Config

A sample config file can be found at https://mellow-3d.github.io/fly_sb2040_v1_klipper_config.html


# More Info

https://mellow-3d.github.io/fly_sb2040_v1_general.html
