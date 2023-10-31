
So you're can0 interface is online, but a query returns nothing:

![image](https://user-images.githubusercontent.com/124253477/235122048-e39c4fb0-6163-4469-b1fa-aa9dddfe69b2.png)

First up, if you previously _could_ see UUID's returned, and then put them into your printer.cfg file, but now you can't see anything from a canbus query **don't panic**. Once a UUID has been "grabbed" by klipper-on-pi then it won't show up to a query. This is normal.

If you haven't put the UUID into your printer.cfg then this means that your method of CAN adapting (standalone adapter or usb-can-bridge mainboard) is running OK but can't see anything on the network. Starting at the adapter end, if you are using a usb-can-bridge mainboard then **double check** that the klipper firmware you flashed had the correct pins set for the CAN network. If you used the wrong pins then the mainboard will boot fine, and even show the can0 interface fine, but will be looking on the wrong pins for CAN traffic and so will never find any other nodes. Note that you should never be able to get into a situation with a usb-can-bridge mainboard where it shows the can0 interface fine but can't find at least its own UUID to a query.

Next, check the firmware of your toolhead. If you never saw the toolhead Katapult or klipper as a UUID at all then **double check** the Katapult/klipper firmware for incorrect settings. This could be any setting as even a single incorrect setting on this firmware will either stop the toolhead from booting at all (in which case you won't see it on the network) or it boots but is looking at the wrong CAN pins/has the wrong CAN speed (in which case you also won't see it on the network).

I'm going to assume you are using Katapult from this point on. If this had the correct settings (which you have double checked) and it flashed OK then we can assume it has booted into Katapult. I would recommend setting a status_led pin in the config (I have outlined the correct pins to use for this in the toolhead_flashing/common_hardware entries) as it will be flashing an LED if it is sitting in Katapult mode.

If it's sitting in Katapult but you still can't see a UUID then your problem is likely down to wiring. Check that you have the 120ohm resistor/jumper in at both ends (some mainboards like the Octopus have the resistor prebuilt, no jumper needed). If you hook the CAN wires up, then use a multimeter in resistance mode and measure across the CanH and CanL wires at **one** end (eg. at the mainboard/adapter end) you should see a resistance of around 60 ohms. This is because you will have two 120ohm resistors in parallel, and this ends up being 60 ohms of resistance (parallel resistor values are a bit weird like that, google it if you don't belive me).

If you see the 60ohms then you know both resistors are in circuit and also your wires are connected (no breaks). If still no UUID then swap your CanH and CanL wires around as this is a _very_ common mistake to make.

If you only see 120ohms and you are **sure** the jumpers are in both ends, then you have a break in your CAN wire(s). Broken wire, or bad crimp, or a pin not seated in a connector properly. Either way, you need to check your wires again.


[Return to Troubleshooting](./)
