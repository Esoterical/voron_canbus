#!/bin/sh

#Credit to @bolliostu for the original idea and script
#Credit to @dormouse for a whole lot, including making the script not look like hot garbage

# Directories and files
KATAPULTDIR="$HOME/katapult"
CANBOOTDIR="$HOME/CanBoot"
KLIPPERDIR="$HOME/klipper"
KLIPPYLOG="$HOME/printer_data/logs/klippy.log"

# Default responses 
MODEL="Unknown"
DISTRO="Unknown"
KERNEL="Unknown"
UPTIME="Unknown"

IFACESERVICE="Directory Not Found"
SYSTEMD="Directory Not Found"
IPA="Interfaces Not Found"

CAN0STATUS="Unknown"
CAN0IFACE="/etc/network/interfaces.d/can0 Not Found"
CAN0STATS="No can0 interface"
CAN0QUERY="No can0 interface"    

RCLOCAL="/etc/rc.local Not Found"
BYID="/dev/serial/by-id Not Found"

BOOTLOADERDIRFND="Not Found"
BOOTLOADERFND="Not Found"
BOOTLOADERVER="Unknown"
KLIPPERDIRFND="Not Found"
KLIPPERFND="Not Found"
KLIPPERVER="Unknown"

KLIPPERCFG="Not Found"
KLIPPYMSGS="Not Found"
MCUCONFIGS="Not Found"
ADC="Klipper Log Not Found"

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


# Formatting function for output sections
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

if [ -f /sys/firmware/devicetree/base/model ]; then
	MODEL="$(cat /sys/firmware/devicetree/base/model)"
fi

if [ ! -z "$(ls /etc/*-release)" ]; then
	DISTRO="$(cat /etc/*-release)"
fi

KERNEL="$(uname -a)"
UPTIME="$(uptime)"

if [ -d /etc/network ]; then
	IFACESERVICE="$(ls /etc/network)"
fi

if [ -d /etc/systemd/network ]; then
	if [ ! -z "$(ls /etc/systemd/network)" ]; then
		SYSTEMD="$(ls /etc/systemd/network)"
	else
		SYSTEMD="Empty Directory"
	fi
fi

IPA="$(ip a)"

# Checking can0 interface configuration.
if [ -f /etc/network/interfaces.d/can0 ]; then
	CAN0IFACE=$(cat /etc/network/interfaces.d/can0)
fi

if ip l l can0 > /dev/null 2>&1; then
	CAN0STATS="$(ip -d -s l l can0)"
	CAN0UPDOWN="$(echo "$CAN0STATS" | grep -m 1 -o 'state [A-Z]*')"
	CAN0STATE="$(echo "$CAN0STATS" | grep -m 1 -o 'can state [A-Z-]*')"
	CAN0BITRATE="$(echo "$CAN0STATS" | grep -m 1 -o 'bitrate [0-9]*')"
	CAN0QLEN="$(echo "$CAN0STATS" | grep -m 1 -o 'qlen [0-9]*')"
	CAN0STATUS="$(echo "  $CAN0UPDOWN"; echo "  $CAN0STATE"; echo "  $CAN0BITRATE"; echo "  $CAN0QLEN";)"

	if [ "$CAN0UPDOWN" = "state UP" ]; then
		CAN0QUERY="$(~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0)"
	else
		CAN0QUERY="Unable to query can0 - DOWN"
	fi
fi

# Contents of rc.local
if [ -f /etc/rc.local ]; then 
	RCLOCAL="$(cat /etc/rc.local)"
fi

LSUSB="$(lsusb)"

if [ -d /dev/serial/by-id ]; then
	BYID="$(ls -l /dev/serial/by-id | tail -n +2 | awk '{print $9,$10,$11}')"
fi

# Retrieving katapult bootloader compilation configuration.
if [ -d ${KATAPULTDIR} ]; then
    BOOTLOADERDIRFND="${KATAPULTDIR}";
	if [ -f ${KATAPULTDIR}/.config ]; then
		BOOTLOADERFND="\n$(cat ${KATAPULTDIR}/.config)"
		cd ${KATAPULTDIR}
		BOOTLOADERVER="$(git describe --tags)"
	fi

# Retrieving CanBoot bootloader compilation configuration if katapult not there.
elif [ -d ${CANBOOTDIR} ]; then
	BOOTLOADERDIRFND="${CANBOOTDIR}"
	if [ -f ${CANBOOTDIR}/.config ]; then
		BOOTLOADERFND="\n$(cat ${CANBOOTDIR}/.config)"
		cd ${CANBOOTDIR}
		BOOTLOADERVER="$(git describe --tags)"
	fi
fi;

# Retrieving klipper firmware compilation configuration.
if [ -d ${KLIPPERDIR} ]; then
    KLIPPERDIRFND="${KLIPPERDIR}";
	if [ -f ${KLIPPERDIR}/.config ]; then
		KLIPPERFND="\n$(cat ${KLIPPERDIR}/.config)"
		if command -v git > /dev/null 2>&1; then
			cd ${KLIPPERDIR}
			KLIPPERVER="$(git describe --tags)"
		fi
	fi
fi

# Retrieving info from klippy.log
if [ -f $KLIPPYLOG ]; then
	SESSIONLOG=$(tac $KLIPPYLOG | sed '/Start printer at /q' | tac)
	KLIPPERCFG=$(echo "$SESSIONLOG" | awk '/^===== Config file/{m=1;next}/^[=]+$/{m=0}m')
	KLIPPYMSGS=$(echo "$SESSIONLOG" | awk '/^[=]+$/,EOF' | tail +2)
	MCUCONFIGS=$(echo "$SESSIONLOG" | awk '/^Loaded MCU/,/^MCU/')
	STARTUPMSGS=$(echo "$KLIPPYMSGS" | grep -E -v '^MCU|^Loaded MCU|^Stats' | head -100)

	# ADC temp check
	MIN_TEMP=-10
	MAX_TEMP=400
	ADC=$(echo "$SESSIONLOG" | tac | grep -m 1 "^Stats" | sed 's/\([a-zA-Z0-9_.]*\)\:/\n\1:/g' |
		awk -v mintemp="$MIN_TEMP" -v maxtemp="$MAX_TEMP" '/temp=/ {
			printf "%18s ", $1;
			for (i=2; i<=split($0, stat, " "); i++) {
				if (sub(/^.*temp=/, "", stat[i])) {
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
		} END { if (j == 0) { printf "No Temperature Data Available\n"; } }'
	)
fi

LOG="$(prepout "Klippy Messages" "$KLIPPYMSGS")\n$(prepout "Klipper Config" "$KLIPPERCFG")"

DEBUG="$(prepout "OS" "Model:\n${MODEL}" "Distro:\n${DISTRO}" "Kernel:\n${KERNEL}" "Uptime:\n${UPTIME}") 
	$(prepout "Network" "Interface Services:\n${IFACESERVICE}" "Systemd Network Files:\n${SYSTEMD}" "ip a:\n${IPA}")
	$(prepout "can0" "status:\n${CAN0STATUS}" "file:\n${CAN0IFACE}" "ifstats:\n${CAN0STATS}" "Query:\n${CAN0QUERY}")
	$(prepout "rc.local contents" "${RCLOCAL}")
	$(prepout "USB / Serial" "lsusb:\n${LSUSB}" "/dev/serial/by-id:\n${BYID}")
	$(prepout "MCU Configs" "${MCUCONFIGS}")
	$(prepout "Temperature Check" "${ADC}")
	$(prepout "Startup Messages" "${STARTUPMSGS}")
	$(prepout "Bootloader" "Directory: ${BOOTLOADERDIRFND}" "Version: ${BOOTLOADERVER}" "Make Config: ${BOOTLOADERFND}")
	$(prepout "Klipper" "Directory: ${KLIPPERDIRFND}" "Version: ${KLIPPERVER}" "Make Config: $KLIPPERFND")"

if nc -z -w 3 termbin.com 9999; then
	echo "Uploading...\n"
	LOGURL=$(echo "$LOG" | nc termbin.com 9999)
	sleep 1
	DEBUGURL=$(echo "$DEBUG\n$(prepout "Klippy Log Details" "$LOGURL")" | nc termbin.com 9999)
	echo "Information available at the following URL:"
	echo "$DEBUGURL" 
else
	if [ -d $HOME/printer_data/logs ]; then
		LOGPATH=$HOME/printer_data/logs
	else
		LOGPATH=/tmp
	fi
	TIMESTAMP=$(date "+%Y%m%d-%H%M%S")
	DEBUGFILE="$LOGPATH/esodebug-$TIMESTAMP.txt"
	LOGFILE="$LOGPATH/esolog-$TIMESTAMP.txt"
	echo "Unable to connect to termbin.com. Outputting to local file instead..."
	echo "$DEBUG" > $DEBUGFILE
	echo "$LOG" > $LOGFILE
 	echo "debug: $DEBUGFILE"
	echo "log: $LOGFILE"
fi
