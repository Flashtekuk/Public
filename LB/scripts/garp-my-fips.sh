#!/bin/bash

######
#
# garp-my-fips.sh - Script to perform a garp against all floating IP addresses on Loadbalancer.org appliance
#
# v1.0 - 2025-01-29 - Initial write - Neil Stone <support@loadbalancer.org>
#
######

# Check if active node, if not, exit
if [ $(cat /var/log/nodestatus_local) = passive ]; then
	exit 2
fi

# Send GARP for each floating IP address
for FIP in $(/bin/sed /etc/ha.d/haresources -e s/\ /\\n/g | /bin/awk -F: '/IPaddr2/{print $3}' | /bin/awk -F\/ '{print $1}'); do
	/sbin/arping -A -c 1 ${FIP}
done
