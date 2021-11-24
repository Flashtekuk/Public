#!/bin/bash

#
# Shell script to upload SSH public key to Loadbalancer.org appliance via WebUI
#

LB=${1}
USERNAME=loadbalancer
PASSWORD=loadbalancer
HOSTNAME=$(hostname)
KEYFILE=${2}

if [ ${#} -ne 2 ]; then
	echo "Usage: ${0} IP /path/to/public/keyfile.pub"
	exit 69
fi

curl -k -u ${USERNAME}:${PASSWORD} -X POST \
	--form hostname=${HOSTNAME} \
	--form username="root" \
	--form public_key=@${KEYFILE} \
	"https://${LB}:9443/lbadmin/config/security.php?action=upload_pub_user" \
	--silent > /dev/null
