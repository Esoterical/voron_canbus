---
layout: default 
title: Updating
has_children: true
nav_order: 70
has_toc: false
---

# Updating

![captain_update](https://github.com/Esoterical/voron_canbus/assets/124253477/2b35e7a5-d2b7-4f50-9db7-5e4202ad85ed)


Did you update the Klipper on your Pi, and now it is yelling at you about MCU version being out of date? Or maybe you just want to update the firmware on your boards for the latest features (or fixes). Either way, just follow these steps and it should be pretty painless.

Before doing anything, you need to pull the latest Katapult down from Git so just so all the following tools are *definitely* available. You may already have the latest Katapult stuff, but running the Git commands again won't hurt.

```bash
test -e ~/katapult && (cd ~/katapult && git pull) || (cd ~ && git clone https://github.com/Arksine/katapult) ; cd ~
```

This command will download Katapult from github if you don't already have it, or it will update it to the latest if you do already have it.

If during the following steps you see "Application:CanBoot" instead of "Application:Katapult" then don't worry, Canboot was just renamed to Katapult but all the Katapult tools/queries will still "talk" to Canboot perfectly fine. You don't need to update a working CanBoot bootloader.

If you only have a CAN Toolhead (ie. if you are running a USB Canbus adapter like a U2C or a UTOC) then go straight [here](./toolhead_updating.md).

If you have a mainboard running USB-CAN-Bridge mode klipper, go to [here](./mainboard_updating.md)
