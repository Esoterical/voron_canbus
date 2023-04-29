#!/bin/sh

# Checks for nc command and installs modern version of netcat on Debian based systems if not found.
if ! command -v nc > /dev/null 2>&1 ; then
    echo "NetCat not found on system"
    echo "Installing Netcat with 'sudo apt install netcat-openbsd'"
    sudo apt install netcat-openbsd
fi

# Definition of commands to be be run to obtain relavent information regarding CAN bus configuration.
PRETTY_LINE_BRK="================================================================"
DISTRO="$(cat /etc/*-release)"
KERNEL="$(uname -a)"
IPA="$(ip a)"
LSUSB="$(lsusb)"

# Identification of directories pertainent to CAN fw compilation files.
CANBOOTDIR="/home/$USER/CanBoot/"
CANFND="NOT Found"

KLIPPERDIR="/home/$USER/klipper/"
KLIPPERFND="NOT Found"

# Checking Linux Network configuration.
if [ -f /etc/network/interfaces.d/can0 ]; then
    NETWORK=$(cat /etc/network/interfaces.d/can0)
else
    NETWORK="can0 network not found in /etc/network/interfaces.d/"
fi

# Retrieving bootloader compilation configuration.
if [ -d ${CANBOOTDIR} ]; then
    if [ -f ${CANBOOTDIR}/.config ]; then 
        CANFND="Found\n\nCanBoot Config:\n$(cat ${CANBOOTDIR}/.config)"
    else
        CANFND="Found\n\nCanBoot Make Config: Not Found"
    fi
fi

# Retrieving klipper firmware compilation configuration.
if [ -d ${KLIPPERDIR} ]; then
    if [ -f ${KLIPPERDIR}/.config ]; then 
        KLIPPERFND="Found\n\nKlipper Config:\n$(cat ${KLIPPERDIR}/.config)"
    else
        KLIPPERFND="Found\n\nKlipper Make Config: Not Found"
    fi
fi

# Formatting outpur
TXT_OS="${PRETTY_LINE_BRK}\nOS\n${PRETTY_LINE_BRK}\n\nDistro:\n${DISTRO}\n\nKernel:\n${KERNEL}"
TXT_NET="\n\n${PRETTY_LINE_BRK}\nNetwork\n${PRETTY_LINE_BRK}\n\ncan0:\n${NETWORK}\n\nip a:\n${IPA}"
TXT_USB="\n\n${PRETTY_LINE_BRK}\nUSB\n${PRETTY_LINE_BRK}\n\nlsusb:\n${LSUSB}"
TXT_CAN="\n\n${PRETTY_LINE_BRK}\nCanBoot\n${PRETTY_LINE_BRK}\n\nCanBoot Directory: ${CANFND}"
TXT_KLP="\n\n${PRETTY_LINE_BRK}\nKlipper\n${PRETTY_LINE_BRK}\n\nKlipper Directory: ${KLIPPERFND}"

# Reminding user of nice place to get help and letting them know the termbin link.
echo "Please post the following link to Discord https://discord.gg/voron #can_bus_depot:"

# Sending to termbin and obtaining link.
echo "${TXT_OS} ${TXT_NET} ${TXT_USB} ${TXT_CAN} ${TXT_KLP}" | nc termbin.com 9999
