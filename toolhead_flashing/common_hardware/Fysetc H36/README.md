---
layout: default 
title: Fysetc H36
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# CANBUS Mode

To put the H36 board into CAN mode (instead of USB mode) you simply need to make sure the Katapult and Klipper firmware settings (further down below) have the 
"GPIO pins to set at micro-controller startup" set correctly. For CAN mode this needs to be `!PA2`


# 120 ohm Termination Resistor

The H36 board has a 120 ohm termination resistor enabled by default. If you need to disable this you need desolder the bridge on the back of the board

![image](https://github.com/user-attachments/assets/3505af56-8d9d-49ba-8dbe-2e897df7f66e)

{: .note }
> Please note, due to the USB/CAN switching ability of the H36, when it is unpowered you are unable to measure the 120 ohm termination resistor if you just measure across the H and L wires.
> This has no effect in use, but can make troubleshooting a broken wire a little more difficult. Something to keep in mind.


# DFU Mode

To put the H36 into DFU mode, connect it via USB to the Pi using the USB-C port then hold the BOOT0 button, press and release the RESET button, then count to 5 and release the BOOT0 button.

![image](https://github.com/user-attachments/assets/cdc62cf8-e926-4f4d-9c99-6f8d047b4db3)




# Katapult Config

![image](https://github.com/user-attachments/assets/b52db77f-6cc2-4866-a600-ef67f8ae250e)



# Klipper Config

![image](https://github.com/user-attachments/assets/0ee6c2c9-90ba-4ab6-a108-068d3660130e)




# Sample Config

A sample config file can be found at [https://github.com/FYSETC/H36_Combo/tree/main
](https://github.com/FYSETC/H36_Combo/tree/main)

# More Info

More information can be found at the [H36 wiki](https://wiki.fysetc.com/H36_Combo/)
