---
layout: default 
title: Getting Started 
nav_order: 20
---

# Getting Started

# can0 file, CAN Speeds, and Transmit Queue Length

In order to dictate the speed at which your CAN network runs at you will need to create (or modify) a "can0" file on your Pi. This is what will tell linux "Hey, you now have a new network interface called can0 that you can send CAN traffic over". The approach needed here heavily depends on the network stack of your Pi. Raspbian and older version of Debian typically use ifupdown, but some newer distros (Ubuntu, other single-board-computer distros) use netplan, which by default uses systemd-networkd under the hood. To be safe it's easiest to just follow both the "ifupdown" **and** the "systemd-networkd" instructions. You can have both set up and your Pi will just use the configuration that is relevant to your system.

To set everything up, SSH into your pi and run the commands needed for your network setup:

## ifupdown
```bash
sudo nano /etc/network/interfaces.d/can0
```
  ![image](https://user-images.githubusercontent.com/124253477/221327674-fad20589-1a5b-4d68-b2d9-2596553f64ab.png)

This will open (or create if it doesn't exist) a file called 'can0' in which you need to enter the following information:
```bash
allow-hotplug can0
iface can0 can static
  bitrate 1000000
  up ip link set can0 txqueuelen 1024
```

![image](https://user-images.githubusercontent.com/124253477/221378593-9a0fcdb5-082c-454e-94bd-08a6dc449d34.png)

Press Ctrl+X to save the can0 file.

The "allow-hotplug" helps the CAN nodes come back online when doing a "firmware_restart" within Klipper.
"bitrate" dictates the speed at which your CAN network runs at. Kevin O'Connor (of Klipper fame) recommends a 1M speed for this to help with high-bandwidth and timing-critical operations (ADXL Shaper calibration and mesh probing for example).
To complement a high bitrate, setting a high transmit queue length "txqueuelen" of 1024 helps minimise "Timer too close" errors.

Once the can0 file is created just reboot the Pi with a `sudo reboot` and move on to the next step.

## systemd-networkd (netplan)
```bash
sudo nano /etc/systemd/network/10-can.link
```
This will open (or create if it doesn't exist) a file called `10-can.link` in which you need to enter the following information:
```bash
[Match]
Type=can

[Link]
TransmitQueueLength=1024
```
Press Ctrl+X to save the file.

To set the bitrate, we need to create another file in the same directory:
```bash
sudo nano /etc/systemd/network/25-can.network
```
This creates a network file, that networkd will then use to automatically set up the network with. Because of how networkd works, "hotplugging" is baked in.
Enter the following in the network-file and close it with Ctrl+X:
```bash
[Match]
Name=can*

[CAN]
BitRate=1M
```
  
# 120R Termination Resistors

A CANBus expects both ends of the CanH/CanL wire run to be terminated with a 120 ohm resistor bridging the High and Low wires. Your CAN board will almost certainly have provisions for this somewhere.

**Note**

You want to have **two** of these termination resistors in your CANBus circuit. **No more, No less**. Running with too many connected can be just as bad as running with none.

Now, ideally these resistors are placed at the very start and end of your CAN network, but in reality the scale we are working with on 3d printers is so small compared to what CANBus is designed for it ends up not really mattering in practice.

If you only have a single USB CAN adapter (or usb-can-bridge mainboard) and a single toolhead, then just have the 120R on each. If you are running multiple toolheads (eg. in an IDEX setup) running back to the same source (eg. a U2C), then have the jumpers on each toolhead and **not** on the "source" board.

If your setup is all randomly connected, then just pick the two "most edge" boards in the system to have the 120 ohm resistors on.

## CAN Adapter/Mainboard

Some boards (Like the BTT Octopus) have the 120 ohm resistor permenantly connceted across the CanH/L wires, so nothing you need to do there. Others will have a two-pin header (sometimes labelled "120R") that you can put a jumper on and this will bring the termination resistor into the circuit.

The same can be said for dedicated USB CAN adapters (like the U2C). Most will have a a header that you can put a jumper on to enable the resistor.

You can find information and diagrams on the 120 ohm termination resistor placement for boards in the [mainbard common hardware](./mainboard_flashing/common_hardware) section.

## Toolhead

Nearly all Toolheads will have a two-pin header (sometimes labelled 120R) that you can put a jumper on to bring the 120 ohm resistor into the circuit.

You can find information and diagrams on the 120 ohm termination resistor placement for boards in the [toolhead common hardware](./toolhead_flashing/common_hardware) section.
  

# Next Step

Now that the can0 interface files are set up, you need to choose how you are going to connect your Pi to the CANBus network.

To actually create a CAN network in your system, your Pi needs some sort of device to act as a CAN adapter (think of it like a USB network card, or USB wifi dongle). The simplest plug-and-play option is to use a dedicated USB to Can device such as the BigTreeTech U2C, Mellow Fly UTOC, Fysetc UCAN, etc. (other devices exist as well). The second "cheaper" option is to actually utilise your printer mainboard (ie. Octopus or Spider board) to function as a usb-can bridge for klipper. We'll cover both options, but you only need to choose one.

[Click here for Dedicated USB-CAN Adapter](./Dedicated_USB_Can_Device.md)

[Click here for USB-CAN-Bridge Klipper on your Mainboard](./USB_CAN_Bridge_Mainboard.md)

