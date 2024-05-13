---
layout: default 
title: MKS THR36 V1.0
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# 120 ohm Termination Resistor

There is a permanent 120 ohm termination resistor soldered to the board, no need to add a jumper to enable it and also no ability to disable it.

# BOOT Mode

To put the THR36 into boot mode (for initial flashing), unplug any USB and CAN cables from the THR36, then put the 5v jumper in the middle and "on" position so the board can receive power over the USB connection:

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/f8d98041-e9da-4c99-87bf-d25b899e71c4)


Plug a USB cable from the pi to the THR36 then hold down the BOOT button, breifly press the RESET button (while still holding BOOT), wait a few seconds, then release the BOOT button. The THR36 should now show up to an `lsusb` command as Pi RP2 Boot device:

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/81d28d7c-a273-47d7-a57b-a34c84ccf279)




# Katapult Config

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/a7638805-f9f0-475a-abbb-1ce4f3d239aa)



# Klipper Config

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/9cd3358d-8c9f-4462-9521-9ed2f1ac15d7)


# Sample Config

A sample config file can be found at https://github.com/makerbase-mks/MKS-THR36-THR42-UTC/tree/main


