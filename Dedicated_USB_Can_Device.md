---
layout: default 
title: Dedicated USB CAN Device
has_children: true
has_toc: false
nav_order: 30
---

# Dedicated USB CAN device

If you want to use a dedicated USB CAN devcice, then it should be as  simple as plugging it in to your Pi via USB. ***You shouldn't have to flash anything to this U2C/UTOC/etc device first, they are meant to come pre-installed with the necessary firmware. They do NOT run Klipper***. You can test if it is working by running an `lsusb` command (from an SSH terminal to your pi). Most common USB CAN devices will show up as a "Geschwister Schneider CAN adapter" when they are working properly (though some may simply show as an "OpenMoko, Inc" device):

![image](https://user-images.githubusercontent.com/124253477/221329262-d8758abd-62cb-4bb6-9b4f-7bc0f615b5de.png)

![image](https://user-images.githubusercontent.com/124253477/222042688-10fa6fdb-8c0a-4142-8c40-0d93ef4fc4bd.png)


A better check is by running `ip -s -d link show can0` . If everything is correct you will see something like this:

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/1c1c807f-5654-44fb-b0a9-c59e3e43f60a)

You see a can0 interface, the "qlen" will be 1024, and the bitrate will be 1000000


{: .stop }
>
><p align="center">
>  <img src="https://github.com/Esoterical/voron_canbus/assets/124253477/36065239-009c-4195-8e13-a43959acac7b" />
></p>
>
>If the `ip -s -d link show can0` command returns an error then go back to ths top of this page and check that your USB CAN adapter is properly showing up to an `lsusb` command.
>
>If the can0 network shows up, but the qlen *isn't* 1024 or the bitrate *isn't* 1000000 then go back to [Getting_Started](./Getting_Started.md) and check the can0 file settigns in both the ifupdown section and the netplan section.



**A note on edge cases**

If you plug in your USB CAN adapter and you *don't* see the expected results from an `lsusb`, then the firmware on your device may have issues. If this is the case then it's worth going to the Github page of your device as they usually have the stock firmware and flashing instructions there.

**A note on the note**

The BTT U2C V2.1 was released with bad firmware which although would show up to the above tests it would make issues show up down the line. If you have a v2.1 of the U2C then please follow [these instructions](./can_adapter/BigTreeTech%20U2C%20v2.1/README.md) to update it.


# Next Step

Once you have confirmed you can see your can0 interface, continue [here](./toolhead_flashing) for instructions on flashing your toolhead for use with Canbus.
