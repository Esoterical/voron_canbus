# Katapult Config

![image](https://user-images.githubusercontent.com/124253477/221349790-d073d222-1061-4c81-a7eb-796a8693b621.png)

# Klipper USB-CAN-Bridge when using Katapult or stock bootloader

![image](https://user-images.githubusercontent.com/124253477/221349817-d7381c21-fecc-4111-a34b-bf0522cd456e.png)

# Klipper USB-CAN-Bridge when **NOT** using Katapult or stock bootloader

![image](https://user-images.githubusercontent.com/124253477/221349849-b78db57a-fe2d-461e-a026-10112071a60e.png)

# NOTES
You will need a seperate CAN Transceiver board, such as the SN65VHD230:

![image](https://user-images.githubusercontent.com/124253477/221390554-0cf82868-2157-4f14-bdcf-168e59c8f22d.png)

The Can Rx and Can Tx will be connected to the PD0 and PD1 port (which is labelled as the CAN port). You can also hook up the Gnd and 5v from this port to the transceiver board (don't worry the SN65VHD230 may be marked as 3.3v but it can handle up to 6V on the Vin)

![image](https://user-images.githubusercontent.com/124253477/221390921-e1fa8675-347a-4fda-8217-95b9f872acc7.png)







