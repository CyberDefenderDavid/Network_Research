#!/bin/bash
# Specify the username and ip address or hostname
User="cfc020823"
Hostname="157.245.52.40"
Password="cfc020823!"
#check sudo
function check_sudo(){
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo."
    exit 1
fi
}
# Function to check if tor is installed
function check_tor() {
    if command -v tor &>/dev/null; then
        echo "tor       is already installed"
    else
        echo "tor is not installed"
        echo "tor will be installed"
        sudo apt-get install tor -y &>/dev/null
        echo "tor successfully installed"
    fi
}
#Function to check if nipe is installed
function check_nipe() {
	#print nipe.pl path
	nipe_location=$(find / -type f -name nipe.pl 2>/dev/null)
	#if nipe.pl is found then
	if [ -n "$nipe_location" ]; then
        echo "nipe      is already installed"
    else
        echo "nipe is not installed"
        echo "nipe will be installed"
        # Desktop
		cd /home/kali/Desktop
		# Clone the "nipe" repository from GitHub into the folder
		git clone https://github.com/htrgouvea/nipe /home/kali/Desktop/nipe >/dev/null 2>&1
		# CD into nipe
		cd /home/kali/Desktop/nipe
		# Install the "cpanm" tool
		sudo apt-get install cpanminus -y >/dev/null 2>&1
		# Install Perl 
		sudo cpanm --installdeps . >/dev/null 2>&1
		# Install "nipe"
		sudo perl nipe.pl install >/dev/null 2>&1
		echo "nipe successfully installed"
    fi
}
# Function to check if namp is installed
function check_nmap() {
    if command -v nmap &>/dev/null; then
        echo "nmap      is already installed"
    else
        echo "namp is not installed"
        echo "nmap will be installed"
        sudo apt-get install namp -y &>/dev/null
        echo "nmap successfully installed"
    fi
}
# Function to check if whois is installed
function check_whois() {
    if command -v whois &>/dev/null; then
        echo "whois     is already installed"
    else
        echo "whois is not installed"
        echo "whois will be installed"
        sudo apt-get install whois -y &>/dev/null
        echo "whois successfully installed"
    fi
}
# Function to check if sshpass is installed
function check_sshpass() {
    if command -v sshpass &>/dev/null; then
        echo "sshpass   is already installed"
    else
        echo "sshpass is not installed"
        echo "sshpass will be installed"
        sudo apt-get install sshpass -y &>/dev/null
        echo "sshpass successfully installed"
    fi
}
# Function to check if geoip-bin is installed
function check_geoip_bin() {
    if command -v geoiplookup &>/dev/null; then
        echo "geoip-bin is already installed"
    else
        echo "geoip-bin is not installed" 
        echo "geoip-bin will be installed"
        sudo apt-get install geoip-bin -y &>/dev/null
        echo "geoip-bin successfully installed"
    fi
}
#start sudo perl nipe.pl
function start_nipe() {
	cd /home/kali/Desktop/nipe
    while true; do
    status_output=$(sudo perl nipe.pl status 2>&1) # Check status
    case "$status_output" in
            *"Status: true"*)
                #echo "Status: true"
                break
                ;;
            *"Status: false"*)
                #echo "Status: false"
                sudo perl nipe.pl start
                sudo perl nipe.pl restart
                ;;
            *"ERROR: sorry, it was not possible to establish a connection to the server."*)
                #echo "Status: error"
                sudo perl nipe.pl start
                sudo perl nipe.pl restart
                ;;
            *)
                #echo "Status: unknown"
                sudo perl nipe.pl start
                sudo perl nipe.pl restart
                ;;
		esac
	done
}
#check sudo perl nipe.pl status
function check_anonymous() {
	#congratulation = on tor network
	result=$(curl -s https://check.torproject.org/ | grep -o "Congratulations")
	if [[ -n "$result" ]]; then		
		spoofip=$(curl -s https://check.torproject.org/ | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'| head -n 1)
        spoofcountry=$(geoiplookup "$spoofip" | awk '{print $5, $6 ,$7}')
        echo "You are anonymous .. Connecting to the remote Server."
        echo " "
        echo "Your Spoofed IP address is: $spoofip, Spoofed country: $spoofcountry"
        read -p "Specify a Domain/IP address to scan: " input
    else
        echo "Network connection is NOT anonymous, exiting now."
        exit 1
    fi
}
# Function auto ssh
function auto_ssh() {
	local User="$1"
    local Hostname="$2"
    local Password="$3"
    output=$(sshpass -p "$Password" ssh -q -o "StrictHostKeyChecking=no" -T "$User@$Hostname" <<EOF
    
		#store uptime in $uptime 
        uptime=\$(uptime) #blackslash because of EQF
        #echo to store in $output, then to be grep 
        echo "Uptime: \$uptime" 
		
        # print the ip address and store as $ip_address
        ip_address=\$(curl -s ipinfo.io/ip) 
        #echo to store in $output, then to be grep 
        echo "IP address: \$ip_address" 
        
        #whois
        echo "start of whois $input"
        date "+%A, %B %d, %Y, %H:%M:%S"
        whois $input
        echo "end of whois $input" 
                
        #nmap
        nmap $input -p-
EOF
)
    #grep info from output 
    uptime=$(echo "$output" | grep 'Uptime:') # extract the uptime
    ip_address=$(echo "$output" | grep 'IP address:') #result is "IP address:" 
    ip_address_value=$(echo "$ip_address" | awk '{print $NF}')  # extract the IP address from the "IP Address:" line

	echo ""	
	#echo "$output" #for debugging
	echo "Connecting to Remote Server:"	
	echo "$uptime" 
	echo "$ip_address" 
	echo "Country: $(geoiplookup "$ip_address_value" | awk '{print $5, $6, $7}')"
	echo ""
}
#creating the input of whois & nmap to .txt
function whois_nmap() {
	#create dir for whois and nmap
	mkdir -p /home/kali/Desktop/nipe/whois
	mkdir -p /home/kali/Desktop/nipe/nmap
	mkdir -p /home/kali/Desktop/nipe/log
	
	#print pwd
	#desktop=$(pwd)	cannot use because of sudo
	#date+time
	datetime=$(date "+%a %b %d %I:%M:%S %p %Z %Y")
	#result of whois and nmap
	echo "$output" | awk '/start of whois/,/end of whois/' >> /home/kali/Desktop/nipe/whois/whois_$input.txt
	echo "$output" | awk '/Starting/,/seconds/' >> /home/kali/Desktop/nipe/nmap/nmap_$input.txt

	#echo where the whois data is saved
	echo "Whoising victim's address: "
	echo "Whois data was saved into /home/kali/Desktop/nipe/whois/whois_$input"
	echo ""
	
	#echo where the nmap data is saved
	echo "Scanning victim's address: "
	echo "Nmap scan was saved into /home/kali/Desktop/nipe/nmap/nmap_$input"
	
	# Append the date, time, and input to the log file
	echo "$datetime Nmap data collected for: $input" >> /home/kali/Desktop/nipe/log/nr.log
	echo "$datetime Whois data collected for: $input" >> /home/kali/Desktop/nipe/log/nr.log
}

# Call the functions #conside to create an app_list
check_sudo
check_tor
check_nipe
check_nmap
check_whois
check_sshpass
check_geoip_bin
start_nipe
check_anonymous
auto_ssh "$User" "$Hostname" "$Password"
whois_nmap
