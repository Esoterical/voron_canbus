# BOOT Mode


To put the SB2209 into boot mode (for initial flashing), unplug any USB and CAN cables from the SB2040, then put the 5v jumper in place so the board can receive power over the USB connection:

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/e8daeabf-3c85-45cb-89e3-0735cca961dd)

Plug a USB cable from the pi to the SB2209 then hold down the BOOT button, breifly press the RST button (while still holding BOOT), wait a few seconds, then release the BOOT button. The SB2209 should now show up to an `lsusb` command as Pi RP2 Boot device:

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/fda3a72c-b255-46fd-ab11-938c92844d42)



# Katapult Config

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/385cf2be-e3a2-4b74-8eaa-824c91d442f7)


# Klipper when using Katapult

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/aac98e3a-472f-4934-9000-13de6e66849e)



# Klipper when **NOT** using Katapult

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/72c34057-2c5e-46ff-9d87-05dddf013b27)

# Sample Config

A sample config file can be found at https://github.com/bigtreetech/EBB/tree/master/EBB%20SB2209%20CAN%20(RP2040)


