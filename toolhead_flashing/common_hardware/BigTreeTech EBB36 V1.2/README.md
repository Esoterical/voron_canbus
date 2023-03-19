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

# CanBOOT Config

![image](https://user-images.githubusercontent.com/124253477/221349624-69abcf3e-dfd8-48d0-b4f6-0ebd620f6b42.png)


# Klipper when using CanBOOT

![image](https://user-images.githubusercontent.com/124253477/221349102-cd2f4060-9c29-44aa-b722-9883262b2fc3.png)


# Klipper when **NOT** using CanBOOT

![image](https://user-images.githubusercontent.com/124253477/221349111-570dedac-fa9b-4706-b0d3-3bbc773461f0.png)

# Sample Configuration

A sample configuration file can be found at https://github.com/bigtreetech/EBB/tree/master/EBB%20CAN%20V1.1%20(STM32G0B1)
