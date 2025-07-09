---
layout: default 
title: Timer Too Close
nav_order: 60
parent: Troubleshooting
---

# Timer Too Close

This error tends to be a "catch all" for a bunch of different causes. It can often be caused by the Pi itself getting overloaded (or overheating and throttling), or the mcu in question (toolhead/mainboard/whatever) also getting overloaded. Or a different thing entirely.

Some things to check:

## Pi CPU load

There's always the possibility of a rogue process on your Pi hogging the CPU cycles and not leaving much space left for klipper tasks. This is something that is generally hard to spot unless it is *really* obvious
(like a bad klipperscreen process stuck at 90% CPU or whatever), but something I like to do is use `htop` to get a view of the currently running processes and just seeing if anything looks particularly wrong. Pressing
`F6` then choosing the PERCENT_CPU option in the "Sort By" sidebard helps sort the list from highest CPU usage to lowest.

![image](https://github.com/user-attachments/assets/cc61761f-2e5b-4adc-a9f3-9744af4a8b87)

## LED Effects

Another common resource hog that can use up cycles on both the Pi *and* the MCU is the LED Effects plugin. The one that lets your neopixels do the funky breathing/pulsing effects. Because Klipper uses bit-banging in
order to send neopixel commands once you start trying to send animation effects at 12fps or whatever the load on the MCU really adds up. So if you are getting TTC errors and have the LED Effects plugin installed it's
best to just [uninstall it](https://github.com/julianschill/klipper-led_effect?tab=readme-ov-file#uninstall) to see if it helps with the error.

## Anecdata

Because the problems are so many I'm just going to start cataloguing real-world examples of where users have had TTC errors and what the cause ended up being.

This section will be expanded as I add more examples.


`User had no retransmits/invalids, failed at same point in same gcode when sliced in orca. Worked fine in SS. Ended up being gcode_arc set too low (0.01 vs 0.1)`

`User had no retrasmits/invalids, using CB1, they determined it'd TTC when CB1 got above 70 degrees. Worked fine under 70.`

`User had no retrasmits/invalids, would get TTC *sometimes* after print finished. They had 256 usteps on all motors, and in the end_print macro had a move in all X/y/Z planes at F20000. This would overload the system. `


`KAMP running at the printer.cfg max velocity (which it does by default) caused TTCs when user had max velocity set quite high (1k mm/s). Issue didn't show up when running Ellis test_speed macro though even at >1k mm/s. MAybe a combo of X,Y, and Z movement, or maybe extruder movement as well. Fixed by lowering printer.cfg max velocity, or changing the KAMP settings to use a lower travel_speed.
They also observed this problem was more likely on short distances (IE smaller print). "I believe the acceleration to quick deceleration or transition from KAMP to actual print can cause this when moving at very very high speeds."`

`I can't remember the specifics on this one, but a bad/dying SD card can definitely cause TTC errors as well as the base linux system starts freaking out/having errors and this extra load transferrs into messing with klipper`

`Seemingly random TTC's, SD card was full`

`TTC when Exclude Object was used on a large/complex model. Possibly the host overloaded trying to skip the bazillion lines of gcode`

[Return to Troubleshooting](../troubleshooting.md)
