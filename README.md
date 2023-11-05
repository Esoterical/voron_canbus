Before we start a big thanks has to go to the #mcu_toolhead_boards thread on the Voron discord. A wealth of information from some very clever people.
If you have any of the following combinations of hardware, please look at these existing specific guides:

Octopus (in CAN bridge mode) and SB2040: https://github.com/akhamar/voron_canbus_octopus_sb2040 by @MastahFR

BTT U2C and EBB36: https://github.com/EricZimmerman/VoronTools/blob/main/EBB_CAN.md by @EricZimmerman

SKR Pico in can bridge mode: https://github.com/eschlenz/3D-Printing-Public/blob/main/skr_pico_canboot_canbus.md by @eschlenz

and many others.

## Generalised CANBus guide

So you want to use Canbus on your printer? There are plenty of guides around but usually they are guides on a specific hardware configuration. This guide hopes to generalise some of the steps to help anyone get started on their CAN journey with a printer.

Note: This will be generally structured around Voron printers and common hardware for a Voron printer, but you can take the information to any Klipper-based printer as long as you either use the same electronics (mainboard/canboard) or use this guide to adapt to your specific electronics (if they are supported).

So let's get started.


# Basic Structure of a 3d Printer CANBus

In all likelyhood you are looking to hook up a single CAN toolhead board to your printer to minimise wiring from mainboard to toolhead, so that is the setup we'll be focusing on.
In order to achieve a functioning CAN network on your printer you need 3 things: A computer running the main Klipper software (usually a Raspberry Pi, but anything with a USB port will work for this guide), a CAN network adapter (either a standalone USB device or running a compatible mainboard in klipper's usb-can bridge mode) and a CAN node (the toolhead device). This is also the order in which you need to set things up. No point setting everything up on the toolhead CAN board if you don't have a way for the Pi to talk to it.
We are going to assume you have a functioning Pi (or equivelant) running linux and already have Klippper, Moonraker, some sort of GUI (Fluidd/Mainsail/Octoprint), and you have the ability to SSH into it.

# Regarding Katapult (formerly known as CanBoot)

You may have seen other guides have installing Katapult/CanBOOT onto devices as a first step. Katapult is a custom firmware and allows flashing of Klipper to the devices via the CAN network so you don't have to plug a USB cable in each time to flash/update klipper. Katapult is really handy but it is ***NOT*** mandatory. This will be discussed later, but Klipper will happily run over a CAN network with or without Katapult.

# can0 file, CAN Speeds, and Transmit Queue Length

This step usually comes later, but as it is common across all different variants we may as well get it done first. In order to dictate the speed at which your CAN network runs at you will need to create (or modify) a "can0" file on your Pi. This is what will tell linux "Hey, you now have a new network interface called can0 that you can send CAN traffic over". To do this first SSH to your Pi and run the command:
  ```
  sudo nano /etc/network/interfaces.d/can0
  ```
  ![image](https://user-images.githubusercontent.com/124253477/221327674-fad20589-1a5b-4d68-b2d9-2596553f64ab.png)

This will open (or create if it doesn't exist) a file called 'can0' in which you need to enter the following information:
  ```
  allow-hotplug can0
  iface can0 can static
    bitrate 1000000
    up ip link set can0 txqueuelen 1024
  ```

![image](https://user-images.githubusercontent.com/124253477/221378593-9a0fcdb5-082c-454e-94bd-08a6dc449d34.png)

Press Ctrl+X to save the can0 file.

The "allow-hotplug" helps the CAN nodes come back online when doing a "firmware_restart" within Klipper.
"bitrate" dictates the speed at which your CAN network runs at. Kevin O'Connor (of Klipper fame) recommends a 1M speed for this to help with high-bandwidth and timing-critical operations (ADXL Shaper calibration and mesh probing for example).
To complement a high bitrate, setting a high transmit queue length "txqueuelen" of 1024 helps minimise "Timer too close" errors.

Once the can0 file is created just reboot the Pi with a `sudo reboot` and move on to the next step.

#  Your main CAN network adapter

To actually create a CAN network in your system, your Pi needs some sort of device to act as a CAN adapter (think of it like a USB network card, or USB wifi dongle). The simplest plug-and-play option is to use a dedicated USB to Can device such as the BigTreeTech U2C, Mellow Fly UTOC, Fysetc UCAN, etc. (other devices exist as well). The second "cheaper" option is to actually utilise your printer mainboard (ie. Octopus or Spider board) to function as a usb-can bridge for klipper. We'll cover both options, but you only need to choose one.

# Dedicated USB CAN device

**IF YOU HAVE A BTT U2C V2.1 THEN PLEASE FLASH IT WITH THE LATEST VERSION OF V2 FIRMWARE FROM THE GITHUB AS THE SHIPPED FIRMWARE MAY HAVE BUGS https://github.com/Esoterical/voron_canbus/tree/main/can_adapter/BigTreeTech%20U2C%20v2.1**

If you want to use a dedicated USB CAN devcice, then it should be as  simple as plugging it in to your Pi via USB. ***You shouldn't have to flash anything to this U2C/UTOC/etc device first, they are meant to come pre-installed with the necessary firmware. They do NOT run Klipper***. You can test if it is working by running an `lsusb` command (from an SSH terminal to your pi). Most common USB CAN devices will show up as a "Geschwister Schneider CAN adapter" when they are working properly (though some may simply show as an "OpenMoko, Inc" device):

![image](https://user-images.githubusercontent.com/124253477/221329262-d8758abd-62cb-4bb6-9b4f-7bc0f615b5de.png)

![image](https://user-images.githubusercontent.com/124253477/222042688-10fa6fdb-8c0a-4142-8c40-0d93ef4fc4bd.png)


A better check is by running an 'interface config' command `ifconfig`. If the USB CAN device is up and happy (and you have created the can0 file above) then you will see a can0 interface:

![image](https://user-images.githubusercontent.com/124253477/221329326-efa1437e-839d-4a6b-9648-89412791b819.png)

**A note on edge cases**

If you plug in your USB CAN adapter and you *don't* see the expected results from an `lsusb` or `ifconfig`, then the firmware on your device may have issues. If this is the case then it's worth going to the Github page of your device as they usually have the stock firmware and flashing instructions there.

**A note on the note**

The BTT U2C V2.1 was released with bad firmware which although would show up to the above tests it would make issues show up down the line. If you have a v2.1 of the U2C then please follow the instructions here: https://github.com/Esoterical/voron_canbus/tree/main/can_adapter/BigTreeTech%20U2C%20v2.1

# Klipper USB to CAN bus bridge

The second way of setting up a CAN network is to use the printer mainboard itself as a CAN adapter.

**If you are using a dedicated CAN adapter as above then you don't need this step. Your mainboard will be flashed the same as any other "normal" klipper install**

This is acheived through Klippers "USB-CAN-Bridge mode". In order for this to work you need to have a compatible MCU on the mainboard (A lot of the popular STM32 chips works, as well as the RP2040), and either a dedicated "CAN" port on the motherboard or at least a way of accessing the CAN pins that you configure for klipper.

Some mainboards (like the BTT Octopus) have a CAN Transceiver built in so they will output CAN signals directly from a dedicated port (the Octopus has an RJ11 port for this purpose). Other compatible boards may have a port on their board labelled as CAN but only output serial (Tx Rx) signals. These boards can still be run as USB-CAN-Bridge mode but will require an additional CAN Transceiver module (such as the SN65HVD230). These can be cheaply purchased from Amazon or eBay or AliExpress. Other boards may yet not have any dedicated CAN port, but still have a compatible MCU and have compatible CAN pins that you can access (the SKR Mini E3 V3 can be run in USB-CAN-Bridge mode if you use the PB8/PB9 pins on the EXP1 header that is normally used for an LCD screen).

More specific instructions refer to https://github.com/Esoterical/voron_canbus/tree/main/mainboard_flashing

Once you have klipper firmware flashed to your mainboard, with the USB-CAN-Bridge mode enabled, it should show up to your Pi as a "Geschwister Schneider CAN adapter" if you run an `lsusb`

![image](https://user-images.githubusercontent.com/124253477/221329262-d8758abd-62cb-4bb6-9b4f-7bc0f615b5de.png)

If you run an `ifconfig` command you should also see a can0 interface.

![image](https://user-images.githubusercontent.com/124253477/221329326-efa1437e-839d-4a6b-9648-89412791b819.png)

The takeaway is that if you go down the mainboard USB-CAN-Bridge route, then you *need* to have klipper firmware flashed to the mainboard before attempting any further CAN installs/troubleshooting.

# CAN on a toolhead

One you have a functioning CAN network on your printer, you can proceed to flashing klipper to your toolhead of choice. Refer to https://github.com/Esoterical/voron_canbus/tree/main/toolhead_flashing for more information on how to flash the toolhead.

To wire up your toolhead refer to manufacturer guides but the overall process is hooking up 24v and Gnd back to your 24v PSU, and then connecting CANH and CANL to the CANH and CANL of your CAN adapter (either dedicated USB Can devcie, or a USB-CAN-Bridge mainboard). CANH goes to CANH, CANL goes to CANL.

Once you have klipper installed on your toolhead, and it is all wired up correctly, you can run a canbus query command:

`~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0`

which should show a can UUID for each CAN device (a USB-CAN-Bridge mode mainboard will show as a CAN device) as well as the unique ID of the device:

![image](https://user-images.githubusercontent.com/124253477/221332914-c612d996-f9c3-444d-aa41-22b8eda96eba.png)

You will then use this uuid in your printer.cfg for the [mcu] section of your device

![image](https://user-images.githubusercontent.com/124253477/221332943-57a65a4e-f3ab-484c-8ac5-a2b35366e34f.png)

(This is my Spider mainboard running in USB-CAN-Bridge mode, and my EBB36 toolhead)

# Configuration

If you have completed the above and have the canbus uuid of your CAN device in your printer.cfg, then everything else is just a case of setting up the required pins with the toolhead MCU name prefixed to the pin name. See https://www.klipper3d.org/Config_Reference.html#mcu-my_extra_mcu for information.
Most toolheads will have a sample.cfg on their github, so it's usually a simple case of copy-pasting the required information from the sample into your own printer.cfg.




