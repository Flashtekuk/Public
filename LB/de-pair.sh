#!/bin/bash
set -e

 ##############################################################################################################
#                                                                                                              #
# Script to convert Loadbalancer.org HA paired node XML configs to a standalone master ready for pairing.      #
# Uses 'xmlstarlet' package. Please install prior to using this script.                                        #
#                                                                                                              #
# v1.0 - 2021-04-12 - Neil Stone - Initial write                                                               #
# v1.0.1 - 2021-04-12 - Neil Stone - Improve the sed                                                           #
# v1.2.0 - 2021-05-02 - Neil Stone - Merge master and slave scripts                                            #
#                                                                                                              #
 ##############################################################################################################

# Check xmlstarlet is installed
which xmlstarlet &> /dev/null || echo "Binary: 'xmlstarlet' not found in path, please check this is installed and try again"

if [ $# -ne 2 ]; then
	CONFIG=lb_config.xml
else
	CONFIG=${2}
fi

if [ ${1} = master ]; then
	MODE=master
	MODE_EXTRAS=''
elif [ ${1} = slave ]; then
	MODE=slave
	MODE_EXTRAS=' -u config/physical/network/role -v master \
	 -u config/physical/secure/httpscert -v localhost \
	 -d config/pound/virtual \
	 -d config/haproxy/virtual \
	 -d config/ldirectord/virtual \
	 -d config/stunnel/virtual \
	 -d config/heartbeat/vip \
	 -d config/sslcerts/cert \
	 -d config/waf/gateway \
	 -d config/gslb/topologies/topology \
	 -d config/gslb/globalnames/globalname \
	 -d config/gslb/members/member \
	 -d config/gslb/pools/pool \
	 -d config/pbr/rule'
else
	MODE=fail
	echo "Useage: ${0} [master|slave] filename.xml"
	exit 6
fi

if [ ! -f ${CONFIG} ]; then
	echo "Unable to access ${CONFIG}"
	exit 2
fi

OUT=unpaired-${MODE}-${CONFIG}

xmlstarlet edit -O -P \
 -u config/physical/network/master -v "" \
 -u config/physical/network/slave  -v "" \
\
 -u config/physical/pool/name -v "" \
 -u config/physical/pool/state -v none \
\
 -u config/heartbeat/ucast_interface/master -v lo \
 -u config/heartbeat/ucast_interface/slave -v lo \
 -u config/heartbeat/ucast_ip/master -v 127.0.0.1 \
 -u config/heartbeat/ucast_ip/slave -v 127.0.0.1 \
\
 -u config/global/firewall/conntrack_size -v 524288 \
 -u config/global/firewall/lockdown -v off \
 -u config/global/firewall/admin_net -v 0.0.0.0/0 \
\
 -d config/physical/pool/node \
 -d config/physical/pool/node/hostname \
 -d config/physical/pool/node/role \
 -d config/physical/pool/node/ip \
 -d config/physical/pool/node/type \
\
 ${MODE_EXTRAS} \
 ${CONFIG} | sed -e "/^$/d" -e "/\t$/d" > ${OUT}

echo "Converted: ${CONFIG} to ${OUT}"
exit 0
