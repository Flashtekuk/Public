#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#####
#
# Loadbalancer.org check_mk agent to provide monitoring of haproxy and lvs
#
# HAProxy check pulls data right from haproxy stats socket
# LVS check uses a text file in /etc/check_mk (called lvs) which has one entry per line as per
#
# vipname ip.add.re.ss port
# website 192.168.66.88 80
#
# Usage: copy this script in to /usr/lib/check_mk_agent/plugins and chmod +x
#
#
#####

## HAProxy

echo "<<<haproxy:sep(44)>>>"
echo "show stat" | socat - "UNIX-CONNECT:/var/run/haproxy.stat"

## LVS

# Source the configuration file for this agent plugin
if [ -e "/etc/check_mk/lvs" ] ; then
   echo '<<<lvs:sep(58)>>>'
   cat /etc/check_mk/lvs | (
   while read label vip port
   do
     LVS_ITEM=$(lvsgsp -v ${vip} ${port} | sed 'N;s/\n/:/' | head -n1)
     echo ${label}:${LVS_ITEM}
   done
   )
fi

#####

echo '<<<lbha>>>'
LOCALSTATE=$(cat /var/log/nodestatus_local)
echo "${HOSTNAME}:${LOCALSTATE}"

echo '<<<lbver>>>'
if [ -f /etc/loadbalancer.org/update_available ]; then
	if [ $(grep -q -e '^\"\"$' /etc/loadbalancer.org/update_available ; echo ${?}) = 1 ]; then
		echo "Update available"
	else
		echo "No update available"
	fi
else
	echo "Update flag file not present"
fi

#LOCALLBVER=$(cut /etc/loadbalancer.org/version.txt -f3 -d\: | cut -f 3 -d\/ | cut -f 1 -d ' ' | sed -e 's/\-/\./g' | rev | cut -d\. -f 3- | rev)
#echo "Local version is: ${LOCALLBVER}"
#REMOTELBVER=$(curl https://www.loadbalancer.org/support/ 2>/dev/null |grep "Latest version" | sed -e 's/<[^>]*>//g' | awk '{print $3}')
#echo "Latest version is: ${REMOTELBVER}"
#
#if [ ${LOCALLBVER} != ${REMOTELBVER} ]; then
#	echo "Versions not equal, upgrade available"
#else
#	echo "Versions match"
#fi

#UPDATESTATE=$(curl --user loadbalancer:loadbalancer -k 'https://127.0.0.1:9443/lbadmin/config/update.php?mnp=maint&submnp=msu&t=1610976392&l=e&action=online' 2>/dev/null \
# | grep -i ${LOCALLBVER} | grep "information" | sed -e 's/<[^>]*>//g')
#echo ${UPDATESTATE}

#echo ""
