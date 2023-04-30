# Troubleshooting

So, you've followed the instructions but things just aren't working they way they should. Hopefully there will be some nuggets of wisdom here that help out with your build. Note that this page is still very much a work in progress and I will be treating it as a living document. Expect it to be less structured than the rest of the guide, just look around for something that sounds like your problem and see what is there.

There won't be any particular order to the sections. Maybe I'll make it flow better in the future, maybe not.


## No CAN network when running a query or flash attempt

If you run a `python3 ~/CanBoot/scripts/flash_can.py -i can0 -q` or `~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0` or are trying to flash a device with a command like `python3 ~/CanBoot/scripts/flash_can.py -i can0 -u b6d9de35f24f -f ~/klipper/out/klipper.bin` but you are seeing an error along the lines of "unable to bind socket to can0" or "failed to transmit, network is down" then your can0 "interface" on your Pi isn't running.

![image](https://user-images.githubusercontent.com/124253477/235117239-009ab013-d9ba-4524-81d4-a73c8990c2a7.png)

First thing to check is your `/etc/network/interfaces.d/can0` file. Make sure it exists and you have no typos in it.

### Seperate USB-CAN adapter (U2C/UTOC/etc.)

If you are using a seprate USB to CAN adapter (U2C/UTOC/etc.) then double check that the USB cable connecting the devices is plugged in and not loose. If you *never* get a response to a query (ie. the can0 interface has never shown at all) then you may have a dodgy USB cable. I have personally seen a handful of usb-c cables that don't actually have the data pins hooked up (they are power only). If the adapter doesn't show to an `lsusb` then your cable is probably dodgy.

If it shows up to an `lsusb` but an `ip link show can0` shows "Device can0 does not exist" then you might have a bad firmware or something on your device. Reflash it with the appropriate firmware either from a manufacturer github repository or other source (like candlelight). If there are instructions back on the voron_canbus/can_adapter folder then follow those.

### USB-CAN-Bridge mode mainboard

Check that the Pi-to-mainboard USB cable hasn't come loose or anything, and that the mainboard is actually powered up. An `lsusb` should show the mainboard up as a can adapter device. If it's not showing as a can adapter device then do an `ls /dev/serial/by-id`. If you see your mainboard there then either it's still in CanBoot mode, or you haven't flashed usb-can-bridge klipper to it (or the flash didn't take). If that is the case then reflash your mainboard as per the voron_canbus/mainboard_flashing instructions and take extra care that the klipper `make menuconfig` settings are 100% correct for your board.

## No UUIDs show up to a query

So you're can0 interface is online, but a query returns nothing:

![image](https://user-images.githubusercontent.com/124253477/235122048-e39c4fb0-6163-4469-b1fa-aa9dddfe69b2.png)

First up, if you previously *could* see UUID's returned, and then put them into your printer.cfg file, but now you can't see anything from a canbus query **don't panic**. Once a UUID has been "grabbed" by klipper-on-pi then it won't show up to a query. This is normal.

If you haven't put the UUID into your printer.cfg then this means that your method of CAN adapting (standalone adapter or usb-can-bridge mainboard) is running OK but can't see anything on the network. Starting at the adapter end, if you are using a usb-can-bridge mainboard then **double check** that the klipper firmware you flashed had the correct pins set for the CAN network. If you used the wrong pins then the mainboard will boot fine, and even show the can0 interface fine, but will be looking on the wrong pins for CAN traffic and so will never find any other nodes. Note that you should never be able to get into a situation with a usb-can-bridge mainboard where it shows the can0 interface fine but can't find at least its own UUID to a query. 

Next, check the firmware of your toolhead. If you never saw the toolhead canboot or klipper as a UUID at all then **double check** the canboot/klipper firmware for incorrect settings. This could be any setting as even a single incorrect setting on this firmware will either stop the toolhead from booting at all (in which case you won't see it on the network) or it boots but is looking at the wrong CAN pins/has the wrong CAN speed (in which case you also won't see it on the network).

I'm going to assume you are using CanBoot from this point on. If this had the correct settings (which you have double checked) and it flashed OK then we can assume it has booted into Canboot. I would recommend setting a status_led pin in the config (I have outlined the correct pins to use for this in the toolhead_flashing/common_hardware entries) as it will be flashing an LED if it is sitting in CanBoot mode.

If it's sitting in CanBoot but you still can't see a UUID then your problem is likely down to wiring. Check that you have the 120ohm resistor/jumper in at both ends (some mainboards like the Octopus have the resistor prebuilt, no jumper needed). If you hook the CAN wires up, then use a multimeter in resistance mode and measure across the CanH and CanL wires at **one** end (eg. at the maibnoard/adapter end) you should see a resistance of around 60 ohms. This is because you will have two 120ohm resistors in parallel, and this ends up being 60 ohms of resistance (parallel resistor values are a bit weird like that, google it if you don't belive me).

If you see the 60ohms then you know both resistors are in circuit and also your wires are connected (no breaks). If still no UUID then swap your CanH and CanL wires around as this is a *very* common mistake to make.



