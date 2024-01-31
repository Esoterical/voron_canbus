# Final Steps

So your CAN network is now running and you can see the CAN boards on it, everything is coming up Milhouse.

The last few things you need to do are to [check your termination resistors](#120r-termination-resistors) and [update your printer config](#update-config).

# 120R Termination Resistors

A CANBus expects both ends of the CanH/CanL wire run to be terminated with a 120 ohm resistor bridging the High and Low wires. Your CAN board will almost certainly have provisions for this somewhere.

**Note**

You want to have **two** of these termination resistors in your CANBus circuit. **No more, No less**. Running with too many connected can be just as bad as running with none.

Now, ideally these resistors are placed at the very start and end of your CAN network, but in reality the scale we are working with on 3d printers is so small compared to what CANBus is designed for it ends up not really mattering in practice.

If you only have a single USB CAN adapter (or usb-can-bridge mainboard) and a single toolhead, then just have the 120R on each. If you are running multiple toolheads (eg. in an IDEX setup) running back to the same source (eg. a U2C), then have the jumpers on each toolhead and **not** on the "source" board.

If your setup is all randomly connected, then just pick the two "most edge" boards in the system to have the 120 ohm resistors on.

## CAN Adapter/Mainboard

Some boards (Like the BTT Octopus) have the 120 ohm resistor permenantly connceted across the CanH/L wires, so nothing you need to do there. Others will have a two-pin header (sometimes labelled "120R") that you can put a jumper on and this will bring the termination resistor into the circuit.

The same can be said for dedicated USB CAN adapters (like the U2C). Most will have a a header that you can put a jumper on to enable the resistor.

## Toolhead

Nearly all Toolheads will have a two-pin header (sometimes labelled 120R) that you can put a jumper on to bring the 120 ohm resistor into the circuit.


# Update Config

You will need to add some settings to your printer.cfg in order for Klipper (on the Pi) to actually talk to your new CAN nodes.

If you are running a dedicated USB Can adapter (like a U2C) then you don't need to do anything for this device, it won't be used/seen in the printer.cfg.

If you are running a USB-CAN-Bridge Mainboard, then you will need to now set your main [mcu] section to use the UUID of your mainboard (that you found in [this step](./mainboard_flashing#klipper-is-now-installed))

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/11040725-aa0f-4f98-bb8d-df4420320096)


Note that the mainboard **must** be simply called [mcu]. And also note that there is no `restart_method` or anything else in this section, just the `canbus_uuid`.

For your toolhead, you will need to add a new mcu section but as this is a ["extra" mcu](https://www.klipper3d.org/Config_Reference.html#mcu-my_extra_mcu) you need to give it a name. The name is arbitrary, but keeping it similar to what the manufacturer uses in their sample config files makes it easier later.

eg. if I called my board "EBBCan", then I would have the [mcu EBBCan] section with the UUID of my toolhead (that you found in [this step](./toolhead_flashing#klipper-is-now-installed))

![image](https://github.com/Esoterical/voron_canbus/assets/124253477/4f3d2478-490b-41d9-8ee1-322d4a7f8117)


If you have completed the above and have the canbus uuid of your CAN device in your printer.cfg, then everything else is just a case of setting up the required pins with the toolhead MCU name prefixed to the pin name. 

Most toolheads will have a sample.cfg on their github, so it's usually a simple case of copy-pasting the required information from the sample into your own printer.cfg.

