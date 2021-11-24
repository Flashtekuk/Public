#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

##########################################################################################################
#
# Health check to check function of HTTP proxy
#
# v1.0 - 2021-11-24 - Neil Stone <support@loadbalancer.org> - Initial creation.
# v1.1 - 2021-11-24 - Neil Stone <support@loadbalancer.org> - Improve handling of multiple site checks.
# v1.2 - 2021-11-24 - Neil Stone <support@loadbalancer.org> - Exit loop on first success.
#
#########################################################################################################

# Exit now if not enough args
if [ ${#} -lt 3 ]; then
	exit 4 	# Not enough args
fi

# user defined variables
CURLOPTS=""
# CURLOPTS="--haproxy-protocol" # Set this if proxy protocol in play on real server - Requires cURL v7.60.0 (Loadbalancer.org appliance v8.6) or newer.
# Set the following space separated list of the pages to check
PAGES="www.bbc.co.uk www.microsoft.com www.google.com www.loadbalancer.org"
# ${CHECK_STATUS} is the HTTP status that must be returned by at least one of the ${PAGES}
CHECK_STATUS="301"

# Command Line Parameters
VIRTUAL_IP=${1}
VIRTUAL_PORT=${2}
REAL_IP=${3}

# Set real server port from ${4} unless that is "0" or not present (inherited)
if [ "${4}" == "0" ] || [ -z "${4}" ]; then
	REAL_PORT="${2}"
else
	REAL_PORT="${4}"
fi

# Program starts
STATUS=0
COUNT=0

for PAGE in ${PAGES}
do
	CURL_OUT=$(curl ${CURLOPTS} --output /dev/null --write-out "%{http_code}" \
		--header 'Cache-Control: no-cache' \
		--head --silent --max-time 3 \
		--url http://${PAGE}/ \
		--proxy ${REAL_IP}:${REAL_PORT})
	echo ${CURL_OUT} | grep -q -e "${CHECK_STATUS}" && exit 0
	let STATUS=${STATUS}+${?}
	let COUNT++
done

if [ ${COUNT} -gt ${STATUS} ]
then
    exit 0 # At least one returned the ${CHECK_STATUS} value.
else
    exit 42 # NONE returned the ${CHECK_STATUS} value.
fi
