# BOOT Mode

To put the SB2040 into boot mode (for initial flashing), unplug any USB and CAN cables from the SB2040, then hold the BOOT button. While continuing to hold the BOOT button plug in the USB cable from the Pi to the SB2040. Keep holding the BOOT button for a few more second, then release. The SB2040 should now show up to an `lsusb` command as Pi RP2 Boot device:

![image](https://user-images.githubusercontent.com/124253477/226155004-2cc63e48-4545-46c0-92ed-b09cd26c8e80.png)


# CanBOOT Config

![image](https://user-images.githubusercontent.com/124253477/221348610-0bff3f39-e340-46a7-b1ef-15a35013247e.png)

# Klipper when using CanBOOT

![image](https://user-images.githubusercontent.com/124253477/221348650-b9f2749e-0f3b-44b4-b34a-a57bd8beb706.png)


# Klipper when **NOT** using CanBOOT

![image](https://user-images.githubusercontent.com/124253477/221348953-de98e788-734d-4e34-b9dd-1b2a0e99607c.png)

# Sample Config

A sample config file can be found at https://mellow-3d.github.io/fly-sb2040_klipper_config.html

# More Info

https://mellow-3d.github.io/fly-sb2040_v1_general.html
