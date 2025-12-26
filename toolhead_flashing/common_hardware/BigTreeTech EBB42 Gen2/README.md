---
layout: default 
title: BigTreeTech EBB42 Gen2
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# Breakout Board

The EBB42 Gen2 comes with a convenient protection/connection breakout board that sits in your electronics bay. 
When connecting to the EBB42 Gen2 over USB (for initial DFU flashing) you need to make sure a USB cable is connected from your Pi to the USB-C port of the breakout board.

When connecting to the EBB42 Gen2 over CAN (for flashing Klipper via Katapult and for just normal use) make sure there are CAN H/L wires connected from your CAN adapter
(a dedicated adapter like a U2C, or from your USB-CAN-Bridge mainboard) to the CAN port of the breakout board (shown in orange).

**PLEASE NOTE** The breakout board does **NOT** provide any usb-to-can adapter ability by itself. You still need some other device providing the CAN interface to your pi
(either a dedicated CAN adapter like a U2C or a mainboard in usb-can-bridge mode).

<img width="1193" height="956" alt="image" src="https://github.com/user-attachments/assets/06b9a2b2-1697-444c-873f-b3f219c6006a" />

# CANBUS Mode

To put the EBB42 Gen2 into CAN mode (instead of USB mode) make sure to **add** a jumper to the USB/CAN header

<img width="655" height="478" alt="image" src="https://github.com/user-attachments/assets/6d3c9f5d-413d-4588-b8c5-5804552e4c3c" />


# 120 ohm Termination Resistor

The header for the 120R termination resistor is circled in purple

<img width="747" height="523" alt="image" src="https://github.com/user-attachments/assets/e8f3083e-6bb5-47e2-93f2-e4a88e5d304b" />


# DFU Mode

To put the EBB42 Gen2 into DFU mode first power off the printer then connect the main CAN/Power cable from the EBB42 Gen2 to the breakout board that goes in your electronics bay.

Also, make sure to temporarily **remove** the USB/CAN selection jumper from the EBB42 Gen2 board.

Then make sure you have power connected to this breakout board as well, and then connect a USB cable from your Pi to the breakout board. 

We need the EBB42 Gen2 connected via USB at this stage for the DFU mode to work.

Then power up the system and on the EBB42 Gen2 board hold the BOOT button, press and release the RST button, then count to 5 and release the BOOT button.

<img width="715" height="402" alt="image" src="https://github.com/user-attachments/assets/6085f87d-8462-4454-a477-e9b3f02263b0" />


Once you have finished any DFU flashing be sure to **add** the USB/CAN selection jumper back.


# Katapult Config

<img width="778" height="273" alt="image" src="https://github.com/user-attachments/assets/f1df3f71-13cb-4e01-b82f-26f9565e8aab" />


# Klipper Config

<img width="724" height="236" alt="image" src="https://github.com/user-attachments/assets/fe7c7584-4c79-4e3a-a950-1cc4322ba55e" />


# Sample Configuration

A sample configuration file can be found at [https://github.com/bigtreetech/EBB/blob/master/EBB_GEN2/EBB42_GEN2/sample-bigtreetech-ebb42-gen2-v1.0.cfg](https://github.com/bigtreetech/EBB/blob/master/EBB_GEN2/EBB42_GEN2/sample-bigtreetech-ebb42-gen2-v1.0.cfg)
