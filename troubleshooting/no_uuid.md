---
layout: default 
title: No UUID
nav_order: 20
parent: Troubleshooting
---


So you're can0 interface is online, but a query returns nothing:

![image](https://user-images.githubusercontent.com/124253477/235122048-e39c4fb0-6163-4469-b1fa-aa9dddfe69b2.png)

First up, if you previously _could_ see UUID's returned, and then put them into your printer.cfg file, but now you can't see anything from a canbus query **don't panic**. Once a UUID has been "grabbed" by klipper-on-pi then it won't show up to a query. This is normal.



### Firmware

If you haven't put the UUID into your printer.cfg then this means that your method of CAN adapting (standalone adapter or usb-can-bridge mainboard) is running OK but can't see anything on the network. Starting at the adapter end, if you are using a usb-can-bridge mainboard then **double check** that the klipper firmware you flashed had the correct pins set for the CAN network. If you used the wrong pins then the mainboard will boot fine, and even show the can0 interface fine, but will be looking on the wrong pins for CAN traffic and so will never find any other nodes. Note that you should never be able to get into a situation with a usb-can-bridge mainboard where it shows the can0 interface fine but can't find at least its own UUID to a query.

Next, check the firmware of your toolhead. If you never saw the toolhead Katapult or klipper as a UUID at all then **double check** the Katapult/klipper firmware for incorrect settings. This could be any setting as even a single incorrect setting on this firmware will either stop the toolhead from booting at all (in which case you won't see it on the network) or it boots but is looking at the wrong CAN pins/has the wrong CAN speed (in which case you also won't see it on the network).

I'm going to assume you are using Katapult from this point on. If this had the correct settings (which you have double checked) and it flashed OK then we can assume it has booted into Katapult. I would recommend setting a status_led pin in the config (I have outlined the correct pins to use for this in the toolhead_flashing/common_hardware entries) as it will be flashing an LED if it is sitting in Katapult mode.




### Wiring

If it's sitting in Katapult but you still can't see a UUID then your problem is likely down to wiring. (Thanks to @drachenkaetzchen for the much better writeup than my original one)

- First thing **Shut down the Pi with `sudo shutdown now` and then power off the whole printer. There needs to be no power before testing further.** 

- Each side of the CAN Bus needs the 120 Ohm resistor in place. Ensure you got the appropriate jumpers set. The Octopus is an exception, it has no jumper, the 120 Ohm resistor is always present.

- For all following measurements, your printer must be powered off.

- Ensure using a multimeter in continuity mode that CAN_L from one side actually ends up on CAN_L on the other side. Same for CAN_H. Remove all termination resistors for that. If one of your boards has a fixed       120 Ohm resistor, remove the jumper on the other board. Then use your multimeter in Ohms mode to measure from one side to the other, you should read close to 0 ohms. If you read 120 Ohms, you probably have         swapped CAN_L and CAN_H

- With everything connected, measure resistance between CAN_L and CAN_H. You should read 60 Ohms (2x 120 Ohm in parallel = 60 Ohms). If you get 120 Ohm, then there might be a break in the wire or you forgot to set   the jumper

- If you suspect that CAN_L or CAN_H might be broken, measure in resistance mode (not continuity!) between CAN_L on one board with CAN_L on the other board. If you get 240 Ohms, then there's a break in CAN_L.       Repeat the measurement for CAN_H

- Some users have encountered issues despite following the guide guide here. Everything seemed fine until attempting to flash Klipper on the SB2209. They could locate the board in DFU mode over USB, but the CAN UUID wasn't visible. Consequently, they were unable to flash Klipper onto the SB2209. It was discovered that the CAN wire provided with the BTT EBB SB2209 had the high and low data wire colors swapped compared to the picture in their documentation. By swapping the high and low data wires in the adapter, they were able to locate the CAN signal and successfully flash Klipper on the SB2209.

### can0 Interface

There are guides floating around on the internet (I can't find them now but I swear I've seen them in the past) that instruct users to add post-boot tasks to modify the CAN speed or txqueuelen to something different than is stated in the `/etc/network/interfaces.d/can0` file. If your firmware/wiring/everything looks fine yet you still can't get a UUID then this is a good thing to check.

To test this hypothisis, make sure you are **absolutely sure** of the CAN speed you set when compiling the katapult/klipper firmware for your device (if you are using this guide then that will be one million, 1000000) then run the following commands to manually take down the can0 interface then bring it back up with the "known correct" speed

To **stop** the can0 interface:

`sudo ip link set can0 down type can`

To **start** the can0 interface (replace the bitrate to whatever you are using if it isn't 1000000)

`sudo ip link set can0 up type can bitrate 1000000`

To confirm the network is back up and running at the correct speeds run `ip -details -statistics link show can0` and look for the following:

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/62ad3926-8524-4e73-a8db-130893908799)

If it looks good then re-run a canbus query to see if the UUID shows up now.

If your UUIDs show up then reboot the printer and check again. If they now *don't* show up then you probably have one of these post-boot script things interfering. 
Usually it is in the rc.local file. Run:

`sudo nano /etc/rc.local`

and if you see any lines referecing "can0" then put a # at the start of the line to comment it out (or delete the whole line), then reboot and canbus query once again. Hopefully it's all good at this point.

If the rc.local file *isn't* the problem, but you still get post-boot no UUIDs but you *do* get UUIDs after manually setting the can0 speed with the commands, then the overriding "script" is somewhere else. As linux has a bunch of different ways to change settings after a boot it is hard to cover all of them here. Just take the information you have now figured out (something is changing my can0 speed afterboot, it isn't the rc.local file) and ask your favourite helpers/discord channels/forums/wherever.

[Return to Troubleshooting](./)
