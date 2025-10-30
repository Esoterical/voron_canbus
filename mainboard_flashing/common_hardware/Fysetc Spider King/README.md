---
layout: default 
title: Fysetc Spider King
parent: Common Mainboard Hardware
grand_parent: Mainboard Flashing
---

# 120 ohm Termination Resistor

There is a permanent 120 ohm termination resistor soldered to the board, no need to add a jumper to enable it and also no ability to disable it.

# CAN Port

The CAN port is a JST-XH header located here:

<img width="439" height="316" alt="image" src="https://github.com/user-attachments/assets/d08b7d41-9e68-4eed-bbf2-f229cdfd6164" />



# DFU Mode

To put the Spider King into DFU mode, first power off the board. Then make sure there is **no** jumper on the USB-5V header. 

Place jumper on the BT0 and 3V3 pins. Then power on the board.

<img width="1308" height="357" alt="image" src="https://github.com/user-attachments/assets/b737cd84-25c5-42a2-bc69-456ffcb78101" />




# Katapult Config

<img width="822" height="297" alt="image" src="https://github.com/user-attachments/assets/adac1257-e633-4f5c-8b07-59dcf32791d9" />

# Klipper USB-CAN-Bridge Config

<img width="831" height="293" alt="image" src="https://github.com/user-attachments/assets/1bae866d-f9d0-44e4-a36f-3442edb28732" />


