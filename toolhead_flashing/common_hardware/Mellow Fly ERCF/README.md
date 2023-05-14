# BOOT Mode

To put the ERCF into boot mode (for initial flashing), unplug any USB and CAN cables from the ERCF, then hold the BOOT button. While continuing to hold the BOOT button plug in the USB cable from the Pi to the ERCF. Keep holding the BOOT button for a few more second, then release. 

![image](img/dfu-mode.png)

The ERCF should now show up to an `lsusb` command as Pi RP2 Boot device:

![image](https://user-images.githubusercontent.com/124253477/226155004-2cc63e48-4545-46c0-92ed-b09cd26c8e80.png)


# CanBOOT Config

![image](./img/canboot.png)

# Klipper when using CanBOOT

![image](./img/klipper-canboot.png)


# Klipper when **NOT** using CanBOOT

![image](./img/klipper-only.png)

# Sample Config

A sample config file can be found at https://mellow.klipper.cn/#/board/fly_ercf/cfg

# More Info

https://mellow.klipper.cn/#/board/fly_ercf/
