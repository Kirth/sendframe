#!/bin/bash


# Default route NW Interface
INTERFACE=$(ip route | grep default | awk '{print $5}')


# IP address + subnet mask of the interface
IP_ADDR=$(ip -o -f inet addr show $INTERFACE | awk '{print $4}')

NETWORK=$(ipcalc -n $IP_ADDR | cut -d= -f2)
NETMASK=$(ipcalc -m $IP_ADDR | cut -d= -f2)
CIDR=$(ipcalc -p $IP_ADDR | cut -d= -f2)

BROADCAST=$(ipcalc -b $IP_ADDR | cut -d= -f2)

echo "Scanning network: $NETWORK/$CIDR on interface $INTERFACE"

# Ping all IP addresses in the subnet to populate ARP cache
for ip in $(nmap -n -sL $NETWORK/$CIDR | grep "Nmap scan report" | awk '{print $5}'); do
    ping -c 1 -W 1 $ip > /dev/null &
done

# Wait for all pings to finish
wait

echo ""
echo "IP Address       MAC Address"
echo "-----------------------------------"

# Display the ARP cache
arp -n | grep -v incomplete | awk '/^[0-9]/ {printf "%-15s %s\n", $1, $3}'

