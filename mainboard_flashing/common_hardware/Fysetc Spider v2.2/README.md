---
layout: default 
title: Fysetc Spider v2.2
parent: Common Mainboard Hardware
grand_parent: Mainboard Flashing
---

# 120 ohm Termination Resistor

As the Spider v2.2 requires an [external CAN transciever](#transceiver) there is no built in 120ohm resistor on the Spider itself. The transceiver you use will likely have the 120r resistor hard soldered already, but some may have jumpers or solder pads to add/remove it from the circuit.

# Katapult Config

![image](https://user-images.githubusercontent.com/124253477/221349790-d073d222-1061-4c81-a7eb-796a8693b621.png)

# Klipper USB-CAN-Bridge Config

![image](https://user-images.githubusercontent.com/124253477/221349817-d7381c21-fecc-4111-a34b-bf0522cd456e.png)


# Transceiver
You will need a seperate CAN Transceiver board, such as the TJA1050:

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/2df10f80-8239-4368-9aa4-e1abe9ded541)

The Can Rx and Can Tx will be connected to the PD0 and PD1 port (which is labelled as the CAN port). You can also hook up the Gnd and 5v from this port to the transceiver board.

![image](https://user-images.githubusercontent.com/124253477/221390921-e1fa8675-347a-4fda-8217-95b9f872acc7.png)







