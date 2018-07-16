#!/bin/bash


# Simulate network delay
printf "Welcome to the random network simulator:\n\n"

kill_all (){
	# Clearing the netem configuration
	for i in "${net_array[@]}"
	do
		sudo tc qdisc del dev "$i" root &> /dev/null
	done
}

network_array (){
	# Creating an array containing all network interfaces which are up
	net_array=()
        for iface in $(ifconfig | cut -d ' ' -f1| tr ':' '\n' | awk NF)
        do
                net_array+=("$iface")
        done
        unset "net_array[${#net_array[@]}-1]"
}

user_input (){
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

	# Maximum interval duation

	printf "\nPlease define the maximum time intervals you want to use in seconds:\n"
        read -r time_int

	while ! [[ "$time_int" =~ ^[0-9]+$ && "$time_int" -gt 0 ]]; do
                echo "Please enter a valid numerical maximum time interval in [s]:"
                read -r time_int
        done


	# Time Delay Setup

	echo "Please define the maximum time delay in [ms]:"
	read -r max_delay
	while ! [[ "$max_delay" =~ ^[0-9]+$ && "$max_delay" -ge 0 ]]; do
		echo "Please enter a valid numerical maximum time delay value in [ms]:"
		read -r max_delay
	done

	# Jitter Setup

	echo "Please define the maximum jitter in [ms]:"
	read -r max_jitter

	while ! [[ "$max_jitter" =~ ^[0-9]+$ && "$max_jitter" -ge '0' ]]; do
		echo "Please enter only a valid integer value for the maximum jitter greater or equal to 0ms:"
		read -r max_jitter
	done

	# Packet Loss Setup

	echo "Please define the maximum packet loss in [%]:"
	read -r max_ploss

	while ! [[ "$max_ploss" =~ ^[0-9]+$ && "$max_ploss" -lt '100' && "$max_ploss" -ge '0' ]]; do
		echo "Please enter a valid packet loss value in [%], between 0% and 100%:"
		read -r max_ploss
	done
}

confirmation (){
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

print_settings (){

	printf "\nThese are the set parameters:\n\n"
	printf "Selected Network interface:\t%s\n" "${user_iface}"
	printf "Maximum Time Interval:\t\t%ss\n" "${time_int}"
	printf "Maximum Delay:\t\t\t%sms\n" "${max_delay}"
	printf "Maximum Jitter:\t\t\t%sms\n" "${max_jitter}"
	printf "Maximum Packet Loss:\t\t${max_ploss}%%\n\n"
}

randgen () {
	if [[ $1 == 0 ]];then
		echo 0
	else
		echo "$((RANDOM % (("$1") + 1)))"
	fi
}

netemu (){
	rand_int="$(randgen "$time_int")"
	rand_delay="$(randgen "$max_delay")"
	rand_jitter="$(randgen "$max_jitter")"
	rand_ploss="$(randgen "$max_ploss")"
	if [[ "$rand_ploss" == 0 ]]; then
		sudo tc qdisc add dev "$user_iface" root netem delay "$rand_delay"ms "$rand_jitter"ms
		printf "Network interface: %s will be delayed with %sms and the jitter will be %sms for %s seconds.\n" "$user_iface" "$rand_delay" "$rand_jitter" "$rand_int"
	else
		sudo tc qdisc add dev "$user_iface" root netem delay "$rand_delay"ms "$rand_jitter"ms loss "$rand_ploss"%
		printf "Network interface: %s will be affected by %d%% packet loss, the RTT will be %dms and the jitter %dms for %s seconds.\n" "$user_iface" "$rand_ploss" "$rand_delay" "$rand_jitter" "$rand_int"
	fi
}

rand_netsim() {
	while :
	do
		kill_all
		netemu
		sleep "$rand_int"
		kill_all
		sleep "$rand_int"
	done
}

network_array
kill_all
user_input
print_settings
confirmation
print_settings
rand_netsim
