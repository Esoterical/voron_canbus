---
layout: default 
title: Timeout During Homing/Probing
nav_order: 40
parent: Troubleshooting
---

# Timeout during homing and/or probing

I'm going to make a couple of assumptions right at the start for this section as this 'symptom' could be from different causes. So to narrow it down this section is if:

- Your printer gets an error along the lines of `Timeout during homing` or `Timeout during probe` or `Timeout during homing probe`
- This error doesn't *always* happen. Sometimes it'll home fine or probe fine and start printing.
- Once your printer is printing it doesn't error out, it only happens during axis homing or a bed mesh.

If your symptoms match the above read on. If you can't even finish a homing or probing actuion error, or you sometimes can but you frequently get ["lost communication to mcu"](./lost_communication_to_mcu.md) or ["timer too close"](./timer_too_close.md) errors please read those relevant sections first then return here if your symptoms more align with the above.

With that out of the way, this kind of problem is usually the cause of your Pi not keeping up with klipper during a homing or probing operation. These operations require very tight timings and an underpowered board or a board with a lot of background processes going on can somtimes miss a timing window and cause this error. Or sometimes a board that "should" work fine still does it, which I suspect is something lower level in the linux kernel, but that's not a discussion for here.

## Service Niceness

My current favourite way of making sure the klipper service has first take of cpu cycles is via changing the "niceness" value of the Klipper service. Niceness is how the operating system determines which services/applications have a higher priority when it comes to giving them CPU cycles to do work with. By default the operating-system-critical kernel level stuff all have a niceness of -20 and standard services/applications have a niceness of 0. The lower the niceness (ie. the "less nice" the process is) the higher priority it has and so it will be given CPU cycles before other things.

In order to use this to our advantage and make the Klipper service have higher priority over other things on the Pi we simply need to add a single line to the klipper.service config file.

Run:

```bash
sudo nano /etc/systemd/system/klipper.service
```

and then add `Nice=-10` to the bottom of what is already there

![image](https://github.com/user-attachments/assets/771800c7-62cf-45e1-8e0d-7d671965de96)

(be very careful to make the change *negative* 10. Doing it as just Nice=10 will make the klipper service *too* nice and therefore it will be at the back of the queue for any cpu cycles. This is a bad thing)

Now just `sudo reboot now` to reboot the Pi. After that the Klipper service will have a higher priority than other processes and this can really help with timing-critical events such as homing or probing.

## Legacy Methods

I've moved the older methods that used to be listed here to the ["Legacy Timeout During Homing/Probing"](./legacy_timeout_during_homing_probing.md) page. The Niceness method is a much cleaner way of achieving the results we are after, but if the
older methods are required for reference you can find them there.


[Return to Troubleshooting](../troubleshooting.md)
