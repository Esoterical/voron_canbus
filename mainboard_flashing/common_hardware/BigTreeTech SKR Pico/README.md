
# CanBOOT Config

![image](https://user-images.githubusercontent.com/124253477/221390508-c6fdd63a-f4af-46e1-b100-ee90dd723bf8.png)

# Klipper USB-CAN-Bridge when using CanBOOT or stock bootloader

![image](https://user-images.githubusercontent.com/124253477/221390518-b7f15c58-6beb-43bd-a47b-d6823956e997.png)

# Klipper USB-CAN-Bridge when **NOT** using CanBOOT or stock bootloader

![image](https://user-images.githubusercontent.com/124253477/221390533-cdc390ca-eaaf-4771-a9b7-cad1d2cbfaee.png)

# NOTES
You will need a seperate CAN Transceiver board, such as the SN65VHD230:

![image](https://user-images.githubusercontent.com/124253477/221390554-0cf82868-2157-4f14-bdcf-168e59c8f22d.png)

The Can Tx and Can Rx will be connected to the IO0 and IO1 port which is commonly used for the UART Pi connection. You can also hook up the Gnd and 5v from this port to the transceiver board (don't worry the SN65VHD230 may be marked as 3.3v but it can handle up to 6V on the Vin)

![image](https://user-images.githubusercontent.com/124253477/221390636-6342067f-1a2a-4b18-99a4-d33441dab933.png)





