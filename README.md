## Generalised CANBus guide

So you want to use Canbus on your printer? There are plenty of guides around but usually they are guides on a specific hardware configuration. This guide hopes to generalise some of the steps to help anyone get started on their CAN journey with a printer.

Note: This will be generally structured around Voron printers and common hardware for a Voron printer, but you can take the information to any Klipper-based printer as long as you either use the same electronics (mainboard/canboard) or use this guide to adapt to your specific electronics (if they are supported).

So let's get started.


# Basic Structure of a 3d Printer CANBus

In all likelyhood you are looking to hook up a single CAN toolhead board to your printer to minimise wiring from mainboard to toolhead, so that is the setup we'll be focusing on. 
In order to achieve a functioning CAN network on your printer you need 3 things: A computer running the main Klipper software (usually a Raspberry Pi, but anything with a USB port will work for this guide), a CAN network adapter (either a standalone USB device or running a compatible mainboard in klipper's usb-can bridge mode) and a CAN node (the toolhead device). This is also the order in which you need to set things up. No point setting everything up on the toolhead CAN board if you don't have a way for the Pi to talk to it.
We are going to assume you have a functioning Pi (or equivelant) running linux and already have Klippper, Moonraker, some sort of GUI (Fluidd/Mainsail/Octoprint), and you have the ability to SSH into it.

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


