#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

########################################################################################################################
#
# 84-80-check.sh
#
# v0.1 - Neil Stone <support@loadbalancer.org> - 20221206 - Initial write
# v0.2 - Neil Stone <support@loadbalancer.org> - 20221207 - Updated output from curl stderr to stdout
# v0.3 - Neil Stone <support@loadbalancer.org> - 20221207 - Updated output from curl to output to tee and append to log
# v0.4 - Neil Stone <support@loadbalancer.org> - 20221207 - Exit 0 on desired http exit code
#
#########################################################################################################################

LOG=/var/log/L4-v84_80-healthcheck.log

VIP=${1}
VPT=${2}
RIP=${3}
RPT=${4}
RPATH="admin/healthcheck"
URL="http://${RIP}:${RPT}/${RPATH}"
WANTEDCODE="200"

echo "####################################################################################################################################" >> ${LOG}
echo "$(date --rfc-3339=seconds) - health check of ${URL} started" >> ${LOG}
EC=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' ${URL} 2>&1 | tee -a ${LOG})
echo "$(date --rfc-3339=seconds) - health check of ${URL} finished - State: ${EC}" >> ${LOG}

if [ ${EC} -eq ${WANTEDCODE} ]; then
	echo "Exit state matched ${WANTEDCODE} - Exiting 0" >> ${LOG}
	exit 0
fi

exit ${EC}
