# Dedicated USB CAN device


**IF YOU HAVE A BTT U2C V2.1 THEN PLEASE FLASH IT WITH THE LATEST VERSION OF V2 FIRMWARE FROM THE GITHUB AS THE SHIPPED FIRMWARE MAY HAVE BUGS [See Here](./can_adapter/BigTreeTech%20U2C%20v2.1)**

If you want to use a dedicated USB CAN devcice, then it should be as  simple as plugging it in to your Pi via USB. ***You shouldn't have to flash anything to this U2C/UTOC/etc device first, they are meant to come pre-installed with the necessary firmware. They do NOT run Klipper***. You can test if it is working by running an `lsusb` command (from an SSH terminal to your pi). Most common USB CAN devices will show up as a "Geschwister Schneider CAN adapter" when they are working properly (though some may simply show as an "OpenMoko, Inc" device):

![image](https://user-images.githubusercontent.com/124253477/221329262-d8758abd-62cb-4bb6-9b4f-7bc0f615b5de.png)

![image](https://user-images.githubusercontent.com/124253477/222042688-10fa6fdb-8c0a-4142-8c40-0d93ef4fc4bd.png)


A better check is by running an 'interface config' command `ifconfig`. If the USB CAN device is up and happy (and you have created the can0 file above) then you will see a can0 interface:

![image](https://user-images.githubusercontent.com/124253477/221329326-efa1437e-839d-4a6b-9648-89412791b819.png)

**A note on edge cases**

If you plug in your USB CAN adapter and you *don't* see the expected results from an `lsusb` or `ifconfig`, then the firmware on your device may have issues. If this is the case then it's worth going to the Github page of your device as they usually have the stock firmware and flashing instructions there.

**A note on the note**

The BTT U2C V2.1 was released with bad firmware which although would show up to the above tests it would make issues show up down the line. If you have a v2.1 of the U2C then please follow the instructions here: https://github.com/Esoterical/voron_canbus/tree/main/can_adapter/BigTreeTech%20U2C%20v2.1


# Next Step

Once you have confirmed you can see your can0 interface, continue [here](./toolhead_flashing) for instructions on flashing your toolhead for use with Canbus.