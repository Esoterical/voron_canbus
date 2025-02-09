---
layout: default 
title: Multiple CAN Networks
parent: Troubleshooting
---

Credit to @fragmon90's post on the Armored Turtle 3D discord for the framework of these instructions.

# Multiple CAN Networks


Connect your first CAN interace
LSUSB
![image](https://github.com/user-attachments/assets/979ce265-cedb-48ab-aa13-5c20f61a5f5a)

Note down the Bus and Device ID (in the above it is `Bus 001 Device ID 010`)

Run udevadmin info with the Bus and Device ID and grep to find the serial

`udevadm info -a -n /dev/bus/usb/001/010 | grep ATTR{serial}`

![image](https://github.com/user-attachments/assets/07fed863-dd8a-4097-9c68-36e1c27e496d)

sudo nano /etc/udev/rules.d/99-can.rules

SUBSYSTEM=="net", ACTION=="add", ATTR{serial}=="YOUR_SERIAL", NAME="can0"

![image](https://github.com/user-attachments/assets/4e78045a-1667-42d5-b842-35d3f2bef8e9)

ctrl X to save and exit, press Y when it asks to save modified buffer, press enter when it asks for the filename to use

Connected second CAN adapter

LSUSB

![image](https://github.com/user-attachments/assets/aec211b4-6850-4dbc-8353-631f90bd1861)

Note down the Bus and Device ID (in the above it is `Bus 001 Device ID 012`)

Run udevadmin info with the Bus and Device ID and grep to find the serial

`udevadm info -a -n /dev/bus/usb/001/012 | grep ATTR{serial}`

![image](https://github.com/user-attachments/assets/c32129b7-ab27-45ba-8421-432050aa6ce5)

sudo nano /etc/udev/rules.d/99-can.rules

SUBSYSTEM=="net", ACTION=="add", ATTR{serial}=="YOUR_SERIAL", NAME="can1"

![image](https://github.com/user-attachments/assets/cdbd87ab-2f2c-4eb9-acbb-eebe42b8abb8)

ctrl X to save and exit, press Y when it asks to save modified buffer, press enter when it asks for the filename to use

`sudo reboot now`

go to your printer.cfg (or whatever .cfg has the required settings) where the MCU section is for your board that is on the second CAN network.
Add `canbus_interface: can1` underneath the canbus_uuid:. This lets Klipper know that this device is on the can1 interface instead of can0.

![image](https://github.com/user-attachments/assets/59afac6b-ef4e-4ad9-a9aa-6eee7023000f)
