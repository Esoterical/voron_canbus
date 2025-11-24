---
layout: default 
title: BigTreeTech EBB36 Gen2
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# CANBUS Mode

To put the EBB36 Gen2 into CAN mode (instead of USB mode) make sure to **add** a jumper to the USB/CAN header

<img width="1015" height="559" alt="image" src="https://github.com/user-attachments/assets/767bf8fb-bab9-4a29-82b2-96e6b2bf10e3" />


# 120 ohm Termination Resistor

The header for the 120R termination resistor is circled in purple

<img width="1015" height="559" alt="image" src="https://github.com/user-attachments/assets/ecf1d704-d21b-4790-85a0-b50888a75f55" />


# DFU Mode

To put the EBB36 Gen2 into DFU mode first power off the printer then connect the main CAN/Power cable from the EBB36 Gen2 to the breakout board that goes in your electronics bay.

Also, make sure to temporarily **remove** the USB/CAN selection jumper from the EBB36 Gen2 board.

Then make sure you have power connected to this breakout board as well, and then connect a USB cable from your Pi to the breakout board. 

We need the EBB36 Gen2 connected via USB at this stage for the DFU mode to work.

Then power up the system and on the EBB36 Gen2 board hold the BOOT button, press and release the RST button, then count to 5 and release the BOOT button.

<img width="1365" height="671" alt="image" src="https://github.com/user-attachments/assets/2b0bf37d-0bbd-4aa2-8c0c-7b3fe2742544" />

Once you have finished any DFU flashing be sure to **add** the USB/CAN selection jumper back.


# Katapult Config

<img width="778" height="273" alt="image" src="https://github.com/user-attachments/assets/f1df3f71-13cb-4e01-b82f-26f9565e8aab" />


# Klipper Config

<img width="724" height="236" alt="image" src="https://github.com/user-attachments/assets/fe7c7584-4c79-4e3a-a950-1cc4322ba55e" />


# Sample Configuration

A sample configuration file can be found at [https://github.com/bigtreetech/EBB/blob/master/EBB_GEN2/EBB36_GEN2/sample-bigtreetech-ebb36-gen2-v1.0.cfg](https://github.com/bigtreetech/EBB/blob/master/EBB_GEN2/EBB36_GEN2/sample-bigtreetech-ebb36-gen2-v1.0.cfg)
