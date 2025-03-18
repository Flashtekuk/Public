#!/bin/bash
#set -x

GW="${2}"
DNS="${3}"

TERM=xterm

if [ $# -lt 3 ]; then
	echo "ERROR: Need IP, GW, and DNS"
	exit 2
else
	IP=$1
	yes | lbinit
	yes | lbrestore
	lbfirstboot
	lb_net_setup.php ${IP}/24 ${GW} ${DNS}
	ip a a ${IP}/18 dev eth0
	htpasswd -b /etc/loadbalancer.org/passwords loadbalancer loadbalancer
	lbconsoleenable
	reboot
	rm -f /root/configure.sh
fi
