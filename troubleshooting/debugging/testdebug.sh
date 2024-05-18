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

showhelp() {
	echo "Usage: can_debug.sh [-f logfile] [-n]"
	echo "Options:"
	echo "	-f logfile	Override default klippy.log file"
	echo "	-h		Help"
	echo "	-n		Dry-run: no disclaimer, saves, or uploads"
}

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

dashedline() {
	char=$1
	count=$2
	printf "$char%.0s" $(seq $count)
	printf "\n"
}

prepout() {
	echo
	dashedline "=" 64
	echo $1;
	dashedline "=" 64
	echo
	# shift the first array entry $1 (Header) and iterate through remaining 
	shift
	for var in "$@"; do echo "$var\n"; done
}

#######################################

while getopts hf:n flag; do
	case "$flag" in
		h)	showhelp;
			exit;;
		f)	KLIPPYLOG=${OPTARG};;
		n)	DRYRUN=1;;
	esac
done

if [ ! $DRYRUN ]; then
	disclaimer;
	checknc;
fi

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
		if [ -z "$CAN0QUERY" ]; then
			CAN0QUERY="Total 0 uuids found"
		fi	
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
		BOOTLOADERFND="$(grep -v "^#" ${KATAPULTDIR}/.config | awk NF)"
		cd ${KATAPULTDIR}
		BOOTLOADERVER="$(git describe --tags)"
	fi

# Retrieving CanBoot bootloader compilation configuration if katapult not there.
elif [ -d ${CANBOOTDIR} ]; then
	BOOTLOADERDIRFND="${CANBOOTDIR}"
	if [ -f ${CANBOOTDIR}/.config ]; then
		BOOTLOADERFND="$(grep -v "^#" ${CANBOOTDIR}/.config | awk NF)"
		cd ${CANBOOTDIR}
		BOOTLOADERVER="$(git describe --tags)"
	fi
fi

BL_STATS="Directory: $BOOTLOADERDIRFND\nVersion: $BOOTLOADERVER"
BL_VIEW=""

if [ ! "$BOOTLOADERFND" = "Not Found" ]; then
	BL_BOARD_DIRECTORY="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_BOARD_DIRECTORY=\"([[:alnum:]]+)\"/\1/p')"
	BL_MCU="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_MCU=\"([[:alnum:]]+)\"/\1/p')"
	BL_LAUNCH_APP_ADDRESS="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_LAUNCH_APP_ADDRESS=([0-9x]+)/\1/p')"
	BL_FLASH_APPLICATION_ADDRESS="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_FLASH_APPLICATION_ADDRESS=([0-9x]+)/\1/p')"
	BL_USB="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_USB=y/1/p')"
	BL_CANBUS="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_CANBUS=y/1/p')"
	BL_CANBUS_FREQUENCY="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_CANBUS_FREQUENCY=([0-9]+)/\1/p')"
	BL_INITIAL_PINS="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_INITIAL_PINS="([[:alnum:],]*)"/\1/p')"
	if [ $BL_INITIAL_PINS ]; then
		BL_ENTRY="$BL_INITIAL_PINS"
	else
		BL_ENTRY="None"
	fi
	BL_ENABLE_DOUBLE_RESET="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_ENABLE_DOUBLE_RESET=y/1/p')"
	if [ $BL_ENABLE_DOUBLE_RESET ]; then
		BL_DBL_CLICK="Y"
	else
		BL_DBL_CLICK="N"
	fi
	BL_ENABLE_LED="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_ENABLE_LED=y/1/p')"
	BL_STATUS_LED_PIN="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_STATUS_LED_PIN="([[:alnum:],]*)"/\1/p')"
	if [ $BL_ENABLE_LED ]; then
		BL_LED="$BL_STATUS_LED_PIN"
	else
		BL_LED="None"
	fi
	BL_BUILD_DEPLOYER="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_BUILD_DEPLOYER=y/1/p')"


	if [ "$BL_BOARD_DIRECTORY" = "stm32" ]; then

		BL_STM32_CLOCK_REF="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_STM32_CLOCK_REF_([[:alnum:]]+)M=y/\1/p')"
		if [ -z $BL_STM32_CLOCK_REF ]; then
			BL_STM32_CLOCK_REF="Internal Clock"
		else
			BL_STM32_CLOCK_REF="$BL_STM32_CLOCK_REF Mhz"
		fi	

		BL_STM32_USB="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_STM32_USB_([[:alnum:]_]+)=y/\1/p')"
		BL_STM32_CANBUS="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_STM32_CANBUS_([[:alnum:]_]+)=y/\1/p')"
	
		BL_OFFSET="$(printf '%d' $((($BL_LAUNCH_APP_ADDRESS - 0x8000000)/1024)))"
		if [ $BL_OFFSET -ne 0 ]; then
			BL_OFFSET="$BL_OFFSET KiB"
		else
			BL_OFFSET="None"
		fi

		BL_DEPLOYER="$(printf '%d' $((($BL_FLASH_APPLICATION_ADDRESS - 0x8000000)/1024)))"
		if [ $BL_BUILD_DEPLOYER ]; then
			BL_DEPLOYER="$BL_DEPLOYER KiB"
		else
			BL_DEPLOYER="None"
		fi

		if [ $BL_USB ]; then
			BL_COMMS="USB ($BL_STM32_USB)"
		elif [ $BL_CANBUS ]; then
			BL_COMMS="CANBus Pins: $BL_STM32_CANBUS - Bitrate: $BL_CANBUS_FREQUENCY"
		else
			BL_COMMS="UNKNOWN"
		fi

		BL_VIEW="${BL_VIEW:+${BL_VIEW}}Processor: $BL_MCU (${BL_STM32_CLOCK_REF})\n"
        	BL_VIEW="${BL_VIEW:+${BL_VIEW}}Offset: $BL_OFFSET | Deployer: $BL_DEPLOYER\n"
		BL_VIEW="${BL_VIEW:+${BL_VIEW}}Comms: $BL_COMMS\n"
		BL_VIEW="${BL_VIEW:+${BL_VIEW}}Entry Pins: $BL_ENTRY | 2xReset: $BL_DBL_CLICK | LED: $BL_LED" 

	elif [ "$BL_BOARD_DIRECTORY" = "rp2040" ]; then

		BL_RP2040_FLASH="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_RP2040_FLASH_([[:alnum:]]+)=y/\1/p')"
		BL_RP2040_CANBUS_GPIO_RX="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_RP2040_CANBUS_GPIO_RX=([0-9]+)/\1/p')"
		BL_RP2040_CANBUS_GPIO_TX="$(echo "$BOOTLOADERFND" | sed -nr 's/CONFIG_RP2040_CANBUS_GPIO_TX=([0-9]+)/\1/p')"
		BL_RP2040_CANBUS_GPIO="${BL_RP2040_CANBUS_GPIO_RX}/${BL_RP2040_CANBUS_GPIO_TX}"

		BL_DEPLOYER="$(printf '%d' $((($BL_FLASH_APPLICATION_ADDRESS - 0x10000000)/1024)))"
		if [ $BL_BUILD_DEPLOYER ]; then
			BL_DEPLOYER="$BL_DEPLOYER KiB"
		else
			BL_DEPLOYER="None"
		fi

		if [ $BL_USB ]; then
			BL_COMMS="USB"
		elif [ $BL_CANBUS ]; then
			BL_COMMS="CAN RX/TX: ${BL_RP2040_CANBUS_GPIO} ($BL_CANBUS_FREQUENCY bps)"
		else
			BL_COMMS="UNKNOWN"
		fi

		BL_VIEW="${BL_VIEW:+${BL_VIEW}}Processor: $BL_MCU (${BL_RP2040_FLASH})\n"
        	BL_VIEW="${BL_VIEW:+${BL_VIEW}}Deployer: $BL_DEPLOYER\n"
		BL_VIEW="${BL_VIEW:+${BL_VIEW}}Comms: $BL_COMMS\n"
		BL_VIEW="${BL_VIEW:+${BL_VIEW}}Entry Pins: $BL_ENTRY | 2xReset: $BL_DBL_CLICK | LED: $BL_LED" 
	else
		BL_VIEW="${BL_VIEW:+${BL_VIEW}}Quickview Unavailable"
	fi
fi

# Retrieving klipper firmware compilation configuration. 
if [ -d ${KLIPPERDIR} ]; then
	KLIPPERDIRFND="${KLIPPERDIR}";
	if [ -f ${KLIPPERDIR}/.config ]; then
 		KLIPPERFND="$(grep -v "^#" ${KLIPPERDIR}/.config | awk NF)"
		if command -v git > /dev/null 2>&1; then
			cd ${KLIPPERDIR}
			KLIPPERVER="$(git describe --tags)"
		fi
	fi
fi

FW_STATS="Directory: $KLIPPERDIRFND\nVersion: $KLIPPERVER"
FW_VIEW=""

if [ ! "$KLIPPERFND" = "Not Found" ]; then
	FW_BOARD_DIRECTORY="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_BOARD_DIRECTORY=\"([[:alnum:]]+)\"/\1/p')"
	FW_MCU="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_MCU=\"([[:alnum:]]+)\"/\1/p')"
	FW_FLASH_APPLICATION_ADDRESS="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_FLASH_APPLICATION_ADDRESS=([0-9x]+)/\1/p')"
	FW_USBCANBUS="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_USBCANBUS=y/1/p')"
	FW_USB="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_USB=y/1/p')"
	FW_CANBUS="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_CANBUS=y/1/p')"
	FW_CANBUS_FREQUENCY="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_CANBUS_FREQUENCY=([0-9]+)/\1/p')"
	FW_INITIAL_PINS="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_INITIAL_PINS="([[:alnum:],]*)"/\1/p')"
	if [ $FW_INITIAL_PINS ]; then
		FW_ENTRY="$FW_INITIAL_PINS"
	else
		FW_ENTRY="None"
	fi

	if [ "$FW_BOARD_DIRECTORY" = "stm32" ]; then
		FW_STM32_CLOCK_REF="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_STM32_CLOCK_REF_([[:alnum:]]+)M=y/\1/p')"
		if [ -z $FW_STM32_CLOCK_REF ]; then
			FW_STM32_CLOCK_REF="Internal Clock"
		else
			FW_STM32_CLOCK_REF="$FW_STM32_CLOCK_REF Mhz"
		fi	

		FW_STM32_USBCANBUS="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_STM32_USBCANBUS_([[:alnum:]_]+)=y/\1/p')"
		FW_STM32_USB="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_STM32_USB_([[:alnum:]_]+)=y/\1/p')"
		FW_STM32_CANBUS="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_STM32_CANBUS_([[:alnum:]_]+)=y/\1/p')"

		FW_OFFSET="$(printf '%d' $((($FW_FLASH_APPLICATION_ADDRESS - 0x8000000)/1024)))"
		if [ $FW_OFFSET -ne 0 ]; then
			FW_OFFSET="$FW_OFFSET KiB"
		else
			FW_OFFSET="None"
		fi

		if [ $FW_USBCANBUS ]; then
			FW_COMMS="Bridge USB ($FW_STM32_USBCANBUS} CAN ($FW_STM32_CANBUS)"
		elif [ $FW_USB ]; then
			FW_COMMS="USB ($FW_STM32_USB)"
		elif [ $FW_CANBUS ]; then
			FW_COMMS="CANBus Pins: $FW_STM32_CANBUS - Bitrate: $FW_CANBUS_FREQUENCY"
		else
			FW_COMMS="UNKNOWN"
		fi

		FW_VIEW="${FW_VIEW:+${FW_VIEW}}Processor: $FW_MCU (${FW_STM32_CLOCK_REF})\n"
        	FW_VIEW="${FW_VIEW:+${FW_VIEW}}Offset: $FW_OFFSET\n"
		FW_VIEW="${FW_VIEW:+${FW_VIEW}}Comms: $FW_COMMS\n"
		FW_VIEW="${FW_VIEW:+${FW_VIEW}}Entry Pins: $FW_ENTRY"
		
	elif [ "$FW_BOARD_DIRECTORY" = "rp2040" ]; then

		FW_RP2040_CANBUS_GPIO_RX="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_RP2040_CANBUS_GPIO_RX=([0-9]+)/\1/p')"
		FW_RP2040_CANBUS_GPIO_TX="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_RP2040_CANBUS_GPIO_TX=([0-9]+)/\1/p')"
		FW_RP2040_CANBUS_GPIO="${FW_RP2040_CANBUS_GPIO_RX}/${FW_RP2040_CANBUS_GPIO_TX}"
		FW_RP2040_HAVE_BOOTLOADER="$(echo "$KLIPPERFND" | sed -nr 's/CONFIG_RP2040_HAVE_BOOTLOADER=y/1/p')"
		if [ $FW_RP2040_HAVE_BOOTLOADER ]; then
			FW_OFFSET="$(printf '%d KiB' $((($FW_FLASH_APPLICATION_ADDRESS - 0x10000000)/1024)))"
		else
			FW_OFFSET="None"
		fi

		if [ $FW_USBCANBUS ]; then
			FW_COMMS="Bridge USB CAN RX/TX: ${FW_RP2040_CANBUS_GPIO} ($FW_CANBUS_FREQUENCY bps)"
		elif [ $FW_USB ]; then
			FW_COMMS="USB"
		elif [ $FW_CANBUS ]; then
			FW_COMMS="CAN RX/TX: ${FW_RP2040_CANBUS_GPIO} ($FW_CANBUS_FREQUENCY bps)"
		else
			FW_COMMS="UNKNOWN"
		fi

		FW_VIEW="${FW_VIEW:+${FW_VIEW}}Processor: $FW_MCU\n"
        	FW_VIEW="${FW_VIEW:+${FW_VIEW}}Offset: $FW_OFFSET\n"
		FW_VIEW="${FW_VIEW:+${FW_VIEW}}Comms: $FW_COMMS\n"
		FW_VIEW="${FW_VIEW:+${FW_VIEW}}Entry Pins: $FW_ENTRY"

	else
		FW_VIEW="${FW_VIEW:+${FW_VIEW}}Quickview Unavailable"
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
			j=0;
			for (i=2; i<=split($0, stat, " "); i++) {
				if (sub(/^.*temp=/, "", stat[i])) {
					printf "%6s", stat[i];
					if (stat[i] + 0 < mintemp ) {
						printf "%s", "    *** Check Sensor ***";
					} else if (stat[i] + 0 > maxtemp) {
						printf "%s", "    *** Check Sensor ***";
					}
					j++;
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
	$(prepout "Bootloader" "${BL_STATS}" "${BL_VIEW}" "Make Config:\n${BOOTLOADERFND}")
	$(prepout "Klipper" "${FW_STATS}" "${FW_VIEW}" "Make Config:\n${KLIPPERFND}")"

if [ $DRYRUN ] ; then
	echo "Dumping output...\n"
	echo "$DEBUG"
	echo "$LOG"
elif nc -z -w 3 termbin.com 9999; then
	echo "Uploading...\n"
	LOGURL=$(echo "$LOG" | nc termbin.com 9999)
	sleep 1
	DEBUGURL=$(echo "$DEBUG\n$(prepout "Klippy Log Details" "$LOGURL")" | nc termbin.com 9999)
	echo "Information available at the following URL:"
	echo "$DEBUGURL" 
else
	echo "Unable to connect to termbin.com. Outputting to local file instead..."
	if [ -d $HOME/printer_data/logs ]; then
		LOGPATH=$HOME/printer_data/logs
	else
		LOGPATH=/tmp
	fi
	TIMESTAMP=$(date "+%Y%m%d-%H%M%S")
	DEBUGFILE="$LOGPATH/esodebug-$TIMESTAMP.txt"
	LOGFILE="$LOGPATH/esolog-$TIMESTAMP.txt"
	echo "$DEBUG" > $DEBUGFILE
	echo "$LOG" > $LOGFILE
 	echo "debug: $DEBUGFILE"
	echo "log: $LOGFILE"
fi
