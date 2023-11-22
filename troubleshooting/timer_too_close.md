This section is still under construction



User had no retransmits/invalids, failed at same point in same gcode when sliced in orca. Worked fine in SS. Ended up being gcode_arc set too low (0.01 vs 0.1)

User had no retrasmits/invalids, using CB1, they determined it'd TTC when CB1 got above 70 degrees. Worked fine under 70.

User had no retrasmits/invalids, would get TTC *sometimes* after print finished. They had 256 usteps on all motors, and in the end_print macro had a move in all X/y/Z planes at F20000. This would overload the system. 

[Return to Troubleshooting](./)
