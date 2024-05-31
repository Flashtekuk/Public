#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

###
#
# AoVPN health check script
#
# v1.0 - 2024-05-31 - Neil Stone <support@loadbalancer.org> - Intial code
#
###

SERVER_ADDR="${3}"

if [ ! -z "${4}" ]; then
    SERVER_PORT="${4}"
else
    SERVER_PORT="${2}"
fi

REQ_STATE="401"
CHECK_PATH="sra_\{BA195980-CD49-458b-9E23-C84EE0ADCD75\}"

curl --silent -w %{http_code} --insecure --max-time 3 \
    https://${SERVER_ADDR}:${SERVER_PORT}/${CHECK_PATH} \
    | grep -q ${REQ_STATE}

