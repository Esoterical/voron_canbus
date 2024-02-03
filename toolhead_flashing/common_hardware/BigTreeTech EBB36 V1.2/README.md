# 120 ohm Termination Resistor

The header for the 120R termination resistor is circled in purple

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/64dc58a0-bd77-4da2-bd55-a58bd25dfacf)


# CAN port wiring

![EBB36_PowerConnector2](https://github.com/Esoterical/voron_canbus/assets/124253477/5d915c3b-ce41-417a-bf05-887c1da230cd)


# DFU Mode
1.  Add a jumper as shown in the image below so the board can be powered via a USB connection
    ![image](https://user-images.githubusercontent.com/124253477/226155159-06afd94e-01fb-4256-89ec-10e59d236eac.png)

2. Connect your device to your Pi via USB
3. Press and hold the `RESET` and `BOOT` buttons down (button locations shown in step 1)
    1. Release `RESET` button
    2. Release `BOOT` button
4. The device should now be in DFU mode. Verify this via the `lsusb` command, which should look something like this:
    ```
    Bus 001 Device 005: ID 0483:df11 STMicroelectronics STM Device in DFU Mode
    ```

# Katapult Config

![image](https://user-images.githubusercontent.com/124253477/228764838-d75c7bc4-a27f-4c3a-b6c8-ef0e78f49f4f.png)


# Klipper Config

![image](https://user-images.githubusercontent.com/124253477/221349102-cd2f4060-9c29-44aa-b722-9883262b2fc3.png)


# Sample Configuration

A sample configuration file can be found at https://github.com/bigtreetech/EBB/tree/master/EBB%20CAN%20V1.1%20(STM32G0B1)
