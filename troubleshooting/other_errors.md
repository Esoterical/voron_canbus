---
layout: default 
title: Other Errors
parent: Troubleshooting
---

# Reading your klippy.log

If you happen to be having errors such as "Timer Too Close" or "Missed Scheduling of next digital out event" or something like that (ie. something that isn't giving a direct cause like an ADC error or a Lost Comms error)
then it is always worth having a look into your klippy.log file to see what it says.

Simply download the klippy.log file from your printer (you can do this via the Mainsail or Fluidd GUI, or copy it directly from `~/printer_data/logs`), scroll down to the very bottom, then start scrolling "up" until you 
run into the error you just had (you can also use the "find" function in a lot of text editors to search for your error).

Once you have found where the error in the logs, scroll up a bit further until you start seeing lines that start with `Stats:`

![image](https://github.com/user-attachments/assets/c0ca73e4-0b5b-46b5-aea6-d3f08959a63d)

These lines are incredibly helpful when diagnosing issues. 

Each line goes in sections according to the MCU. The first section will be your mainboard MCU as it is simply called `MCU`

![image](https://github.com/user-attachments/assets/23c8dcf7-c87a-48c6-8d0c-3130a7293b10)

So if you find the `mcu:` part, anything to the right of this on that line will be the stats for the mainboard at that time.  So any bytes_retransmit or bytes_invalid or whatever will be associated with your mainboard.

If you keep scrolling to the right you will find another mcu entry with the name of one of your other boards

![image](https://github.com/user-attachments/assets/4b0c49eb-60ae-443d-9ade-d5eb9c63b1a3)

So same thing again. Anything after *this* entry will be related to *this* particular MCU (in this case, the EBBCan is the toolhead of this user, so the stats are related to the toolhead board).

The most common things to look at to help diagnose issues are the `bytes_retransmit` and `bytes_invalid` counters. Make sure to check the entries for *each* mcu entry (ie. the just `mcu`, a toolhead that may be `EBBCan` or whatever, etc.)

# bytes_retransmit

The `bytes_retransmit:` field indicates how many data packets have had to be resent to that MCU. This can be because the packet was malformed or had errors or otherwise isn't getting through from the Pi to the MCU properly.

If you are seeing bytes_retransmit after investigating a "Lost communication" error then it is highly likely your problem is a physical issue, usually an issue with the CAN cable or other connector (see [here](./lost_communication_to_mcu.md))
But retransmits aren't *only* caused by a bad cable. They can be caused by many other issues as well, but if you see it *in conjunction with* a "Lost communication with mcu" error then there is a good chance it's cabling.

bytes_retransmit is the most common "bad" thing you'll see in the logs, but make sure to check *each* mcu section along the Stats: line. Just because the mainboard MCU has no bytes_retransmits doesn't mean your toolhead doesn't.

If you see anything higher than 9 then you should keep an eye on it. Generally it should be 0 but I've seen USB boards sometimes cause it to get to 9 and stay there (probably something to do with first startup).

# bytes_invalid

the `bytes_invalid:` entry is another helpful one to check but it's far less common for this to be anything other than 0.

Invalid bytes are data packets that arrived to the mcu perfectly fine, no errors or anything, but they came in the wrong order. So if your Pi was sending packets 101, 102, 103, then the MCU may have received them in order 101, 103, 102.

This is **not** something that is caused by a bad cable/wire/other physical thing. This is a software issue.

There have been instances where bad firmware on a CAN adapter (the only one I really know of is the BTT U2C but it could happen to others) and the fix for that is simply to flash the correct firmware on it (see [here](../can_adapter/BigTreeTech%20U2C%20v2.1#bad-firmware) 
for the BTT U2C fix specifically).

The other more common cause is the operating system of the Pi itself. It may be getting overloaded or have some rogue process (in which case the [timer_too_close](./timer_too_close.md) page may help) or you may have a bad version of
the operating system (see the [Pi operating system](../Getting_Started.md#raspberry-pi-operating-system) section of the Getting Started page)

# Live Tracking

If you have found one of these stats incrementing in the logs but you can't seem to find the cause, then it may help to watch the stats "live". You can do this in the Mainsail GUI (may be possible in Fluidd or others in a similar way)
by going to the "MACHINE" tab, then clicking on the mcu name of the board you want to monitor in the "System Loads" section. This will open a new window where you can scroll down and find bytes_retransmit and bytes_invalid (as well
as every other stat) and this will be showing a live update of the stats. 

![image](https://github.com/user-attachments/assets/3df25c42-b7b1-4e57-842c-a2a7968c43d0)

Simply keep this open in another browser window while you are doing a print or test or whatever. It may help you line up a specific action of the printer with a jump in errors.
