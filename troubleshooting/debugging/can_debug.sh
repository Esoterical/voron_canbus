#!/bin/sh

#Credit to @bolliostu for the original idea and script

# Checks for nc command and installs modern version of netcat on Debian based systems if not found.
if ! command -v nc > /dev/null 2>&1 ; then
    echo "NetCat not found on system"
    echo "Installing Netcat with 'sudo apt-get install netcat-openbsd -qq > /dev/null'"
    sudo apt-get install netcat-openbsd -qq > /dev/null
fi

# Definition of commands to be be run to obtain relavent information regarding CAN bus configuration.
PRETTY_LINE_BRK="================================================================"
DISTRO="$(cat /etc/*-release)"
KERNEL="$(uname -a)"
IFACESERVICE="$(ls /etc/network)"
IPA="$(ip a)"
CANSTATS="$(ip -d -s link show can0)"
LSUSB="$(lsusb)"
# BITVERSION="$(getconf LONG_BIT)"
CANQUERY="$(~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0)"


# Identification of directories pertainent to CAN fw compilation files.
KATAPULTDIR="/home/$USER/katapult/"
CANBOOTDIR="/home/$USER/CanBoot/"
CANFND="NOT Found"

# List of systemd filess.
SYSTEMD="$(ls /etc/systemd/network)"


KLIPPERDIR="/home/$USER/klipper/"
KLIPPERFND="NOT Found"

PRNTDATA="/home/$USER/printer_data/logs"
PRNTDATAFND="NOT Found"
#grep "MCU 'mcu' config" ~/printer_data/logs/klippy.log | tail -1

# Checking Linux Network configuration.
if [ -f /etc/network/interfaces.d/can0 ]; then
    NETWORK=$(cat /etc/network/interfaces.d/can0)
else
    NETWORK="can0 network not found in /etc/network/interfaces.d/"
fi

# Retrieving bootloader compilation configuration.
if [ -d ${KATAPULTDIR} ]; then
    if [ -f ${KATAPULTDIR}/.config ]; then
        CANFND="Found\n\nKatapult Config:\n$(cat ${KATAPULTDIR}/.config)"
    else
        CANFND="Found\n\nKatapult Make Config: Not Found"
    fi
elif [ -d ${CANBOOTDIR} ]; then
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

# Retrieving mcu info from klippy log
if [ -d ${PRNTDATA} ]; then
    if [ -f ${PRNTDATA}/klippy.log ]; then
        PRNTDATAFND="Found\n\nKlippy Log:\n$(grep "MCU 'mcu' config" ~/printer_data/logs/klippy.log | tail -1)"
        KLIPPERCFG="$(tac ~/printer_data/logs/klippy.log | awk '/=======================/&&++k==1,/===== Config file =====/' | tac)"
    else
        PRNTDATAFND="Found\n\nKlippy Log: Not Found"
        KLIPPERCFG="Found\n\nKlippy Log: Not Found"
    fi
fi
# Formatting outpur
#TXT_OS="${PRETTY_LINE_BRK}\nOS\n${PRETTY_LINE_BRK}\n\nDistro:\n${DISTRO}\n\nKernel:\n${KERNEL}\n\nBits:\n${BITVERSION}"
TXT_OS="${PRETTY_LINE_BRK}\nOS\n${PRETTY_LINE_BRK}\n\nDistro:\n${DISTRO}\n\nKernel:\n${KERNEL}"
TXT_NET="\n\n${PRETTY_LINE_BRK}\nNetwork\n${PRETTY_LINE_BRK}\n\nInterface Services:\n${IFACESERVICE}\n\ncan0:\n${NETWORK}\n\nip a:\n${IPA}\n\ncan0 ifstats:\n${CANSTATS}" 
TXT_SYSD="\n\n${PRETTY_LINE_BRK}\nSystemd Network Files\n${PRETTY_LINE_BRK}\n\n${SYSTEMD}"
TXT_USB="\n\n${PRETTY_LINE_BRK}\nUSB\n${PRETTY_LINE_BRK}\n\nlsusb:\n${LSUSB}"
TXT_CANQ="\n\n${PRETTY_LINE_BRK}\nCANQuery\n${PRETTY_LINE_BRK}\n\nCANBus Query:\n${CANQUERY}"
TXT_LOG="\n\n${PRETTY_LINE_BRK}\nMCU\n${PRETTY_LINE_BRK}\n\nMCUInfo:\n${PRNTDATAFND}"
TXT_CAN="\n\n${PRETTY_LINE_BRK}\nKatapult\n${PRETTY_LINE_BRK}\n\nKatapult Directory: ${CANFND}"
TXT_KLP="\n\n${PRETTY_LINE_BRK}\nKlipper\n${PRETTY_LINE_BRK}\n\nKlipper Directory: ${KLIPPERFND}"
TXT_CFG="\n\n${PRETTY_LINE_BRK}\nKlipperConfig\n${PRETTY_LINE_BRK}\n\n${KLIPPERCFG}"


# Reminding user of nice place to get help and letting them know the termbin link.
echo "The following link will have your information:"

# Sending to termbin and obtaining link.
echo "${TXT_OS} ${TXT_NET} ${TXT_SYSD} ${TXT_USB} $TXT_CANQ ${TXT_LOG} ${TXT_CAN} ${TXT_KLP} ${TXT_CFG}" | nc termbin.com 9999
