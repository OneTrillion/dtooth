#!/bin/bash

BCTL="bluetoothctl"
IFS=' '
MACREG='^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$'

declare -A devicesList;

notify-send -t 5000 -- 'Scanning for devices'

# Scan for devices
$BCTL --timeout 4 -- scan on

# Loop though all scanned devices
while read line 
	do
		# Array of raw input from BCTL devices
		read -ra rawInfo <<< "$line"

		# Igores all mac address type names
		[[ "${rawInfo[2]}" =~ $MACREG ]] && continue
		
		dName=""

		# Concatenate names with spaces in to one string
		for ((i = 2 ; i < ${#rawInfo[@]} ; i++))
			do
				dName+="${rawInfo[$i]}"
			done

		dMac=${rawInfo[1]}

		devicesList+=(["$dName"]="$dMac")
	done <<< $($BCTL -- devices)

# Puts device names in dmenu format
dmenuFormat=""
for device in "${!devicesList[@]}"
	do
		dmenuFormat+="$device\n"
	done

res=$(echo -e $dmenuFormat | dmenu)
[ -z "$res" ] && notify-send -t 5000 -- 'Error invalid input, exiting' && exit

resVal=${devicesList[$res]}

# Attempts to pair based on device mac-address
notify-send -t 5000 -- 'Attempting to pair device'
$BCTL -- pair $resVal

# Attempts to connect to device 
notify-send -t 5000 -- 'Attempting to connect to device'
$BCTL -- connect $resVal
