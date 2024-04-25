---
layout: default 
title: MKS Monster8 v2
parent: Common Mainboard Hardware
grand_parent: Mainboard Flashing
---




# 120 ohm Termination Resistor

There is a permanent 120 ohm termination resistor soldered to the board, no need to add a jumper to enable it and also no ability to disable it.

# DFU Mode

To put the Monster8 into DFU mode, hold the BOOT0 button and while still holding press and release the RESET button. Then count to 5 and release the BOOT0 button.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/0682086b-f507-430b-96fc-dfbe1812bef9)

# Katapult Config

![image](https://user-images.githubusercontent.com/124253477/221387924-afb1784e-823b-48b4-a5d4-3ea08cd09071.png)

# Klipper USB-CAN-Bridge Config

![image](https://user-images.githubusercontent.com/124253477/221387939-22b5a327-af94-4337-b952-849758bec999.png)


# NOTE ON ENABLING CAN
Make sure to have the CAN select jumper installed. The two jumpers should be on the LEFT and MIDDLE pins.

![image](https://user-images.githubusercontent.com/124253477/221388006-b58054f2-649b-44f0-a997-6d9423928736.png)
