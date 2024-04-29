#!/bin/sh

if nc -z -w 3 termbin.com 9299; then
    echo "termbin OK"
else
    echo "termbin NOK"
fi

if nc -z -w 3 foobar.com 9999; then
    echo "foobar OK"
else
    echo "foobar NOK"
fi


#Credit to @bolliostu for the original idea and script
#Credit to @dormouse for a whole lot, including making the script not look like hot garbage

# Directories and files
KATAPULTDIR="$HOME/katapult"
CANBOOTDIR="$HOME/CanBoot"
KLIPPERDIR="$HOME/klipper"
KLIPPYLOG="$HOME/printer_data/logs/klippy.log"

# Default responses 
CAN0STATS="No can0 interface"
CAN0QUERY="No can0 interface"    
CAN0IFACE="/etc/network/interfaces.d/can0 Not Found"
BYID="/dev/serial/by-id Not Found"

BOOTLOADERDIRFND="Not Found"
BOOTLOADERFND="Not Found"
BOOTLOADERVER="Unknown"
KLIPPERDIRFND="Not Found"
KLIPPERFND="Not Found"
KLIPPERVER="Unknown"

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
MODEL="$(cat /sys/firmware/devicetree/base/model)"
DISTRO="$(cat /etc/*-release)"
KERNEL="$(uname -a)"
UPTIME="$(uptime)"

IFACESERVICE="$(ls /etc/network)"
SYSTEMD="$(ls /etc/systemd/network)"
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
RCLOCAL="$(cat /etc/rc.local)"

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
	PRNTDATAFND="$(tac $KLIPPYLOG | grep -m 1 "MCU 'mcu' config" $KLIPPYLOG)"
	KLIPPERCFG="$(tac $KLIPPYLOG | awk '/=======================/&&++k==1,/===== Config file =====/' | tac)"
       
	# ADC temp check
	MIN_TEMP=-10
	MAX_TEMP=400
	ADC=$(tac $KLIPPYLOG | grep -m 1 "^Stats" | sed 's/\([a-zA-Z0-9_.]*\)\:/\n\1:/g' |
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
		}'
	)
fi

# Sending to termbin and obtaining link.
echo "Uploading...\n"
# echo "$(prepout "OS" "Model:\n${MODEL}" "Distro:\n${DISTRO}" "Kernel:\n${KERNEL}" "Uptime:\n${UPTIME}") 
# $(prepout "Network" "Interface Services:\n${IFACESERVICE}" "Systemd Network Files:\n${SYSTEMD}" "ip a:\n${IPA}")
# $(prepout "can0" "status:\n${CAN0STATUS}" "file:\n${CAN0IFACE}" "ifstats:\n${CAN0STATS}" "Query:\n${CAN0QUERY}")
# $(prepout "rc.local contents" "${RCLOCAL}")
# $(prepout "USB / Serial" "lsusb:\n${LSUSB}" "/dev/serial/by-id:\n${BYID}")
# $(prepout "MCU" "MCUInfo:\n${PRNTDATAFND}")
# $(prepout "Temperature Check" "${ADC}")
# $(prepout "Bootloader" "Directory: ${BOOTLOADERDIRFND}" "Version: ${BOOTLOADERVER}" "Make Config: ${BOOTLOADERFND}")
# $(prepout "Klipper" "Directory: ${KLIPPERDIRFND}" "Version: ${KLIPPERVER}" "Make Config: $KLIPPERFND")
# $(prepout "KlipperConfig" "${KLIPPERCFG}")" |
	# nc termbin.com 9999 | { read url; echo "Information available at the following URL:"; echo "$url"; }

# echo "$(prepout "OS" "Model:\n${MODEL}" "Distro:\n${DISTRO}" "Kernel:\n${KERNEL}" "Uptime:\n${UPTIME}")" > /tmp/esodebug.txt 
# echo "$(prepout "Network" "Interface Services:\n${IFACESERVICE}" "Systemd Network Files:\n${SYSTEMD}" "ip a:\n${IPA}")" >> /tmp/esodebug.txt 
# echo "$(prepout "can0" "status:\n${CAN0STATUS}" "file:\n${CAN0IFACE}" "ifstats:\n${CAN0STATS}" "Query:\n${CAN0QUERY}")" >> /tmp/esodebug.txt 
# echo "$(prepout "rc.local contents" "${RCLOCAL}")" >> /tmp/esodebug.txt 
# echo "$(prepout "USB / Serial" "lsusb:\n${LSUSB}" "/dev/serial/by-id:\n${BYID}")" >> /tmp/esodebug.txt 
# echo "$(prepout "MCU" "MCUInfo:\n${PRNTDATAFND}")" >> /tmp/esodebug.txt 
# echo "$(prepout "Temperature Check" "${ADC}")" >> /tmp/esodebug.txt 
# echo "$(prepout "Bootloader" "Directory: ${BOOTLOADERDIRFND}" "Version: ${BOOTLOADERVER}" "Make Config: ${BOOTLOADERFND}")" >> /tmp/esodebug.txt 
# echo "$(prepout "Klipper" "Directory: ${KLIPPERDIRFND}" "Version: ${KLIPPERVER}" "Make Config: $KLIPPERFND")" >> /tmp/esodebug.txt 
# echo "$(prepout "KlipperConfig" "${KLIPPERCFG}")" >> /tmp/esodebug.txt 

echo "$(prepout "OS" "Model:\n${MODEL}" "Distro:\n${DISTRO}" "Kernel:\n${KERNEL}" "Uptime:\n${UPTIME}") 
$(prepout "Network" "Interface Services:\n${IFACESERVICE}" "Systemd Network Files:\n${SYSTEMD}" "ip a:\n${IPA}")
$(prepout "can0" "status:\n${CAN0STATUS}" "file:\n${CAN0IFACE}" "ifstats:\n${CAN0STATS}" "Query:\n${CAN0QUERY}")
$(prepout "rc.local contents" "${RCLOCAL}")
$(prepout "USB / Serial" "lsusb:\n${LSUSB}" "/dev/serial/by-id:\n${BYID}")
$(prepout "MCU" "MCUInfo:\n${PRNTDATAFND}")
$(prepout "Temperature Check" "${ADC}")
$(prepout "Bootloader" "Directory: ${BOOTLOADERDIRFND}" "Version: ${BOOTLOADERVER}" "Make Config: ${BOOTLOADERFND}")
$(prepout "Klipper" "Directory: ${KLIPPERDIRFND}" "Version: ${KLIPPERVER}" "Make Config: $KLIPPERFND")
$(prepout "KlipperConfig" "${KLIPPERCFG}")" > /tmp/esodebug.txt
	

echo "Output can be found at /tmp/esodebug.txt "
