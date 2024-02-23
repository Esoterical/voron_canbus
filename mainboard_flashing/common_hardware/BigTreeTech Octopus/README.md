---
layout: default 
title: BigTreeTech Octopus
parent: Common Mainboard Hardware
grand_parent: Mainboard Flashing
---

# 120 ohm Termination Resistor

There is a permanent 120 ohm termination resistor soldered to the board, no need to add a jumper to enable it and also no ability to disable it.

# DFU Mode

To put the octopus into DFU mode you need to put in the boot jumper (purple) and press the reset button (green). The blue is for the "power over USB" jumper and isn't needed if you already have 24v hooked up to the octopus.

![image](https://user-images.githubusercontent.com/124253477/229234235-345ff23e-cc9e-4d61-ab7e-3df27dda1eb5.png)


**The BTT Octopus comes in many variations of MCU chip. Make sure you pick the correct config for the MCU chip you have**

# STM32F446
## Katapult Config

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/673ce3c6-5bd7-48a8-bcd4-99aeefb0f0a2)

## Klipper USB-CAN-Bridge Config

![image](https://user-images.githubusercontent.com/124253477/221378034-ac82a51e-6ba7-4288-8186-91a6733dbd2f.png)


# STM32F429
## Katapult Config

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/41d4bfe5-ed20-4956-93fd-cb3b99250aae)

## Klipper USB-CAN-Bridge Config

![image](https://user-images.githubusercontent.com/124253477/221378352-e22e8719-6a26-499a-9f9f-375c0baa1cd6.png)


# STM32F407
## Katapult Config

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/ec17d20a-2aba-4cc5-809f-aa1748a76a63)

## Klipper USB-CAN-Bridge Config

![image](https://user-images.githubusercontent.com/124253477/221378459-561064a6-deaa-4590-85b9-058f480871e2.png)


# STM32H723
## Katapult Config

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/e9850f4a-d4d9-438b-8b95-3fd21cd790d8)

## Klipper USB-CAN-Bridge Config

![image](https://user-images.githubusercontent.com/124253477/221378502-d3aee8c7-c4ba-42da-838b-3e64cfc6262d.png)
