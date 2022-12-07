#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

###################################################################################################################################
#
# 84-80-check.sh
#
# v0.1 - Neil Stone <support@loadbalancer.org> - 20221206 - Initial write
# v0.2 - Neil Stone <support@loadbalancer.org> - 20221207 - Updated output from curl stderr to stdout
# v0.3 - Neil Stone <support@loadbalancer.org> - 20221207 - Updated output from curl to output to tee and append to log
# v0.4 - Neil Stone <support@loadbalancer.org> - 20221207 - Exit 0 on desired http exit code
# v0.5 - Neil Stone <support@loadbalancer.org> - 20221207 - Additional checks for port open, reorder a few bits, include timeouts
#
###################################################################################################################################

VIP=${1}
VPT=${2}
RIP=${3}

if [ "${4}" == "0" ] || [ -z "${4}" ]; then
    CHECK_PORT="${VPT}"
else
    CHECK_PORT="${4}"
fi

LOG=/var/log/L4-v84_80-healthcheck.log
TIMEOUT=2
RPATH="admin/healthcheck"
URL="http://${RIP}:${CHECK_PORT}/${RPATH}"
WANTEDCODE="200"

nc -zvn -w ${TIMEOUT} ${RIP} ${CHECK_PORT}
NC_EC=${?}
if [ ${NC_EC} -ne 0 ]; then
	exit 199
fi

echo "####################################################################################################################################" >> ${LOG}
echo "$(date --rfc-3339=seconds) - health check of ${URL} started" >> ${LOG}
CURL_EC=$(curl --max-time ${TIMEOUT} -o /dev/null --silent --head --write-out '%{http_code}\n' ${URL} 2>&1 | tee -a ${LOG})
echo "$(date --rfc-3339=seconds) - health check of ${URL} finished - State: ${CURL_EC}" >> ${LOG}

if [ ${CURL_EC} -eq ${WANTEDCODE} ]; then
	echo "Exit state matched ${WANTEDCODE} - Exiting 0" >> ${LOG}
	exit 0
fi

exit ${CURL_EC}
