## Generalised CANBus guide

So you want to use Canbus on your printer? There are plenty of guides around but usually they are guides on a specific hardware configuration. This guide hopes to generalise some of the steps to help anyone get started on their CAN journey with a printer.

Note: This will be generally structured around Voron printers and common hardware for a Voron printer, but you can take the information to any Klipper-based printer as long as you either use the same electronics (mainboard/canboard) or use this guide to adapt to your specific electronics (if they are supported).

So let's get started.


# Basic Structure of a 3d Printer CANBus

In all likelyhood you are looking to hook up a single CAN toolhead board to your printer to minimise wiring from mainboard to toolhead, so that is the setup we'll be focusing on. 
In order to achieve a functioning CAN network on your printer you need 3 things: A computer running the main Klipper software (usually a Raspberry Pi, but anything with a USB port will work for this guide), a CAN network adapter (either a standalone USB device or running a compatible mainboard in klipper's usb-can bridge mode) and a CAN node (the toolhead device). This is also the order in which you need to set things up. No point setting everything up on the toolhead CAN board if you don't have a way for the Pi to talk to it.
We are going to assume you have a functioning Pi (or equivelant) running linux and already have Klippper, Moonraker, some sort of GUI (Fluidd/Mainsail/Octoprint), and you have the ability to SSH into it.

# Regarding CAN***BOOT***

You may have seen other guides have installing CanBOOT onto devices as a first step. CanBOOT is a custom firmware and allows flashing of Klipper to the devices via the CAN network so you don't have to plug a USB cable in each time to flash/update klipper. CanBOOT is really handy but it is ***NOT*** mandatory. This will be discussed later, but Klipper will happily run over a CAN network with or without CanBOOT. 

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
    up ifconfig $IFACE txqueuelen 1024
    pre-up ip link set can0 type can bitrate 1000000
    pre-up ip link set can0 txqueuelen 1024
  ```
![image](https://user-images.githubusercontent.com/124253477/221327711-1d68b5b6-3ad8-472c-88ba-761991bfcd7f.png)

The "allow-hotplug" helps the CAN nodes come back online when doing a "firmware_restart" within Klipper.
"bitrate" dictates the speed at which your CAN network runs at. Kevin O'Connor (of Klipper fame) recommends a 1M speed for this to help with high-bandwidth and timing-critical operations (ADXL Shaper calibration and mesh probing for example). 
To complement a high bitrate, setting a high transmit queue length "txqueuelen" of 1024 helps minimise "Timer too close" errors.
The "pre-up" stuff isn't really necessary. It may help with the Pi's functionality if the link isn't online yet but if this is omitted it shouldn't matter.

Once the can0 file is created just reboot the Pi and move on to the next step.

#  Your main CAN network adapter

To actually create a CAN network in your system, your Pi needs some sort of device to act as a CAN adapter (think of it like a USB network card, or USB wifi dongle). The simplest plug-and-play option is to use a dedicated USB to Can device such as the BigTreeTech U2C or the Mellow Fly UTOC (other devices exist as well). The second "cheaper" option is to actually utilise your printer mainboard (ie. Octopus or Spider board) to function as a usb-can bridge for klipper. We'll cover both options, but you only need to choose one.

# Dedicated USB CAN device

If you want to use a dedicated USB CAN devcice, then it should be as  simple as plugging it in to your Pi via USB. ***You shouldn't have to flash anything to this U2C/UTOC/etc device first, they are meant to come pre-installed with the necessary firmware. They do NOT run Klipper***. You can test if it is working by running an `lsusb` command (from an SSH terminal to your pi). Most common USB CAN devices will show up as a "Geschwister Schneider CAN adapter" when they are working properly:
![image](https://user-images.githubusercontent.com/124253477/221329262-d8758abd-62cb-4bb6-9b4f-7bc0f615b5de.png)
You can also check by running an 'interface config' command `ifconfig`. If the USB CAN device is up and happy (and you have created the can0 file above) then you will see a can0 interface:
![image](https://user-images.githubusercontent.com/124253477/221329326-efa1437e-839d-4a6b-9648-89412791b819.png)



