---
layout: default 
title: Timer Too Close
nav_order: 60
parent: Troubleshooting
---

# Timer Too Close

This error tends to be a "catch all" for a bunch of different causes. It can often be caused by the Pi itself getting overloaded (or overheating and throttling), or the mcu in question (toolhead/mainboard/whatever) also getting overloaded. Or a different thing entirely.

You can find more info about it in [this Klipper discourse post](https://klipper.discourse.group/t/timer-too-close/6634)

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

## Raspberry Pi OS (Bookworm, 64-bit) — CAN Stability Settings

On fresh installs of Raspberry Pi OS, some defaults may be too low for heavy CAN traffic. A common symptom is:

`Got error -1 in can write: (105) No buffer space available`

You’ll also see this clearly in the [debugging script](./debugging/README.md) — it’s worth running because it surfaces lots of useful information.

### Enforce correct `qlen`.
When the `qlen` is restored to `10` every restart add the following rule:

```shell
printf 'ACTION=="add", SUBSYSTEM=="net", KERNEL=="can0", RUN+="/usr/sbin/ip link set dev can0 txqueuelen 1024"\n' \
| sudo tee /etc/udev/rules.d/80-can-qlen.rules

sudo udevadm control --reload
sudo systemctl stop klipper

# Recreate the interface so the rule runs:
sudo modprobe -r gs_usb && sudo modprobe gs_usb

# Verify qlen for your can network
ip -d -s link show can0 | grep qlen

sudo systemctl start klipper
```

NOTE: If /usr/sbin/ip isn’t the correct path on your system, replace it with the output of command -v ip.

### Disable USB autosuspend for the CAN adapter

Find your adapter’s Vendor/Product IDs:

```shell
$ lsusb
# Example output:
# Bus 005 Device 003: ID 1d50:606f OpenMoko, Inc. Geschwister Schneider CAN adapter
...
```

In this example the IDs are 1d50:606f (Vendor ID `1d50`, Product ID `606f`). Create a udev rule:

```shell
sudo tee /etc/udev/rules.d/99-usb-can-pm.rules >/dev/null <<'EOF'
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="PASTE_VENDOR_ID_HERE", ATTR{idProduct}=="PASTE_PRODUCT_ID_HERE", \
  TEST=="power/control", ATTR{power/control}="on"
EOF
sudo udevadm control --reload
sudo udevadm trigger -s usb
```

Replace PASTE_VENDOR_ID_HERE / PASTE_PRODUCT_ID_HERE with your values (e.g., 1d50 and 606f).

### Increase global socket buffer sizes

These control default and maximum socket buffer sizes (bytes):

- `net.core.wmem_max` — max send buffer size
- `net.core.rmem_max` — max receive buffer size
- `net.core.wmem_default` — default send buffer size
- `net.core.rmem_default` — default receive buffer size

Increase them with:

```shell
sudo tee /etc/sysctl.d/99-socket-buffers.conf >/dev/null <<'EOF'
net.core.wmem_max=4194304
net.core.rmem_max=4194304
net.core.wmem_default=1048576
net.core.rmem_default=1048576
EOF
sudo sysctl --system
```

(Optional) Verify current values:

```shell
sysctl net.core.wmem_max net.core.rmem_max net.core.wmem_default net.core.rmem_default
```

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
