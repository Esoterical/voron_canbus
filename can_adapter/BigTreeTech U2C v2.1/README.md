---
layout: default 
title: BigTreeTech U2C v2.1
parent: Common CAN Adapters
grand_parent: Dedicated USB CAN Device
---


# 120 ohm Termination Resistor

The header for the 120R termination resistor is circled in purple

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/c7044a7f-db00-42a1-b75f-c449c44a13ca)

# Wiring

Connect a USB cable from our Pi to the usb-c port of the U2C. This provides the data connection and power to the U2C.

Do *not* connect your mainboard (Octopus, etc.) to the USB-A ports on the U2C. They are not a simple USB hub, they are canbus ports using a USB-A connector.
You want to connect your mainboard directly to your Pi via USB.

Connect the CanH and CanL from your canbus boards to any of the H/L connections on the U2C. All of these connections are tied together so it doesn't matter
which ones you choose.

If you *also* run the 24v and GND wires from your canbus board to the U2C then you have to connect the 24v and GND pins (usually the screw terminals) to the V+ and V- of your PSU. This doesn't power the U2C at all, it's just pass through to your canbus board for ease of wiring.

![image](https://github.com/user-attachments/assets/f3e6e632-7456-4825-afbf-fe0f6d0f37e6)


![CANbus_U2C_Pinout_on_Power_Connector](https://github.com/Esoterical/voron_canbus/assets/124253477/57a4a525-31ea-4565-ad69-6bb50510c090)


# Bad Firmware

The U2C came stock with bad firmware that would cause flashing problems down the line. This was mainly back in early 2023 so if you have purchased a board *recently* this may not be an issue, but flashing this firmware can't hurt anyway and is very simple to do.

I have copied a fixed version of the firmware here, you can download it to your pi by running:
```bash
cd ~/
wget https://github.com/Esoterical/voron_canbus/raw/main/can_adapter/BigTreeTech%20U2C%20v2.1/G0B1_U2C_V2.bin
```

(you can read about the error at https://github.com/Arksine/katapult/issues/44)

If you used the wget link the firmware should now be in your home directory. Press the boot button on the U2C while plugging it in to your Pi to put it into DFU mode.

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/ad3a5d48-fc30-4dea-9b9e-96fb1eec37e3)

Confirm it is connected in DFU mode by running `sudo dfu-util -l`. You should see the devive:

![image](https://user-images.githubusercontent.com/124253477/221551890-3205eafb-9f16-41b5-8020-ebb1ebbf5ded.png)

If you can see it there then just run this command to flash the fixed firmware to the U2C:

```bash
sudo dfu-util -D ~/G0B1_U2C_V2.bin -a 0 -s 0x08000000:leave
```

![image](https://user-images.githubusercontent.com/124253477/221552152-89f14967-b807-4e54-9159-003b19eed784.png)

You may see an "error during download get-status" down the bottom. You can ignore that as long as everything else is successful.

Once flashed, unplug the U2C from the Pi then plug it back in. Run an `ifconfig` and you should see a "can0" interface (assuming you have already set the /etc/network/interfaces.d/can0 file). If so, then congratulations your U2C is succesfully flashed with the fixed firmware.

# Missing drivers

Check whether appropriate Linux driver for the adapter is available:
```bash
lsmod | grep can
```

Expected output should contain `gs_usb` (which is a driver for "Geschwister Schneider CAN adapter" based adapters).

If the output does not mention `gs_usb` anywhere, it is likely that you are missing an appropriate driver. This may happen when using less common SBCs and their respective OS image has that module disabled (eg. certain builds of Armbian might have this module disabled during build-time).

With the required driver missing, you may need to use a different OS image, recompile the image, contact the OS image maintainers to include that module, or compile the module stand-alone and then install it.
