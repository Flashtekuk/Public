#!/bin/bash
set -e

 ##############################################################################################################
#                                                                                                              #
# Script to convert Loadbalancer.org HA paired node XML configs to a standalone master ready for pairing.      #
# Uses 'xmlstarlet' package. Please install prior to using this script.                                        #
#                                                                                                              #
# v1.0.0 - 2021-04-12 - Neil Stone - Initial write                                                             #
# v1.0.1 - 2021-04-12 - Neil Stone - Improve the sed                                                           #
# v1.2.0 - 2021-05-04 - Neil Stone - Merge master and slave scripts                                            #
# v1.3.0 - 2022-08-11 - Neil Stone - Remove healthcheck entries on slave                                       #
# v1.3.1 - 2022-08-22 - Neil Stone - Change language to reflect primary/secondary                              #
#                                                                                                              #
 ##############################################################################################################

# Check xmlstarlet is installed
which xmlstarlet &> /dev/null || echo "Binary: 'xmlstarlet' not found in path, please check this is installed and try again"

CONFIG=lb_config.xml
MODE=fail

while getopts :f:m: OPT
do
	case "${OPT}" in
		f) CONFIG=${OPTARG};;
		m) MODE=${OPTARG};;
		*) MODE=fail;;
	esac
done

if [ ${MODE} = 'primary' ]; then
	MODE_EXTRAS=''
elif [ ${MODE} = 'secondary' ]; then
	MODE_EXTRAS=" -u config/physical/network/role -v master \
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
	 -d config/pbr/rule \
	 -d config/healthchecks/healthcheck"
else
	echo "Useage: ${0} -m [primary|secondary] -f filename.xml"
	exit 1
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
