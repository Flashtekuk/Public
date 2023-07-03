#!/bin/bash

USERNAME=loadbalancer
PASSWORD=loadbalancer
LB=${1}
LICENSE=${2}

if [ ${#} -ne 2 ]; then
	echo "Usage: $0 IP /path/to/License.lbk"
	exit 69
fi

curl -k -X POST -u ${USERNAME}:${PASSWORD} \
	--form "submit=file" \
	--form "value=@${LICENSE}" \
	--silent
	 "https://${LB}:9443/lbadmin/config/upgrade.php"
