#!/bin/sh

TEMPFILE=sendit

alias tb="(exec 3<>/dev/tcp/termbin.com/9999; cat >&3; cat <&3; exec 3<&-)"

echo "================================\nOS Details\n================================\nDistro:" >> $TEMPFILE
echo "$(cat /etc/*-release)\n" >> $TEMPFILE

kern=$(uname -r)
echo "Kernel:\n${kern}" >> $TEMPFILE

echo "\n\n================================\nNetwork Config\n================================\n/etc/network/interfaces.d/can0 Output:" >> $TEMPFILE
if [ -f /etc/network/interfaces.d/can0 ]; then
    cat /etc/network/interfaces.d/can0 >> $TEMPFILE
else
    echo "/etc/network/interfaces.d/can0 does not exist" >> $TEMPFILE
fi
echo '\n"ip a" Output:' >> $TEMPFILE
ip a >> $TEMPFILE

echo "\n\n================================\nUSB\n================================\nlsusb Output:" >> $TEMPFILE

lsusb >>$TEMPFILE

echo "Please post the following link to Discord https://discord.gg/voron #can_bus_depot:"

cat $TEMPFILE | tb
rm $TEMPFILE
