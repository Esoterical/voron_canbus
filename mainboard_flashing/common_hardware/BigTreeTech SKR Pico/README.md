---
layout: default 
title: BigTreeTech SKR Pico
parent: Common Mainboard Hardware
grand_parent: Mainboard Flashing
---

# 120 ohm Termination Resistor

As the SKR Pico requires an [external CAN transciever](#transceiver) there is no built in 120ohm resistor on the Pico itself. The transceiver you use will likely have the 120r resistor hard soldered already, but some may have jumpers or solder pads to add/remove it from the circuit.


# Katapult Config

![image](https://user-images.githubusercontent.com/124253477/221390508-c6fdd63a-f4af-46e1-b100-ee90dd723bf8.png)

# Klipper USB-CAN-Bridge Config

![image](https://user-images.githubusercontent.com/124253477/221390518-b7f15c58-6beb-43bd-a47b-d6823956e997.png)

# Transceiver
You will need a seperate CAN Transceiver board, such as the TJA1050:

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/2df10f80-8239-4368-9aa4-e1abe9ded541)


The Can Tx and Can Rx will be connected to the IO0 and IO1 port which is commonly used for the UART Pi connection. You can also hook up the Gnd and 5v from this port to the transceiver board.

![image](https://user-images.githubusercontent.com/124253477/221390636-6342067f-1a2a-4b18-99a4-d33441dab933.png)





