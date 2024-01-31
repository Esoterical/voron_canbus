## Getting Started

# can0 file, CAN Speeds, and Transmit Queue Length

In order to dictate the speed at which your CAN network runs at you will need to create (or modify) a "can0" file on your Pi. This is what will tell linux "Hey, you now have a new network interface called can0 that you can send CAN traffic over". The approach needed here heavily depends on the network stack of your Pi. Raspbian and older version of Debian typically use ifupdown, but newer versions of non-raspbian Debian use netplan, which by default uses systemd-networkd under the hood.

To test if your system uses networkd, try running `networkctl`. If the command is not available, gives an error or no link output, you're probably still using ifupdown. If it does give you meaningful output (typically at least an `ether` and `wlan` link), you're using systemd-networkd. To be safe it's easiest to just follow both the "ifupdown" **and** the "systemd-networkd" instructions. You can have both set up and your Pi will just use the configuration that is relevant to your system.

To set everything up, SSH into your pi and run the commands needed for your network setup:

## ifupdown
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

## systemd-networkd (netplan)
  ```
  sudo nano /etc/systemd/network/10-can.link
  ```
This will open (or create if it doesn't exist) a file called `10-can.link` in which you need to enter the following information:
  ```
  [Match]
  Type=can

  [Link]
  TransmitQueueLength=1024
  ```
Press Ctrl+X to save the file.

To set the bitrate, we need to create another file in the same directory:
  ```
  sudo nano /etc/systemd/network/25-can.network
  ```
This creates a network file, that networkd will then use to automatically set up the network with. Because of how networkd works, "hotplugging" is baked in.
Enter the following in the network-file and close it with Ctrl+X:
  ```
  [Match]
  Name=can*

  [CAN]
  BitRate=1M
  ```
  
  

# Next Step

Now that the can0 interface files are set up, you need to choose how you are going to connect your Pi to the CANBus network.

To actually create a CAN network in your system, your Pi needs some sort of device to act as a CAN adapter (think of it like a USB network card, or USB wifi dongle). The simplest plug-and-play option is to use a dedicated USB to Can device such as the BigTreeTech U2C, Mellow Fly UTOC, Fysetc UCAN, etc. (other devices exist as well). The second "cheaper" option is to actually utilise your printer mainboard (ie. Octopus or Spider board) to function as a usb-can bridge for klipper. We'll cover both options, but you only need to choose one.

[Click here for Dedicated USB-CAN Adapter](./Dedicated_USB_Can_Device.md)

[Click here for USB-CAN-Bridge Klipper on your Mainboard](./USB_CAN_Bridge_Mainboard.md)

