---
layout: default 
title: Mellow Fly SB2040v3
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# Enable Klipper CAN Mode

Have both single switches in the "down" position to enable the board for Klipper CANBUS

![image](https://github.com/user-attachments/assets/d17ff68e-b297-4bb1-923a-298afce42bfa)


# 120 ohm Termination Resistor

The 120 ohm resistor is enabled by switch 1 on the eight switch block

![image](https://github.com/user-attachments/assets/2c6b3c23-ec21-4fcb-91f9-9c379591c527)



# BOOT Mode

Plug a USB cable from the pi to the SB2040v3 then hold down the BOOT button, breifly press the RST button (while still holding BOOT), wait a few seconds, then release the BOOT button. The SB2040v3 should now show up to an lsusb command as Pi RP2 Boot device:

![image](https://github.com/user-attachments/assets/5cc1bef8-329a-4259-9756-c8a14c23af18)



# Katapult Config

![image](https://github.com/user-attachments/assets/9e9d2524-cf91-4b63-82b0-ac0d89e59bfd)

# Klipper Config

![image](https://github.com/user-attachments/assets/39847f63-bbd8-4f8b-8503-32e0981df504)


# Sample Config

A sample config file can be found at https://mellow.klipper.cn/#/board/fly_sb2040_v3_pro/cfg


# More Info

https://mellow.klipper.cn/#/board/fly_sb2040_v3_pro/README
