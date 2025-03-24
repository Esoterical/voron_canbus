---
layout: default 
title: Fysetc PITB V1.0
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# 120 ohm Termination Resistor

There is a permanent 120 ohm termination resistor soldered to the board, no need to add a jumper to enable it and also no ability to disable it.


# BOOT Mode

To put the PITB V1.0 into BOOT mode for initial flashing, unplug the main CAN cable then connect a USB cable from your Pi to the USB-C port of the PITB V1.0.

Then hold the BOOT SEL button, press and release the RST button, count to five then release the BOOT SEL button.

![image](https://github.com/user-attachments/assets/2338aaf5-2891-4ff2-988f-7329fe6e907d)


# Katapult Config

![image](https://github.com/user-attachments/assets/80176c27-3310-4827-b0aa-01469ddc1d2a)



# Klipper Config

![image](https://github.com/user-attachments/assets/adc4420c-4183-4620-b816-086a8b0de25e)
