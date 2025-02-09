---
layout: default 
title: Multiple CAN Networks
parent: Troubleshooting
---

Credit to @fragmon90's post on the Armored Turtle 3D discord for the framework of these instructions.

# Multiple CAN Networks

Generally there is *no* reason you would need mutiple CAN networks on a single printer. If you have a bunch of different
CAN devices you can just hook them up along the same pair of H/L wires on a single CAN network.

However, if your printer needs to run multiple CAN networks for some reason (maybe you run multiple printers/klipper installs
on the same PC) then it is simple enough to do.

All that is really needed to get a second CAN network is to just connect a second CAN adapter. Usually this would be a USB CAN
adapter like a BigTreeTech U2C, but it doesn't have to be. Anything that would act as a CAN adapter will work, but in the following
instructions I will assume your adapter is connected via USB as it is the most common way and simplifies things.

The next important thing we need to do is make sure that each CAN interface *always* gets applied to the same CAN adapter. If 
you don't specify this then Linux may change which adapter is running which network and that will give you klipper errors.

## Using UDEV to force CAN interface to specific hardware

Connect your first CAN adapter to your printer. We want only one connected at this time so it's easier to get the correct 
hardware IDs and not to get confused.

Run `lsusb` and note down the Bus and Device ID (in the following example it is `Bus 001 Device ID 010`)

![image](https://github.com/user-attachments/assets/979ce265-cedb-48ab-aa13-5c20f61a5f5a)


Then we'll use "udevadm info -a -n /dev/bus/usb/BUS/DEVICE_ID" using the Bus and Device ID you just found, then pipe it
to GREP to find the hardware serial of the device.

`udevadm info -a -n /dev/bus/usb/001/010 | grep ATTR{serial}`

![image](https://github.com/user-attachments/assets/07fed863-dd8a-4097-9c68-36e1c27e496d)

Now that we have the hardware serial ID we will use a udev rule to link this hardware to the can0 interface.

Run:

```bash
sudo nano /etc/udev/rules.d/99-can.rules
```

To create a new udev rules file and add:

SUBSYSTEM=="net", ACTION=="add", ATTR{serial}=="YOUR_SERIAL", NAME="can0"

to the top line (making sure to put in the serial ID you just found)

![image](https://github.com/user-attachments/assets/4e78045a-1667-42d5-b842-35d3f2bef8e9)

Press Ctrl X to save and exit, Then Y when it asks to save modified buffer, then press enter when it asks for the filename to use
(it will already have the correct name).



Now connect the second CAN adapter to your Pi and we'll go through a very similar set of steps.

Run `lsusb` and note down the Bus and Device ID (in the following example it is `Bus 001 Device ID 012`)

![image](https://github.com/user-attachments/assets/aec211b4-6850-4dbc-8353-631f90bd1861)

Run udevadmin info with the Bus and Device ID to find the serial ID

`udevadm info -a -n /dev/bus/usb/001/012 | grep ATTR{serial}`

![image](https://github.com/user-attachments/assets/c32129b7-ab27-45ba-8421-432050aa6ce5)

We will now add this second ID to the same 99-can.rules file you created earlier.

Run:

```bash
sudo nano /etc/udev/rules.d/99-can.rules
```

and add a second line the same as the first line but with your new serial ID and with `NAME="can1"` to link this hardware to the
can1 interface.

SUBSYSTEM=="net", ACTION=="add", ATTR{serial}=="YOUR_SERIAL", NAME="can1"

![image](https://github.com/user-attachments/assets/cdbd87ab-2f2c-4eb9-acbb-eebe42b8abb8)

Press Ctrl X to save and exit, Then Y when it asks to save modified buffer, then press enter when it asks for the filename to use
(it will already have the correct name).

Now just reboot your pi with:

```bash
sudo reboot now
```

and we have now made it so your Pi will *always* link that your can0/can1 interfaces to those specific adapters.

Note, you can just go through these steps again for any number of CAN interfaces if you like, but again the use case for multiple CAN networks is
very niche.

## Change Klipper config

The last thing you need to do is modify your printer.cfg so that Klipper knows which boards
are on the new can1 network instead of the default can0.

Simply edit your printer.cfg (or whatever .cfg has the required settings) where the MCU section is for your board that is on the second CAN network.

Add `canbus_interface: can1` underneath the canbus_uuid:. This lets Klipper know that this device is on the can1 interface instead of can0.

![image](https://github.com/user-attachments/assets/59afac6b-ef4e-4ad9-a9aa-6eee7023000f)
