---
layout: default 
title: Fysetc PITB V2.0
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# 120 ohm Termination Resistor

There is a permanent 120 ohm termination resistor soldered to the board, no need to add a jumper to enable it and also no ability to disable it.

# CAN mode

To enable CAN mode you must add a jumper between these two pins.

![image](https://github.com/user-attachments/assets/6f6b9e51-c025-4b34-8537-5449ee7f5833)

If you don't have a jumper in place then the board will default to CAN-FD mode which Klipper does not support.

# BOOT Mode

To put the PITB V2.0 into BOOT mode for initial flashing, unplug the main CAN cable then connect a USB cable from your Pi to the USB-C port of the PITB V2.0.

Then hold the BT0 button, press and release the RST button, count to five then release the BT0 button.

![image](https://github.com/user-attachments/assets/0a0f4cd2-68ce-4eb5-a412-7444df0cff82)

# Katapult Config

![image](https://github.com/user-attachments/assets/6720f402-2459-491a-9a59-1621ab4daf52)


# Klipper Config

![image](https://github.com/user-attachments/assets/1b2ca665-530b-4fe2-af33-27c62d4ca86e)

