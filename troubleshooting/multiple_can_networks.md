---
layout: default 
title: Multiple CAN Networks
parent: Troubleshooting
---

Credit to Fragmon (find them on youtube at [https://youtube.com/@crydteamprinting](https://youtube.com/@crydteamprinting)) for their help with the following instructions.

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

## Finding the Hardware Serial of your CAN Adapter

Connect your first CAN adapter to your printer

We want only **one** connected at this time so it's easier to get the correct hardware IDs and not to get confused.

Run `lsusb` and note down the Bus and Device ID. For example, if your device is on `Bus 001 Device ID 010` then note down the values 
001 and 010

![image](https://github.com/user-attachments/assets/979ce265-cedb-48ab-aa13-5c20f61a5f5a)


Then we'll use "udevadm info -a -n /dev/bus/usb/BUS/DEVICE_ID" using the Bus and Device ID you just found, then pipe it
to GREP to find the hardware serial of the device.

```bash
udevadm info -a -n /dev/bus/usb/001/010 | grep ATTR{serial}
```

![image](https://github.com/user-attachments/assets/07fed863-dd8a-4097-9c68-36e1c27e496d)

{: .note }
>If you aren't seeing any serial number using the above command, you can try searching by ATTRS{serial} instead of ATTR{serial}
>
> `udevadm info -a -n /dev/bus/usb/001/010 | grep ATTRS{serial}`
>
>The difference:
>
>ATTR{serial} checks only the current device level.
>
>ATTRS{serial} searches higher levels in the device hierarchy (e.g., USB hubs or controllers).
>
>If your adapter is part of a multi-interface device or connected via a hub, the serial might be stored on a higher level, requiring ATTRS{serial}.

## Create UDEV rule to link hardware ID to CAN interface

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


## Repeat steps for second CAN adapter

Now connect the second CAN adapter to your Pi and we'll go through a very similar set of steps.

Run `lsusb` and note down the Bus and Device ID (in the following example it is `Bus 001 Device ID 012`)

![image](https://github.com/user-attachments/assets/aec211b4-6850-4dbc-8353-631f90bd1861)

Run udevadmin info with the Bus and Device ID to find the serial ID

```bash
udevadm info -a -n /dev/bus/usb/001/012 | grep ATTR{serial}
```

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

{: .note }
>Also take note that any time you need to run the katapult flashtool.py tool you will need to include the parameter `-i can1` 
>in your command string for any device that is on the can1 network.
>
>eg. `~/katapult/scripts/flsahtool.py -u a145c2b0d6d7 -r -i can1`
