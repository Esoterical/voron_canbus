---
layout: default 
title: Fysetc H36 v2.0
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# CANBUS Mode

To put the H36 V2 board into CAN mode (instead of USB mode) you simply need to make sure the Katapult and Klipper firmware settings (further down below) have the 
"GPIO pins to set at micro-controller startup" set correctly. For CAN mode this needs to be `!PA2`


# 120 ohm Termination Resistor

The H36 V2 board has a 120 ohm termination resistor enabled by default. If you need to disable this you need to cut between these two solder pads to sever the trace between them.

![image](https://github.com/user-attachments/assets/8c8848e7-527a-43ef-9403-e13547804793)

If you need to reenable the 120 ohm resistor again after cutting simply solder the two pads together.


{: .note }
> Please note, due to the USB/CAN switching ability of the H36, when it is unpowered you are unable to measure the 120 ohm termination resistor if you just measure across the H and L wires.
> This has no effect in use, but can make troubleshooting a broken wire a little more difficult. Something to keep in mind.


# DFU Mode

To put the H36 into DFU mode, connect it via USB to the Pi using the USB-C port then hold the BOOT0 button, press and release the RESET button, then count to 5 and release the BOOT0 button.

![image](https://github.com/user-attachments/assets/cdc62cf8-e926-4f4d-9c99-6f8d047b4db3)




# Katapult Config

<img width="789" height="245" alt="image" src="https://github.com/user-attachments/assets/94d1e438-cb9f-45bd-b43c-3bf3119d4e9a" />

# Klipper Config

<img width="756" height="187" alt="image" src="https://github.com/user-attachments/assets/778e42d7-6349-48ef-af1b-df0905ca2e38" />



# Sample Config

A sample config file can be found at [https://github.com/FYSETC/H36_Combo_V2/tree/main
](https://github.com/FYSETC/H36_Combo_V2/tree/main)

# More Info

More information can be found at the [H36 V2 wiki](https://wiki.fysetc.com/docs/H36-Combo-V2)
