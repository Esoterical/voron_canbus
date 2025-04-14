---
layout: default 
title: Fysetc SB Combo V2
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# Safety

Do not use SB1.3 cable directly with V2, their positive and negative positions are reversed and will lead to damage.
The H and L wires are also swapped, but this won't damage anything (it just wouldn't work).

Just use the new cable that comes with the SB Combo V2 board.


# CANBUS Mode

To put the SB Combo V2 board into CAN mode (instead of USB mode) make sure the two switches are in the "up" position.

![image](https://github.com/user-attachments/assets/a5be3ceb-fa40-41a5-a245-058a7c04f866)

# 120 ohm Termination Resistor

The SB Combo V2 board has a 120 ohm termination resistor enabled by default. If you need to disable this you need to cut the trace between these two solder pads.

![image](https://github.com/user-attachments/assets/fc060894-251a-4fd5-8dbb-4dd5854c5019)

{: .note }
> Please note, due to the USB/CAN switching ability of the Combo V2, when it is unpowered you are unable to measure the 120 ohm termination resistor if you just measure across the H and L wires.
> This has no effect in use, but can make troubleshooting a broken wire a little more difficult. Something to keep in mind.



# DFU Mode

To put the SB Combo V2 into DFU mode, connect it via USB to the Pi using the USB-C port then hold the BOOT0 button, press and release the RESET button, then count to 5 and release the BOOT0 button.

![image](https://github.com/user-attachments/assets/922c0f4f-9b4a-44d5-b636-77b9678f62f1)



# Katapult Config

![image](https://github.com/user-attachments/assets/5225459f-11ff-4f76-9fb3-f3524aec2272)



# Klipper Config

![image](https://github.com/user-attachments/assets/46e29e52-36ae-4390-965e-ef4caf0cb00d)



# Sample Config

A sample config file can be found at https://github.com/FYSETC/SB_Combo_V2/tree/main/Config

# More Info

More information can be found at the [SB Combo V2 wiki](https://wiki.fysetc.com/docs/SBComboV2)
