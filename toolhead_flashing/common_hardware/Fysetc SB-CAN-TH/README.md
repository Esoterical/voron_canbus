---
layout: default 
title: Fysetc SB-CAN-TH
parent: Common Toolhead Hardware
grand_parent: Toolhead Flashing
---

# 120 ohm Termination Resistor

The Fysetc SB-CAN-TH v1.1 has no resistor nor any provisions for adding one.

The Fysetc SB-Can-TH v1.3B has header for the 120R termination resistor which is circled in purple

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/592d4dd6-429b-4833-b3f7-2b78d34fa2be)


# DFU Mode

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/dda93dd3-bdc8-4d8f-be9b-45658668bfe1)

## For V1.1

1. Power *off* your whole printer (at the wall)
2. Connect SB-CAN-TH Micro-USB to Pi USB-A
3. Power on your printer
4. Run `lsusb` to check if the SB-CAN-TH shows in DFU mode. If not, go back to step 1.
5. If it shows as a DFU device in `lsusb` you can continue with the flashing steps
6. After flashing, power down the whole printer, remove the USB cable, connect all the CAN cables, then power on the printer.


## For V1.3

1. Power *off* your whole printer (at the wall)
2. Connect SB-CAN-TH Micro-USB to Pi USB-A
3. Power on your printer, wait for the Pi to be fully booted
4. Hold the reset button on the SB-CAN-TH for 2 seconds then release it.
5. Run `lsusb` to check if the SB-CAN-TH shows in DFU mode. If not, go back to step 1.
6. If it shows as a DFU device in `lsusb` you can continue with the flashing steps
7. After flashing, power down the whole printer, remove the USB cable, connect all the CAN cables, then power on the printer.



# Katapult Config

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/ece9bd34-5165-4864-ba95-73e8b1846f94)


# Klipper Config

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/b38f1af9-cf9b-4173-9e30-06e0e0aa1d76)

# Sample Configuration

A sample configuration file can be found at https://github.com/FYSETC/FYSETC_SB_CAN_TOOLHEAD
