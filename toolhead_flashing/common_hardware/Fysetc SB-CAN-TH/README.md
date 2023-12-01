# DFU Mode

1. Power on your Pi
2. Disconnect the 24v CAN wires from the SB-CAN-TH as well as the USB cable (if connected) and wait at least 5 seconds
3. Connect the USB cable from Pi to SB-CAN-TH
4. Plug in the SB-CAN-TH 24v CAN wires to power the board
5. Run `dfu-util -l` on the Pi to confirm the SB-CAN-TH is showing up as a DFU device

Once it shows as a DFU you can flash to it. Once finished flashing disconnect both USB **and** the 24v power wires, wait 5 seconds, then plug in *only* the 24v/Ground/CAN wires (no USB)


# Katapult Config

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/ece9bd34-5165-4864-ba95-73e8b1846f94)


# Klipper when using Katapult

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/b38f1af9-cf9b-4173-9e30-06e0e0aa1d76)


# Klipper when **NOT** using Katapult

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/b89b23eb-f59a-4c1d-b23d-c6108d129ae9)

# Sample Configuration

A sample configuration file can be found at https://github.com/FYSETC/FYSETC_SB_CAN_TOOLHEAD
