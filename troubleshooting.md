---
layout: default 
title: Troubleshooting
nav_order: 80
has_children: true
has_toc: false
---

# Troubleshooting

So, you've followed the instructions but things just aren't working they way they should. Hopefully there will be some nuggets of wisdom here that help out with your build. Note that this page is still very much a work in progress and I will be treating it as a living document. Expect it to be less structured than the rest of the guide, just look around for something that sounds like your problem and see what is there.

There won't be any particular order to the sections. Maybe I'll make it flow better in the future, maybe not.

### No can0 network when flashing

If you see something like "unable to bind socket to can0" when attempting to flash, read [here](./troubleshooting/no_can0.md)


### No UUIDs show up to a query

So you're can0 interface is online, but a query returns no UUIDs? read [here](./troubleshooting/no_uuid.md)


### Klipper won't start

You have everything flashed fine, and the UUID's all showed up, but klipper refuses to start, read [here](./troubleshooting/klipper_fail_to_start.md)


### Timeout during homing/probing

Klipper starts, but sometimes during a homing command or levelling/bed mesh Klipper will halt with "Timeout during homing/probing", read [here](./troubleshooting/timeout_during_homing_probing.md)

### Lost connection to MCU

Klipper was running, maybe even printing for a while, but all of a sudden it failed mid print with "Lost connection to MCU" error, read [here](./troubleshooting/lost_communication_to_mcu.md)


### Timer too close

Sometimes it prints fine, sometimes it fails with "Timer too close" error, read [here](./troubleshooting/timer_too_close.md)


### TMC Driver reset/undervoltage

If your extruder TMC driver is reporting "reset" or undervoltage errors, read [here](./troubleshooting/tmc_reset_undervoltage.md)

## Other Errors and Reading the Log

If you have errors not previously mentioned then it is worth learning to check your klippy.log file [here](./troubleshooting/other_errors.md)
