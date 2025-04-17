---
layout: default 
title: Fysetc Spider v2.3
parent: Common Mainboard Hardware
grand_parent: Mainboard Flashing
---

# 120 ohm Termination Resistor

As the Spider v2.3 requires an [external CAN transciever](#transceiver) there is no built in 120ohm resistor on the Spider itself. The transceiver you use will likely have the 120r resistor hard soldered already, but some may have jumpers or solder pads to add/remove it from the circuit.

# DFU mode

To put the Spider v2.3 into DFU mode, connect the Spider to the Pi with a USB cable, then place a jumper on the `3.3v` and `BT0` pins:

![image](https://github.com/user-attachments/assets/491e2e1c-7b56-419b-a0ec-e08707820030)



Then press the RST button on the side of the board:

![image](https://github.com/user-attachments/assets/05a5354b-e578-4655-b0db-fd5021f3efbb)


# Katapult Config

![image](https://github.com/user-attachments/assets/b99edc19-008a-43fa-be5a-21434b081185)

# Klipper USB-CAN-Bridge Config

![image](https://user-images.githubusercontent.com/124253477/221349817-d7381c21-fecc-4111-a34b-bf0522cd456e.png)


# Transceiver
You will need a seperate CAN Transceiver board, such as the TJA1050:

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/2df10f80-8239-4368-9aa4-e1abe9ded541)

The Can Rx and Can Tx will be connected to the PD0 and PD1 port (which is labelled as the CAN port). You can also hook up the Gnd and 5v from this port to the transceiver board.

![image](https://user-images.githubusercontent.com/124253477/221392424-3454c8da-a7b5-48a7-add6-9e9b751fc3b4.png)
