#!/bin/bash

#
# snmp-on.sh - Small script to enable SNMP v2c on Loadbalancer.org Enterprise appliances
#
# v1.0 - 2026-09-02 - Neil Stone <support@loadbalancer.org> - Initial commit
#

usage() { echo "Usage: ${0} -u username -p password -i webuiip -w webuiport -c community -l location -o contact" 1>&2; exit 1; }

while getopts ":u:p:i:w:c:l:o:" OPT; do
        case "${OPT}" in
                u)
			USER=${OPTARG}
			;;
                p)
			PASS=${OPTARG}
			;;
                i)
			LBIP=${OPTARG}
			;;
                w)
			LBUI=${OPTARG}
			;;
                c)
			COMMUNITY=${OPTARG}
			;;
                l)
			LOCATION=${OPTARG}
			;;
                o)
			CONTACT=${OPTARG}
			;;
                *)
			usage
			;;
        esac
done
shift $((OPTIND-1))

if [ -z "${USER}" ] || [ -z "${PASS}" ] || [ -z "${LBIP}" ] || [ -z "${LBUI}" ] || [ -z "${COMMUNITY}" ] || [ -z "${LOCATION}" ] || [ -z "${CONTACT}" ]; then
    usage
fi


nc -w 3 -z ${LBIP} ${LBUI}
NC_EC=${?}
if [ ${NC_EC} -ne 0 ]; then
	echo "Unable to connect to ${LBIP} on port ${LBUI}"
	exit 2
fi

curl --user ${USER}:${PASS} \
	--insecure \
	--form "snmpv2_enable=on" \
	--form "location=${LOCATION}" \
	--form "contact=${CONTACT}" \
	--form "community=${COMMUNITY}" \
	"https://${LBIP}:${LBUI}/lbadmin/config/snmp.php?action=submit"  -o /dev/null --silent
CURL1_EC=${?}

curl --user ${USER}:${PASS} \
        --insecure \
	--form "restart=snmp" \
	"https://${LBIP}:${LBUI}/lbadmin/config/restart.php?mnp=maint&submnp=mrs"  -o /dev/null --silent
CURL2_EC=${?}

CURL_EC=$((CURL1_EC + CURL2_EC))
exit ${CURL_EC}

