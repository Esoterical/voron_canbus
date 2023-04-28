#!/bin/sh

TEMPFILE=sendit

if ! which nc >/dev/null; then
    sudo apt install netcat
fi


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

cat $TEMPFILE | nc termbin.com 9999
rm $TEMPFILE
