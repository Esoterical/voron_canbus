#!/bin/sh

#Credit to @bolliostu for the original idea and script
#Credit to @dormouse for the disclaimer and spelling

echo "*************"
echo "* Attention *"
echo "*************"
echo
echo "This script will run a series of diagnostic commands to gather configuration"
echo "information about this host and upload it to a public site where it may be"
echo "viewed by others. It will contain no personal information."
echo "It may also be necessary to install an additional package"
echo "to help facilitate this task."
echo "You can view this script at:"
echo "https://github.com/Esoterical/voron_canbus/blob/main/troubleshooting/debugging/can_debug.sh"
echo

while true; do
    read -p "Do you wish to run this program? (yes/no) " yn < /dev/tty
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "Confirmed script execution"


# Checks for nc command and installs modern version of netcat on Debian based systems if not found.
if ! command -v nc > /dev/null 2>&1 ; then
    echo "NetCat not found on system"
    echo "Installing Netcat with 'sudo apt-get install netcat-openbsd -qq > /dev/null'"
    sudo apt-get install netcat-openbsd -qq > /dev/null
fi

# Definition of commands to be be run to obtain relavent information regarding CAN bus configuration.
PRETTY_LINE_BRK="================================================================"
MODEL="$(cat /sys/firmware/devicetree/base/model)"
DISTRO="$(cat /etc/*-release)"
KERNEL="$(uname -a)"
UPTIME="$(uptime)"
IFACESERVICE="$(ls /etc/network)"
IPA="$(ip a)"
CANSTATS="$(ip -d -s link show can0)"
LSUSB="$(lsusb)"
BYID="$(ls -l /dev/serial/by-id | awk -F' ' '{print $9,$10,$11}')"
# BITVERSION="$(getconf LONG_BIT)"
CANQUERY="$(~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0)"


# List of systemd filess.
SYSTEMD="$(ls /etc/systemd/network)"

# Contents of rc.local
RCLOCAL="$(cat /etc/rc.local)"

# Identification of directories pertainent to CAN fw compilation files.
KATAPULTDIR="/home/$USER/katapult/"
CANBOOTDIR="/home/$USER/CanBoot/"
CANFND="NOT Found"



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



# Retrieving info from klippy.log
if [ -d ${PRNTDATA} ]; then
    if [ -f ${PRNTDATA}/klippy.log ]; then
        PRNTDATAFND="Found\n\nKlippy Log:\n$(grep "MCU 'mcu' config" ~/printer_data/logs/klippy.log | tail -1)"
        KLIPPERCFG="$(tac ~/printer_data/logs/klippy.log | awk '/=======================/&&++k==1,/===== Config file =====/' | tac)"
        ADC=$(tac ~/printer_data/logs/klippy.log | grep -m 1 "^Stats" |
        awk '{
                for (i=1; i<=split($0, arr, ":"); i++) {
                        if (arr[i] ~ /temp=/) {
                                printf "%s: ", head[split(arr[i-1],head," ")];
                                for (j=1; j<=split(arr[i], keyval, " "); j++) {
                                        printf "%s", ((keyval[j] ~ /temp=/) ? keyval[j] : "");
                                }
                                printf "\n";
                        }
                }
        }')
    else
        PRNTDATAFND="Found\n\nKlippy Log: Not Found"
        KLIPPERCFG="Found\n\nKlippy Log: Not Found"
        ADC="Found\n\nKlippy Log: Not Found"
    fi
fi
if [ -d ${PRNTDATA} ]; then
    if [ -f ${PRNTDATA}/klippy.log ]; then
        KLIPPY_LOG=$HOME/printer_data/logs/klippy.log
        #KLIPPY_LOG=$HOME/dev/klippytemp/new.log
        MIN_TEMP=30
        MAX_TEMP=40
        
        TEMPERATURECHECK=$(tac ~/printer_data/logs/klippy.log | grep -m 1 "^Stats" | sed 's/\([a-zA-Z0-9_.]*\)\:/\n\1:/g' |
                awk -v mintemp="$MIN_TEMP" -v maxtemp="$MAX_TEMP" '/temp=/ {
                        printf "%18s ", $1;
                        for (i=2; i<=split($0, stat, " "); i++) {
                                if (sub(/temp=/, "", stat[i])) {
                                        printf "%6s", stat[i];
                                        if (stat[i] + 0 < mintemp ) {
                                                printf "%s", " <=min placeholder==";
                                        } else if (stat[i] + 0 > maxtemp) {
                                                printf "%s", " ==max placeholder=>";
                                        }
                                        break;
                                }
                        }
                        printf "\n";
                }')
    fi
fi
# Formatting outpur
#TXT_OS="${PRETTY_LINE_BRK}\nOS\n${PRETTY_LINE_BRK}\n\nDistro:\n${DISTRO}\n\nKernel:\n${KERNEL}\n\nBits:\n${BITVERSION}"
TXT_OS="${PRETTY_LINE_BRK}\nOS\n${PRETTY_LINE_BRK}\n\nModel:\n${MODEL}\n\nDistro:\n${DISTRO}\n\nKernel:\n${KERNEL}\n\nUptime:\n${UPTIME}"
TXT_NET="\n\n${PRETTY_LINE_BRK}\nNetwork\n${PRETTY_LINE_BRK}\n\nInterface Services:\n${IFACESERVICE}\n\ncan0:\n${NETWORK}\n\nip a:\n${IPA}\n\ncan0 ifstats:\n${CANSTATS}" 
TXT_SYSD="\n\n${PRETTY_LINE_BRK}\nSystemd Network Files\n${PRETTY_LINE_BRK}\n\n${SYSTEMD}"
TXT_RCL="\n\n${PRETTY_LINE_BRK}\nrc.local contents\n${PRETTY_LINE_BRK}\n\n${RCLOCAL}"
TXT_USB="\n\n${PRETTY_LINE_BRK}\nUSB\n${PRETTY_LINE_BRK}\n\nlsusb:\n${LSUSB}"
TXT_BYID="\n\n${PRETTY_LINE_BRK}\nDev Serial By-ID\n${PRETTY_LINE_BRK}\n\nDev Serial By-ID:\n${BYID}"
TXT_CANQ="\n\n${PRETTY_LINE_BRK}\nCANQuery\n${PRETTY_LINE_BRK}\n\nCANBus Query:\n${CANQUERY}"
TXT_LOG="\n\n${PRETTY_LINE_BRK}\nMCU\n${PRETTY_LINE_BRK}\n\nMCUInfo:\n${PRNTDATAFND}"
TXT_ADC="\n\n${PRETTY_LINE_BRK}\nTemperature Check\n${PRETTY_LINE_BRK}\n\n${ADC}"
TXT_TCHECK="\n\n${PRETTY_LINE_BRK}\nTest Temperature Check\n${PRETTY_LINE_BRK}\n\n${TEMPERATURECHECK}"
TXT_CAN="\n\n${PRETTY_LINE_BRK}\nKatapult\n${PRETTY_LINE_BRK}\n\nKatapult Directory: ${CANFND}"
TXT_KLP="\n\n${PRETTY_LINE_BRK}\nKlipper\n${PRETTY_LINE_BRK}\n\nKlipper Directory: ${KLIPPERFND}"
TXT_CFG="\n\n${PRETTY_LINE_BRK}\nKlipperConfig\n${PRETTY_LINE_BRK}\n\n${KLIPPERCFG}"


# Reminding user of nice place to get help and letting them know the termbin link.
echo "The following link will have your information:"

# Sending to termbin and obtaining link.
echo "${TXT_OS} ${TXT_NET} ${TXT_SYSD} ${TXT_RCL} ${TXT_USB} ${TXT_BYID} ${TXT_CANQ} ${TXT_LOG} ${TXT_ADC} ${TXT_TCHECK} ${TXT_CAN} ${TXT_KLP} ${TXT_CFG}" | nc termbin.com 9999
