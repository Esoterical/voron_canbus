# Klipper USB to CAN bus bridge

The second way of setting up a CAN network is to use the printer mainboard itself as a CAN adapter.

**If you are using a dedicated CAN adapter as outlined [here](./Dedicated_USB_Can_Device.md) then you don't need this step. Your mainboard will be flashed the same as any other "normal" klipper install**

This is acheived through Klippers "USB-CAN-Bridge mode". In order for this to work you need to have a compatible MCU on the mainboard (A lot of the popular STM32 chips works, as well as the RP2040), and either a dedicated "CAN" port on the motherboard or at least a way of accessing the CAN pins that you configure for klipper.

Some mainboards (like the BTT Octopus) have a CAN Transceiver built in so they will output CAN signals directly from a dedicated port (the Octopus has an RJ11 port for this purpose). Other compatible boards may have a port on their board labelled as CAN but only output serial (Tx Rx) signals. These boards can still be run as USB-CAN-Bridge mode but will require an additional CAN Transceiver module (such as the SN65HVD230). These can be cheaply purchased from Amazon or eBay or AliExpress. Other boards may yet not have any dedicated CAN port, but still have a compatible MCU and have compatible CAN pins that you can access (the SKR Mini E3 V3 can be run in USB-CAN-Bridge mode if you use the PB8/PB9 pins on the EXP1 header that is normally used for an LCD screen).

[Click here to start flashing your mainboard to USB-CAN-Bridge Klipper](./mainboard_flashing)