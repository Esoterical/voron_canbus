---
layout: default 
title: Mellow Fly UTOC
parent: Common CAN Adapters
grand_parent: Dedicated USB CAN Device
---

# 120 ohm Termination Resistor

There is a permanent 120 ohm termination resistor soldered to the board, no need to add a jumper to enable it and also no ability to disable it.

# Flashing UTOC Firmware

This information is from https://mellow-3d.github.io/fly-utoc_firmware.html#flashing-utoc-firmware

**Note: The UTOC firmware is intalled at the manufacturer. This procedure is only needed to restore the OEM firmware.**

Download the stock firmware from https://mellow-3d.github.io/files/utoc_firmware.bin and copy it to the user folder on your Pi.


Install the DFU mode Jumper

![image](https://user-images.githubusercontent.com/124253477/222069095-ae8c486e-5818-4925-927b-4099d517bf1c.png)

![image](https://user-images.githubusercontent.com/124253477/222069120-9a27bcf5-2513-4728-b19f-2925287e1442.png)


Connect the UTOC to your Pi by the USB C port


On your Pi run the command:

`lsusb`

It should return

`Bus 001 Device 004: ID 0483:df11 STMicroelectronics STM Device in DFU Mode`

Run the following command to flash the UTOC.

`sudo dfu-util --dfuse-address -d 0483:df11 -c 1 -i 0 -a 0 -s 0x08000000 -D ~/utoc_firmware.bin`
