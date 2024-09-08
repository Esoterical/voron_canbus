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

## CPU Affinity

Something I've had success with lately is assigning CPU cores to processes. The following steps will force everything *except* klipper to run on the first 3 cores (cores 0, 1, 2) of a quad-core CPU (any Pi newer than a Pi2) and then force Klipper to run by itself on the fourth core. This *may* help with timing issues or scheduling conflicts or whatever could be interrupting Klipper from hitting the proper timing windows.

Create the system.conf.d folder with:
```bash
sudo mkdir -p /etc/systemd/system.conf.d/
```

then edit (or create) the cpuaffinity.conf file by running:
```bash
sudo nano /etc/systemd/system.conf.d/cpuaffinity.conf
```
and putting in:
```bash
[Manager]
CPUAffinity=0-2
```
then press ctrl+X to save and quit. This will force everything to run on the first three cpu cores only.

To make Klipper run on the now-unused fourth core, create the klipper.service.d folder with:
```bash
sudo mkdir -p /etc/systemd/system/klipper.service.d
```

then edit (or create) the override.conf file by running:
```bash
sudo nano /etc/systemd/system/klipper.service.d/override.conf
```
and putting in:
```bash
[Service]
CPUAffinity=3
```
then press ctrl+X to save and quit, and run `sudo reboot now` to reboot the Pi.

Once it starts again it should have the Klipper service running by itself on the fourth core of the CPU and hopefully let it not get interrupted by other non-Klipper processes.

## Config Tweaks

If the CPU Affinity doesn't work (or your computer board doesn't have multiple cores),then we can try minimising CAN traffic by lowering stepper motor microsteps and the homing speed.

- Set **all** microstep settings in your printer.cfg to 16. This value is found in the `[stepper_ ]` sections for X/Y/Z (probably multiple Z motors, you need to change each one) and also your `[extruder]` section.
  
  ![image](https://github.com/Esoterical/voron_canbus/assets/124253477/12fe8458-664c-4a50-86e7-b20845e9a579)
  
- Set the homing speeds to fairly low. 20mm/s for X/Y, 10mm/s for Z. Yes this may be painful but it's just testing at the moment. Once you've "fixed" the problem feel free to adjust these back up.
- Make sure your CAN speed is set to 1M and txqueuelen is set to 1024 (see the [Getting_Started](../Getting_Started.md) page on how to set this)
- Unplug any extra USB devices from your pi. Maybe LEDs, maybe cameras. Anything USB can be drawing power and using processing time so lets remove it all for testing
- If using crowsnest for your camera, stop the crowsnest service completely. Easy to do in mainsail, just press the button:
  
  ![image](https://github.com/Esoterical/voron_canbus/assets/124253477/c0555deb-9cb9-44b5-9679-43500659b2d6)
  
  or you can run `sudo service crowsnest stop` on the Pi and this will also stop the crowsnest service
  
  ![image](https://github.com/Esoterical/voron_canbus/assets/124253477/08d74420-1ef5-4223-9e4e-1c735ee70574)


Now do some more homing and probing. If it's rock solid now, great! Go through the steps in reverse order (re-enable crowsnest, plug in USB one at a time, change microsteps, etc) until you start seeing it time out again. This way you should be able to either track down the single culprit or at least find the limits of what your Pi can handle.

## TRSYNC_TIMEOUT

If the above still doesn't fix it (and by "fix it" I mean "never happens" not just making it happen less) then the next thing I would do is to actually change the klipper homing timeing threshold. This is a bit "hacky", but I've found it necessary on certain boards (I had to do it on my pi3b, nothing else would solve the problem).

By default, Klipper uses a 25ms window for homing actions. This is set by the `TRSYNC_TIMEOUT` entry in the klipper `mcu.py` file. To check if yours is still the default run:

```bash
cat klipper/klippy/mcu.py | grep "TRSYNC_TIMEOUT ="
```

if it shows TRSYNC_TIMEOUT=0.025 then it is still the default setting.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/8ae18275-a606-47e1-86c1-f2b53d54e9a9)

To change this to 50ms run the command:

```bash
sed -i 's\TRSYNC_TIMEOUT = 0.025\TRSYNC_TIMEOUT = 0.05\g' ~/klipper/klippy/mcu.py
```

Then confirm it by running `cat klipper/klippy/mcu.py | grep "TRSYNC_TIMEOUT ="` again. If the change has been set reboot the Pi with `sudo reboot`.

I've found a 50ms timeout window got rid of all my "timeout during homing probe" errors with seemingly no loss in probing or homing accuracy. 

**Note** as I said this is still a bit of a hacky workaround. Doing this will mark your klipper install as "dirty" in your mainsail update manager (all it means is there is a file that is different to what is in github, which is true because we just changed it) and whenever you update klipper it will overwrite this to default. So if you update klipper and find the timeouts returning just run `sed -i 's\TRSYNC_TIMEOUT = 0.025\TRSYNC_TIMEOUT = 0.05\g' ~/klipper/klippy/mcu.py` and reboot.




[Return to Troubleshooting](./)
