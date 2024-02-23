---
layout: default 
title: Mellow Fly ERCF
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# 120 ohm Termination Resistor

There is a permanent 120 ohm termination resistor soldered to the board, no need to add a jumper to enable it and also no ability to disable it.

# BOOT Mode

To put the ERCF into boot mode (for initial flashing), unplug any USB and CAN cables from the ERCF, then hold the BOOT button. While continuing to hold the BOOT button plug in the USB cable from the Pi to the ERCF. Keep holding the BOOT button for a few more second, then release.

![image](img/dfu-mode.png)

The ERCF should now show up to an `lsusb` command as Pi RP2 Boot device:

![image](https://user-images.githubusercontent.com/124253477/226155004-2cc63e48-4545-46c0-92ed-b09cd26c8e80.png)


# Katapult Config

![image](./img/canboot.png)

# Klipper Config

![image](./img/klipper-canboot.png)

# Sample Config

A sample config file can be found at https://mellow.klipper.cn/#/board/fly_ercf/cfg

# More Info

https://mellow.klipper.cn/#/board/fly_ercf/
