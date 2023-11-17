# Lost Communication to mcu

So you're happily printing, everythings great, you're thinking "oh, this whole CANbus thing is easy" when all of a sudden your print stops with an error `Lost communication with MCU 'EBBCan'` or similar (whatever your CAN toolhead name is). You restart, it works fine again but sooner or later it happens again. Or maybe after the first time you can't even get klipper to start again as it just can't connect to your toolhead UUID.

This is almost always a wiring loss problems. A way to confirm is to check your logs. Download your klippy.log from when the error happened, then do a "Ctrl F" search for "lost communication" and find the one that is closes to the bottom of your log file (ie. the latest one that occurred).

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/b0f887be-dc0a-4a2a-858f-c30d96fd00bd)

Once you've found it, look just aove it at the `Stats:` lines. Scroll across until you find hte `bytes_retransmit` entries. There will be one of these for each MCU in your system, so the first one is your mainboard (octpus or whatever) which *probably* is fine, then further along you will find the entries for your CAN toolhead.

What you are looking for is a sudden jump in the retransmits. Maybe it was at 0 for ages, or maybe it would have small jumps but sit at that for long periods of time. Either way what you are looking for is if there was a sudden jump right before the "lost communication" error:

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/2daa62db-9c94-4ddc-8794-f8f1d5b74376)

This is a pretty solid indication of the toolhead losing communcation with the pi from a wiring problem. Could be a broken wire, could be a crimp in a connector going bad. It may be on the 24v or Ground wire or, or it may be the CanH or CanL communcation wires. Either way, your Pi has lost the signal to yuor toolhead.

The only way around it is to go through and check all your wires. Thies is sometimes obvious (a broken wire in a cable chain) othertimes not (a "partially" broken crimp inside a molex connector) but it'll likely be somewhere. Just keep digging around.

Before you say "I've checked and it all looks good, it must be something else" just remember that it doesn't take much of a break for the connection to drop out:

![broken_wire](https://github.com/Esoterical/voron_canbus/assets/124253477/d5d466cf-27af-48b7-93f0-62a8991b784a)


[Return to Troubleshooting](./)

