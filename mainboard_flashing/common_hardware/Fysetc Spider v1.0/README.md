---
layout: default 
title: Fysetc Spider V1.0
parent: Common Mainboard Hardware
grand_parent: Mainboard Flashing
---

# 120 ohm Termination Resistor

As the Spider v1.0 requires an [external CAN transciever](#transceiver) there is no built in 120ohm resistor on the Spider itself. The transceiver you use will likely have the 120r resistor hard soldered already, but some may have jumpers or solder pads to add/remove it from the circuit.

# Katapult Config

![image](https://github.com/user-attachments/assets/3d8e589e-feaa-4695-9328-539dc8ac21c9)


# Klipper USB-CAN-Bridge Config

![image](https://user-images.githubusercontent.com/124253477/221349817-d7381c21-fecc-4111-a34b-bf0522cd456e.png)


# Transceiver
You will need a seperate CAN Transceiver board, such as the TJA1050:

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/2df10f80-8239-4368-9aa4-e1abe9ded541)


The Can Rx and Can Tx will be connected to the PD0 and PD1 port (which is labelled as the CAN port). You can also hook up the Gnd and 5v from this port to the transceiver board.

![image](https://user-images.githubusercontent.com/124253477/221392367-bc3c2d55-2869-4d79-9610-3f2bb0bf41dc.png)
