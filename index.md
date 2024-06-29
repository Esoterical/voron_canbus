---
title: Home
layout: home
nav_order: 1
---


Before we start a big thanks has to go to the #can-and-usb_toolhead_boards thread on the Voron discord. A wealth of information from some very clever people.
Plus a specific thanks to @MastahFR and @eschlenz for their [early](https://github.com/akhamar/voron_canbus_octopus_sb2040) [canbus](https://github.com/eschlenz/3D-Printing-Public/blob/main/skr_pico_canboot_canbus.md) guides, and @EricZimmerman for his still-very-relevant [BTT U2C and EBB36](https://github.com/EricZimmerman/VoronTools/blob/main/EBB_CAN.md) guide.

And a huge thanks to @dormausian who was instrumental in lifting this just-a-github page into an actual website.

## Generalised CANBus guide

So you want to use Canbus on your printer? There are plenty of guides around but usually they are guides on a specific hardware configuration. This guide hopes to generalise some of the steps to help anyone get started on their CAN journey with a printer.

Note: This will be generally structured around Voron printers and common hardware for a Voron printer, but you can take the information to any Klipper-based printer as long as you either use the same electronics (mainboard/canboard) or use this guide to adapt to your specific electronics (if they are supported).

So let's get started.


# Basic Structure of a 3d Printer CANBus

In all likelyhood you are looking to hook up a single CAN toolhead board to your printer to minimise wiring from mainboard to toolhead, so that is the setup we'll be focusing on.
In order to achieve a functioning CAN network on your printer you need 3 things: A computer running the main Klipper software (usually a Raspberry Pi, but anything with a USB port will work for this guide), a CAN network adapter (either a standalone USB device or running a compatible mainboard in klipper's usb-can bridge mode) and a CAN node (the toolhead device). This is also the order in which you need to set things up. No point setting everything up on the toolhead CAN board if you don't have a way for the Pi to talk to it.
We are going to assume you have a functioning Pi (or equivalant) running linux and already have Klippper, Moonraker, some sort of GUI (Fluidd/Mainsail/Octoprint), and you have the ability to SSH into it.

Please note that whenever you see "Pi" or "RPi" in this guide you should substitute it for whatever computer you are running Klipper on (Raspberry Pi, Orange Pi, CB1, BTT Pi, old laptop etc). For example, if the guide says "plug the USB into the Pi", and you have an old laptop doing this job, then plug the USB into your old laptop.
Also note that integrated boards like the BTT Manta series that have a CM4/CB1/CB2 module *on* the mainboard itself, then any Pi connections (usb, etc) would actuallly be on the Manta/Mainboard, and not the Pi/Computer board.

# Regarding Katapult (formerly known as CanBoot)

You may have seen other guides have installing Katapult/CanBOOT onto devices as a first step. Katapult is a custom firmware and allows flashing of Klipper to the devices via the CAN network so you don't have to plug a USB cable in each time to flash/update klipper. Katapult is really handy but it is ***NOT*** mandatory. This will be discussed later, but Klipper will happily run over a CAN network with or without Katapult.


#  Your main CAN network adapter

To actually create a CAN network in your system, your Pi needs some sort of device to act as a CAN adapter (think of it like a USB network card, or USB wifi dongle). The simplest plug-and-play option is to use a dedicated USB to Can device such as the BigTreeTech U2C, Mellow Fly UTOC, Fysetc UCAN, etc. (other devices exist as well). The second "cheaper" option is to actually utilise your printer mainboard (ie. Octopus or Spider board) to function as a usb-can bridge for klipper. We'll cover both options, but you only need to choose one.


# Checkpoints

Throughout this guide you will notice stop signs:

<p align="center">
  <img src="https://github.com/Esoterical/voron_canbus/assets/124253477/36065239-009c-4195-8e13-a43959acac7b" />
</p>

These denote sections where you need to do a final check before proceeding. If you do not get the same results as outlined in these STOP sections, *do not* go further. Continuing on to subsequent sections when the section you are on isn't set up correctly will just either not work or cause confusing issues.


# New build

If this is a fresh build click [here](./Getting_Started.md) to start your journey.

# Updating

If you are just updating an existing already-working CANBus system, click [here](./Updating.md) for steps on how to update the firmware on your boards.

# HELP!

If you are just getting stuck, or you had a working CANBus system that is now not working, have a look at the [troubleshooting section](./troubleshooting.md) for information that may help.




