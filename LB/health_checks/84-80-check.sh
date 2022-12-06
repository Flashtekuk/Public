#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

###########################################################################
#
# 84-80-check.sh
#
# v0.1 - Neil Stone <support@loadbalancer.org> - 20220612 - Initial write
#
############################################################################

LOG=/var/log/L4-v84_80-healthcheck.log

VIP=${1}
VPT=${2}
RIP=${3}
RPT=${4}
RPATH="admin/healthcheck"
URL="http://${RIP}:${RPT}/${RPATH}"

echo "####################################################################################################################################" >> ${LOG}
echo "$(date --rfc-3339=seconds) - health check of ${URL} started" >> ${LOG}
curl --silent --head --write-out '%{http_code}\n' ${URL} >> ${LOG} ; EC=${?}
echo "$(date --rfc-3339=seconds) - health check of ${URL} finished - State: ${EC}" >> ${LOG}

exit ${EC}
