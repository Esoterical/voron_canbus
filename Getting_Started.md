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

{: .highlight }
>As of the Nov 13 2024 release of RaspiOS, ifupdown is disabled by default and the NetworkManager service doesn't handle canbus interfaces.
>
>To check if you have the service, run `systemctl | grep ifupdown` and you should see the "ifupdown-pre.service" listed.
>
>![image](https://github.com/user-attachments/assets/f4b7dd15-2ee6-44d5-9ad0-8d2a303059e2)
>
>If you don't (or the command returns nothing) *and* you are running RaspiOS, reinstall ifupdown by running `sudo apt-get install ifupdown`
>

Open (or create if it doesn't exist) a file called 'can0` by running:

```bash
sudo nano /etc/network/interfaces.d/can0
```
  ![image](https://user-images.githubusercontent.com/124253477/221327674-fad20589-1a5b-4d68-b2d9-2596553f64ab.png)

And enter the following information:

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
  
# Cabling

There is a high likelyhood that with your changeover to canbus you will also change to some sort of umbilical system for your toolhead. This isn't absolutely necessary, but extremely common. Some boards even come with a premade cable which may or may not work well in cable chains anyway.

Before getting too swept up in what the absolute best gold plated gucci cabling would be for your system, keep the following things in mind. They are the most
important factors when it comes to canbus toolhead board cabling. Nearly every single time someone has issues (after the initial install) it is because a wire has
cracked or connector crimp is failing or similar, so take extra careful to follow these steps:

1. **Good Crimps**

    If you are making your own cable then be extra sure your wire crimps are properly done. A loose crimp can fall off, a bent crimp can crack. And make sure the
    pins are fully seated into the connector housing. Do a pull test to be sure, it's very easy for a pin to look inserted but not actually clicked in and they can
    get pushed out the back during use.
  
    This also applies to premade cables. I've seen some where the H/L connectors get pushed back slightly in the housing, enough that it causes intermittent connection
    issues.
   
2. **Strain Relief**

    No matter what you do **not** want the cable having any sort of movement at/near the connector to the toolhead board. If the wires at those crimp points start 
    moving then it's only a matter of time before they'll crack.

    Have the cable run away from the toolhead for a short distance and then secure it down so no matter what the rest of the umbilical is doing there is no movement
    transmitted directly to the connector.

3. **Flexible Cable**
   
    I know I said not to get worked up about über cables, and that's still true, but also don't go using old solid core mains wiring you ripped from the walls.
    You want the cable/wires to be flexible enough to withstand the constant movement of a printer. That means don't go *too* thick on the wire gauge, and also make
    sure it is decently stranded wire (not 7-strand high current wire).
    
    22AWG or thicker (smaller number is thicker wire) is usually fine for the power wires. The CAN H/L can be thinner, 24 or 26AWG is common, but you can also just 
    do four 22AWG wires or something without trouble as well.

A common method of supporting and strain relieving the umbilcal is to use PG7 glands, and although these work really well they also tend to mean people have to cut
or repin the premade cables that come with some boards. Because of this I prefer using the printable [P.U.G](https://www.printables.com/model/378567-pug-parametric-umbilical-gland) umbilical gland. It does the same job as a PG7 but comes in two halves so you can clamp it over any cable without needing to cut/depin anything.
There are a lot of mods on Printables for mounting a PUG on various printers/toolheads.
   

# Next Step

Now that the can0 interface files are set up, you need to choose how you are going to connect your Pi to the CANBus network.

To actually create a CAN network in your system, your Pi needs some sort of device to act as a CAN adapter (think of it like a USB network card, or USB wifi dongle). The simplest plug-and-play option is to use a dedicated USB to Can device such as the BigTreeTech U2C, Mellow Fly UTOC, Fysetc UCAN, etc. (other devices exist as well). The second "cheaper" option is to actually utilise your printer mainboard (ie. Octopus or Spider board) to function as a usb-can bridge for klipper. We'll cover both options, but you only need to choose one.

[Click here for Dedicated USB-CAN Adapter](./Dedicated_USB_Can_Device.md)

[Click here for USB-CAN-Bridge Klipper on your Mainboard](./USB_CAN_Bridge_Mainboard.md)

