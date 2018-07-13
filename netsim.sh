#!/bin/bash


# Simulate network delay
printf "Welcome to the network simulator:\n\n"

function kill_all {
	# Clearing the netem configuration
	for i in "${net_array[@]}"
	do
		sudo tc qdisc del dev "$i" root &> /dev/null
	done
}

function network_array {
	# Creating an array containing all network interfaces which are up
	net_array=()
        for iface in $(ifconfig | cut -d ' ' -f1| tr ':' '\n' | awk NF)
        do
                net_array+=("$iface")
        done
        unset "net_array[${#net_array[@]}-1]"
}

function user_input {
	# Printing available interfaces

	printf "Here is a list of your network interfaces:\n\n"

	for iface in $(ifconfig | cut -d ' ' -f1| tr ':' '\n' | awk NF)
	do 
		addr=$(ip -o -4 addr list "$iface" | awk '{print $4}' | cut -d/ -f1)
		if [[ $iface != "lo" ]]
		then
			printf "$iface""%s\t""$addr""%s\n"
		fi
	done
	
	# Network Interface selection

	printf "\nPlease select the network interface you want to use:\n"
	read -r user_iface 

	while ! [[ "${net_array[*]}" =~ (^| )"$user_iface"( |$) ]]; do # check if the user input is valid
        	echo "Please enter a valid network interface:"
	        read -r user_iface
	done

	# Time Delay Setup

	echo "Please define the time delay in [ms]:"
	read -r delay
	while ! [[ "$delay" =~ ^[0-9]+$ && "delay" -ge 0 ]]; do
		echo "Please enter a valid numerical time delay value in [ms]:"
		read -r delay
	done

	# Jitter Setup

	echo "Please define the jitter in [ms]:"
	read -r jitter

	while ! [[ "$jitter" =~ ^[0-9]+$ && "$jitter" -ge '0' ]]; do
		echo "Please enter only a valid integer value for the jitter greater than 0ms:"
		read -r jitter
	done

	# Packet Loss Setup

	echo "Please define the packet loss in [%]:"
	read -r ploss

	while ! [[ "$ploss" =~ ^[0-9]+$ && "$ploss" -lt '100' && "$ploss" -ge '0' ]]; do
		echo "Please enter a valid packet loss value in [%], between 0% and 100%:"
		read -r ploss
	done
}

function confirmation {
        read -p "Please confirm that these values are correct [Y/n]:"$'\n' -r -n 1 choice
        case "$choice" in
	        y|Y|"" ) ;;
	        n|N ) printf "\nHere we go again:\n" 
			user_input
			print_settings
			confirmation;;
	        * ) printf "\nYou have entered invalid input!\n"
		        confirmation;;
esac
}


function print_settings {

	printf "\nThese are the set parameters:\n\n"
	printf "Network interface:\t%s\n" "${user_iface}"
	printf "Delay:\t\t\t%sms\n" "${delay}"
	printf "Jitter:\t\t\t%sms\n" "${jitter}"
	printf "Packet Loss:\t\t${ploss}%%\n\n"
}

function netemu {
	if [[ "$ploss" == 0 ]]; then
		sudo tc qdisc add dev "$user_iface" root netem delay "$delay"ms "$jitter"ms
	else
		sudo tc qdisc add dev "$user_iface" root netem delay "$delay"ms "$jitter"ms loss "$ploss"% 
	fi
}

network_array
kill_all
user_input
print_settings
confirmation
print_settings
netemu
