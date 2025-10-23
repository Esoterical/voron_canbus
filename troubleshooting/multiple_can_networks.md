---
layout: default 
title: Multiple CAN Networks
parent: Troubleshooting
---

Credit to Fragmon (find them on youtube at [https://youtube.com/@crydteamprinting](https://youtube.com/@crydteamprinting)) for their help with the following instructions.
Also credit to willpuckett for the klipper discourse post [https://klipper.discourse.group/t/setting-up-udev-rules-for-multiple-canbus-interfaces/16211] for a cleaner implementation.

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

On a standard system the first CAN adapter will show up as the can0 interface. Check this by running `ip a` and you
should see the can0 network interface showing. If you don't then you will need to sort that out first using the
earlier sections of this guide.

<img width="848" height="308" alt="image" src="https://github.com/user-attachments/assets/0ad4af8d-4709-45c6-8dc8-0515a831ccbc" />



So to get the hardware serial you run:

```bash
udevadm info -a -p $(udevadm info -q path -p /sys/class/net/can0)| grep serial| head -n 1
```

<img width="858" height="54" alt="image" src="https://github.com/user-attachments/assets/24219771-d0be-4842-83a3-25f7bde25901" />

It will give you something like

`ATTRS{serial}=="110032000D51323532393433"`

This is the hardware ID we will use to "lock" can0 to this specific adapter.

## Create UDEV rule to link hardware ID to CAN interface

Now that we have the hardware serial ID we will use a udev rule to link this hardware to the can0 interface.

Run:

```bash
sudo nano /etc/udev/rules.d/99-can.rules
```

to create a new udev rules file and add:

```bash
SUBSYSTEM=="net", ACTION=="add", ATTRS{serial}=="YOURSERIAL", NAME="can0"
```

to the top line (making sure to put in the serial ID you just found)

<img width="780" height="61" alt="image" src="https://github.com/user-attachments/assets/9d4bc365-c185-4301-a51a-23899f1dfa1a" />


Press Ctrl X to save and exit, Then Y when it asks to save modified buffer, then press enter when it asks for the filename to use
(it will already have the correct name).


## Repeat steps for second CAN adapter

Now connect the second CAN adapter to your Pi and we'll go through a very similar set of steps.

Then run

```bash
ip a
```

to check that this second CAN Adapter is now showing as the `can1` interface.

Then get the hardware serial of this can1 adapter

```bash
udevadm info -a -p $(udevadm info -q path -p /sys/class/net/can1)| grep serial| head -n 1
```

and then you can add this hardware serial to the 99-can.rules file by running

```bash
sudo nano /etc/udev/rules.d/99-can.rules
```

and adding a second line the same as the first one but with this different hardware ATTRS{serial} value
and with `NAME="can1"` at the end

<img width="768" height="99" alt="image" src="https://github.com/user-attachments/assets/089810a4-7090-4334-b60e-6f63f614de9a" />


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
