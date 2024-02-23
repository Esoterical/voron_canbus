---
layout: default 
title: BigTreeTech SB2209 (RP2040)
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# 120 ohm Termination Resistor

The header for the 120R termination resistor is circled in purple

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/7f9863d3-9593-49d6-bf4c-34ba3d47a687)

# BOOT Mode

To put the SB2209 into boot mode (for initial flashing), unplug any USB and CAN cables from the SB2040, then put the 5v jumper in place so the board can receive power over the USB connection:

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/e8daeabf-3c85-45cb-89e3-0735cca961dd)

Plug a USB cable from the pi to the SB2209 then hold down the BOOT button, breifly press the RST button (while still holding BOOT), wait a few seconds, then release the BOOT button. The SB2209 should now show up to an `lsusb` command as Pi RP2 Boot device:

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/fda3a72c-b255-46fd-ab11-938c92844d42)



# Katapult Config

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/3b1a7a33-48ce-4136-8a0f-0aad49d65f76)


# Klipper Config

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/aac98e3a-472f-4934-9000-13de6e66849e)

# Sample Config

A sample config file can be found at https://github.com/bigtreetech/EBB/tree/master/EBB%20SB2209%20CAN%20(RP2040)


