---
layout: default 
title: Termination Resistor Info
parent: Troubleshooting
---

# Termination Resistor Info

The 120 ohm termination resistors facilitate two different jobs in a CANBus system. 
The first is that they provide the proper resistance for the CAN Transceivers to be able to pull the signal high/low.
The second is that they are there to mitigate reflections when the signal hits the "end" of the wire.

Ideally, the 120ohm resistors will be at the physical "ends" of the CAN cable, and each node will be direcly "on" this main cable in a nice straight line. This thinking has caused much
confusion for users, especially as their CAN setups get more complicated than a single toolhead.

For example: In a system that has a U2C CAN adapter in the electronics bay, a CAN toolhead board on the toolhead, and a CAN control board on a ERCF situated outside of the printer.
In this case, it is simple enough to have a CAN cable going from U2C to toolhead, and another going from U2C to ERCF, and have the 120r resistor/jumper in place on the toolhead 
and on the ERCF board, but *not* on the U2C. This gives a nice standard "resistor on each end" setup.

But what about a system with more boards like a toolchanger setup? Or what if instead of a U2C you are using an Octopus mainboard as the CAN adapter, and the Octo has a hardwired 120
ohm resistor that *can't* be removed.

This is where reality hits.

At the end of the day, our printers are *tiny* compared to what a CANBus system is usually used for. This means we have a lot of wiggle room when it comes to things like termination 
resistor placement and wiring quality and component choices etc.

## Transceiver fuctionality 

For a printer, the biggest impact of an incorrect amount of termination resistors is actually around the ability of the CAN transceviers to generate a signal. These transceivers are 
"expecting" the circuit to have around 60 ohms of impedence (which two 120ohm resistors in parallel ends up being). 

If you have **no** resistors at all, then the transceivers can't really pull the signal high or low and in all likelyhood nothing will work.

If you have **one** resistor in the circuit, you *may* find that the system works simply because of the small scale we are on. It's not ideal, but there have been plenty of instances
of a printer functioning even though the user has forgotten one of the termination resistor jumpers.

If you have **two** resistors in the circuit, gold star, this is what we want.

If you have **more than** two resistors things start going bad again. Each additional resistor is lowering the overall impedance (the more resistors in parallel, the lower the effective resistance)
so from the transceivers point of view it's looking more and more like a short circuit, and they won't function like this. You *might* get away with 3 resistors, but that's not guaranteed.
Definitely won't work with 4+.

## Signal Reflections

As stated before, the main factor with the use of 120ohm resistors **in the context of a 3d printer** is how it affects the CAN Transceivers, but the other side is mitigating signal reflections
in the wire. This is what most people think of when talking about these termination resistors, and in a long CAN cable (like in a car or heavy machinery) it is indeed the primary concern. But
for the small maybe-3-meters runs of a printer it's almost negligable.

So if you have a printer with a "complicated" topography, like a 5 toolhead toolchanger setup, simply aim for "good enough" in where you put your resistors/jumpers.
For a toolchanger setup, I'd tie all the tools back to a common spot (like on the gantry or frame) and put a 120ohm jumper/resistor here, then run a single cable back to the electronics bay and put
the other resistor on the CAN adapter/mainboard.

Or for a setup where there are hardwired resistors in "not optimal" locations, like an Octopus mainboard with a hard wired resistor in the middle of both a toolhead and an ERCF board, simply 
put one other termination resistor/jumper on one of the other devices (usually the toolhead, but might also be worth picking the one that has the longest physcial CAN cable run).

