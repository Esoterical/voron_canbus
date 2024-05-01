#!/bin/sh

# Directories and files
KLIPPYLOG="$HOME/printer_data/logs/klippy.log"
SESSIONLOG="Session Log Unavailable"

disclaimer() {
	echo "*************"
	echo "* Attention *"
	echo "*************"
	echo
	echo "This script pulls the log data since the most recent klipper restart and"
       	echo "uploads the information to a public site where it may be viewed by others."
	echo "It may also be necessary to install an additional package to help facilitate"
	echo "this task. No personal or identifying information is included in the upload."
	echo "This script is available for review at: "
	echo "https://TBD"
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

# Retrieving info from klippy.log
if [ -f $KLIPPYLOG ]; then
	SESSIONLOG=$(tac $KLIPPYLOG | sed '/Start printer at /q' | tac)
	KLIPPERCFG=$(echo "$SESSIONLOG" | awk '/^===== Config file/{m=1;next}/^[=]+$/{m=0}m')
	KLIPPYMSGS=$(echo "$SESSIONLOG" | awk '/^[=]+$/,EOF' | tail +2)
else
	echo "Log file not found: $KLIPPYLOG"
	exit 1
fi

LOG="$(prepout "Klippy Messages" "$KLIPPYMSGS")\n$(prepout "Klipper Config" "$KLIPPERCFG")"

if nc -z -w 3 termbin.com 9999; then
	echo "Uploading...\n"
	LOGURL=$(echo "$LOG" | nc termbin.com 9999)
	echo "Information available at the following URL:"
	echo "$LOGURL" 
else

	echo "Upload Failed"
	exit 1;
fi
