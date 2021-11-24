#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

###############################################################################
#
# Health check to check function of HTTP proxy
#
# v1.0 - 2021-11-24 - Neil Stone <support@loadbalancer.org> - Initial creation
#
################################################################################

# Exit now if not enough args
if [ $# -lt 3 ]; then
	# Exit state 4 if not enough args
	exit 4
fi

# user defined variables
CURLOPTS=""
# CURLOPTS="--haproxy-protocol" # Set this if proxy protocol in play on real server - Requires cURL v7.60.0 (Loadbalancer.org appliance v8.6) or newer.
PAGES="www.loadbalancer.org"
CHECK_STRING="HTTP/1.1 301 Moved Permanently"

# Command Line Parameters
VIRTUAL_IP=${1}
VIRTUAL_PORT=${2}
REAL_IP=${3}

# Set real server port from $4 unless that's "0" or not present (inherited)
if [ "${4}" == "0" ] || [ -z "${4}" ]; then
	REAL_PORT="${2}"
else
	REAL_PORT="${4}"
fi

# Program starts

for PAGE in ${PAGES}
do
	curl ${CURLOPTS} -I --silent --url http://${PAGE}/ --proxy ${REAL_IP}:${REAL_PORT} | grep -q -e "${CHECK_STRING}"
done

# set the exiting return code
EXIT_CODE="${?}"
exit ${EXIT_CODE}
