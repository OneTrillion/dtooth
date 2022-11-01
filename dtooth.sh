#!/bin/bash

# Maybe add:
# Go though array and delete all mac address (46-85-10-D1-AE-9A) type names
# If there are any errors make a i3 style error window 

bctl="bluetoothctl"
IFS=' '
declare -A devicesList;

# Scan for devices
$bctl --timeout 4 -- scan on

# Loop though all scanned devices
while read line 
	do
		# Array of raw input from bctl devices
		read -ra rawInfo <<< "$line"

		dMac=${rawInfo[1]}
		dName=""
		
		# Concatenate names with spaces in to one string
		for ((i = 2 ; i < ${#rawInfo[@]} ; i++))
			do
				dName+="${rawInfo[$i]}"
			done

		devicesList+=(["$dName"]="$dMac")
	done <<< $($bctl -- devices)

# Puts device names in dmenu format
dmenuFormat=""
for device in "${!devicesList[@]}"
	do
		dmenuFormat+="$device\n"
	done

res=$(echo -e $dmenuFormat | dmenu)
resVal=${devicesList[$res]}

# Attempts to pair based on device mac-address
$bctl -- pair $resVal

sleep 2 

# Attempts to connect to device 
$bctl -- connect $resVal
