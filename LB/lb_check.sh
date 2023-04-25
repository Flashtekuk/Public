#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#####
#
# Loadbalancer.org check_mk agent to provide monitoring of haproxy and lvs
#
# Neil Stone <support@loadbalancer.org>
#
# v0.1 - 2023-04-25
#
# HAProxy check pulls data right from haproxy stats socket
#
# LVS check uses a text file in /etc/check_mk (called lvs) which has one entry per line as per
#
# vipname ip.add.re.ss port
# website 192.168.66.88 80
#
# (grep ^virtual /etc/ha.d/conf/ldirectord.cf | sed -e "s#\=#\ #g" -e "s#\:#\ #g" -e "s#\"#\ #g"|awk '{print $5 " " $2 " " $3}' > /etc/check_mk/lvs)
#
# Usage: copy this script in to /usr/lib/check_mk_agent/plugins and chmod +x
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

exit 0

### Below here still in development

## Heartbeat status
echo '<<<lbha>>>'
LOCALSTATE=$(cat /var/log/nodestatus_local)
echo "${HOSTNAME}:${LOCALSTATE}"

## LB software version
echo '<<<lbver>>>'
if [ -f /etc/loadbalancer.org/update_available ]; then
	if grep -q -e '^\"\"$' /etc/loadbalancer.org/update_available; then
		echo "LB_VER: No update detected"
	else
		echo "LB_VER: Update detected"
	fi
else
	echo "LB_VER: Update flag file not present"
fi

## End
echo ''
