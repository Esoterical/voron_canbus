# Timer Too Close

This error tends to be a "catch all" for a bunch of different causes. Because the problems are so many I'm just going to start cataloguing real-world examples of where users have had TTC erros and what the cause ended up being.

This section will be expanded as I add more examples.


`User had no retransmits/invalids, failed at same point in same gcode when sliced in orca. Worked fine in SS. Ended up being gcode_arc set too low (0.01 vs 0.1)`

`User had no retrasmits/invalids, using CB1, they determined it'd TTC when CB1 got above 70 degrees. Worked fine under 70.`

`User had no retrasmits/invalids, would get TTC *sometimes* after print finished. They had 256 usteps on all motors, and in the end_print macro had a move in all X/y/Z planes at F20000. This would overload the system. `


`KAMP running at the printer.cfg max velocity (which it does by default) caused TTCs when user had max velocity set quite high (1k mm/s). Issue didn't show up when running Ellis test_speed macro though even at >1k mm/s. MAybe a combo of X,Y, and Z movement, or maybe extruder movement as well. Fixed by lowering printer.cfg max velocity, or changing the KAMP settings to use a lower travel_speed.
They also observed this problem was more likely on short distances (IE smaller print). "I believe the acceleration to quick deceleration or transition from KAMP to actual print can cause this when moving at very very high speeds."`

`I can't remember the specifics on this one, but a bad/dying SD card can definitely cause TTC errors as well as the base linux system starts freaking out/having errors and this extra load transferrs into messing with klipper`

[Return to Troubleshooting](./)
