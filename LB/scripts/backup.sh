#!/bin/bash

usage() { echo "Usage: ${0} -u username -p password -i webuiip -w webuiport -b backuppassword" 1>&2; exit 1; }

while getopts ":u:p:i:w:b:" OPT; do
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
                b)
			BUPW=${OPTARG}
			;;
                *)
			usage
			;;
        esac
done
shift $((OPTIND-1))

if [ -z "${USER}" ] || [ -z "${PASS}" ] || [ -z "${LBIP}" ] || [ -z "${LBUI}" ] || [ -z "${BUPW}" ]; then
    usage
fi

nc -w 3 -z ${LBIP} ${LBUI}
NC_EC=${?}
if [ ${NC_EC} -ne 0 ]; then
	echo "Unable to connect to ${LBIP} on port ${LBUI}"
	exit 2
fi

curl --user ${USER}:${PASS} \
	--remote-name \
	--remote-header-name \
	--insecure \
	--form "action=backup_full" \
	--form "passphrase=${BUPW}" \
	--form "confirm_passphrase=${BUPW}" \
	"https://${LBIP}:${LBUI}/lbadmin/config/backup.php"
CURL_EC=${?}

exit ${CURL_EC}
