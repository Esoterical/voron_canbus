#!/bin/sh

#Credit to @bolliostu for the original idea and script
#Credit to @dormouse for a whole lot, including making the script not look like hot garbage

# Directories and files
KATAPULTDIR="$HOME/katapult"
CANBOOTDIR="$HOME/CanBoot"
KLIPPERDIR="$HOME/klipper"
KLIPPYLOG="$HOME/printer_data/logs/klippy.log"

# Default responses 
CANSTATS="No can0 interface"
CANQUERY="No can0 interface"    
BYID="/dev/serial/by-id Not Found"
CAN0IFACE="/etc/network/interfaces.d/can0 Not Found"

BOOTLOADERDIRFND="Not Found"
BOOTLDRFND="Not Found"
KLIPPERDIRFND="Not Found"
KLIPPERFND="Not Found"
KLIPPERVER="Klipper not installed"

MCUINFOFND="Not Found"
PRNTDATAFND="Not Found"
KLIPPERCFG="Not Found"
ADC="Data Unavailable"

disclaimer() {
	echo "*************"
	echo "* Attention *"
	echo "*************"
	echo
	echo "This script will run a series of diagnostic commands to gather configuration"
	echo "information about this host and upload it to a public site where it may be"
	echo "viewed by others. It will contain no personal information."
	echo "It may also be necessary to install an additional package to help facilitate"
	echo "this task.  This script is available for review at: "
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
}

checknc() {
	# Checks for nc command and installs modern version of netcat on Debian based systems if not found.
	if ! command -v nc > /dev/null 2>&1 ; then
		echo "NetCat not found on system"
		echo "Installing Netcat with 'sudo apt-get install netcat-openbsd -qq > /dev/null'"
		sudo apt-get install netcat-openbsd -qq > /dev/null
	fi
}


# Formatting fuction for output sections
# Usage: prepout <HEADER> [SUBSECTION...]

prepout() {
	echo
	echo "================================================================";
	echo $1;
	echo "================================================================\n";
	# shift the first array entry $1 (Header) and iterate through remaining 
	shift
	for var in "$@"; do echo "$var\n"; done
}

#######################################

disclaimer;
checknc;

echo "\nGathering Data...\n"

# Definition of commands to be be run to obtain relevant information regarding CAN bus configuration.
MODEL="$(cat /sys/firmware/devicetree/base/model)"
DISTRO="$(cat /etc/*-release)"
KERNEL="$(uname -a)"
UPTIME="$(uptime)"
IFACESERVICE="$(ls /etc/network)"
IPA="$(ip a)"

if ip a | grep -q -E "can0"; then
	CANSTATS="$(ip -d -s link show can0)"
	CANQUERY="$(~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0)"
fi

LSUSB="$(lsusb)"

if [ -d /dev/serial/by-id ]; then
	BYID="$(ls -l /dev/serial/by-id | awk '{print $9,$10,$11}')"
fi

# BITVERSION="$(getconf LONG_BIT)"

# List of systemd filess.
SYSTEMD="$(ls /etc/systemd/network)"

# Contents of rc.local
RCLOCAL="$(cat /etc/rc.local)"

#grep "MCU 'mcu' config" $KLIPPYLOG | tail -1

# Checking Linux Network configuration.
if [ -f /etc/network/interfaces.d/can0 ]; then
	CAN0IFACE=$(cat /etc/network/interfaces.d/can0)
fi

# Retrieving katapult bootloader compilation configuration.
if [ -d ${KATAPULTDIR} ]; then
    BOOTLOADERDIRFND="Found";
	if [ -f ${KATAPULTDIR}/.config ]; then
		BOOTLOADERFND="\n$(cat ${KATAPULTDIR}/.config)"
	fi
# Retrieving CanBoot bootloader compilation configuration if katapult not there.
elif [ -d ${CANBOOTDIR} ]; then
	BOOTLOADERDIRFND="Found"
	if [ -f ${CANBOOTDIR}/.config ]; then
		BOOTLOADERFND="\n$(cat ${CANBOOTDIR}/.config)"
	fi
fi;

# Retrieving klipper firmware compilation configuration.
if [ -d ${KLIPPERDIR} ]; then
    KLIPPERDIRFND="Found";
	if [ -f ${KLIPPERDIR}/.config ]; then
		KLIPPERFND="\n$(cat ${KLIPPERDIR}/.config)"
		if command -v git > /dev/null 2>&1; then
            cd ~/klipper
            KLIPPERVER="$(git describe --tags)"
        fi
	fi
fi

# Retrieving info from klippy.log
if [ -f $KLIPPYLOG ]; then
	MCUINFOFND="Found"
	PRNTDATAFND="$(grep "MCU 'mcu' config" $KLIPPYLOG | tail -1)"
	KLIPPERCFG="$(tac $KLIPPYLOG | awk '/=======================/&&++k==1,/===== Config file =====/' | tac)"
       
	# ADC temp check
	MIN_TEMP=-10
	MAX_TEMP=400
	ADC=$(tac $KLIPPYLOG | grep -m 1 "^Stats" | sed 's/\([a-zA-Z0-9_.]*\)\:/\n\1:/g' |
		awk -v mintemp="$MIN_TEMP" -v maxtemp="$MAX_TEMP" '/temp=/ {
			printf "%18s ", $1;
			for (i=2; i<=split($0, stat, " "); i++) {
				#printf "%s", stat;
				if (sub(/temp=/, "", stat[i])) {
					printf "%6s", stat[i];
					if (stat[i] + 0 < mintemp ) {
						printf "%s", "    *** Check Sensor ***";
					} else if (stat[i] + 0 > maxtemp) {
						printf "%s", "    *** Check Sensor ***";
					}
					break;
				}
			}
			printf "\n";
		}'
	)
fi

# Sending to termbin and obtaining link.
echo "Uploading...\n"
echo "$(prepout "OS" "Model:\n${MODEL}" "Distro:\n${DISTRO}" "Kernel:\n${KERNEL}" "Klipper Version:\n${KLIPPERVER}" "Uptime:\n${UPTIME}") 
$(prepout "Network" "Interface Services:\n${IFACESERVICE}" "can0:\n${CAN0IFACE}" "ip a:\n${IPA}" "can0 ifstats:\n${CANSTATS}")
$(prepout "Systemd Network Files" "${SYSTEMD}")
$(prepout "rc.local contents" "${RCLOCAL}")
$(prepout "USB" "lsusb:\n${LSUSB}")
$(prepout "Dev Serial By-ID" "Dev Serial By-ID:\n${BYID}")
$(prepout "CANQuery" "CANBus Query:\n${CANQUERY}")
$(prepout "MCU" "MCUInfo:\n${MCUINFOFND}" "Klippy Log:\n${PRNTDATAFND}")
$(prepout "Temperature Check" "${ADC}")
$(prepout "Bootloader" "Bootloader Directory: ${BOOTLOADERDIRFND}" "Bootloader Make Config: ${BOOTLOADERFND}")
$(prepout "Klipper" "Klipper Directory: ${KLIPPERDIRFND}" "Klipper Make Config: $KLIPPERFND")
$(prepout "KlipperConfig" "${KLIPPERCFG}")" |
	nc termbin.com 9999 | { read url; echo "Information available at the following URL:"; echo "$url"; }
