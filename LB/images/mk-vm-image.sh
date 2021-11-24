#!/bin/bash
#set -x
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

BRANCH=fail
PLATFORM=fail
IP=fail
SSHPASS=loadbalancer
SSHCMD="ssh -t -l root -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
CONFIG_SRC=https://raw.githubusercontent.com/Flashtekuk/Public/master/LB/images

function usage {
    echo "${0} -b BRANCH -i IP -p PLATFORM [hyperv|kvm|vmware|xen]"
    exit 42
}

while getopts :b:p:i:h OPT
do
	case "${OPT}" in
		b) BRANCH=${OPTARG};;
		p) PLATFORM=${OPTARG};;
		i) IP=${OPTARG};;
		*) usage
	esac
done

case "${PLATFORM}" in
	hyperv) LICENSE=lbhyperv;;
	kvm) LICENSE=lbkvm;;
	vmware) LICENSE=lbva;;
	xen) LICENSE=lbxen;;
esac

if [ ${PLATFORM} = fail ] || [ ${BRANCH} = fail ] || [ ${IP} = fail ]; then
    usage
    exit 69
fi

git checkout ${BRANCH}
git pull

grep "^\$DEBUG = False;" essential/var/www/html/lbadmin/inc/lbadmin_config.inc
EC=${?}
if [ ${EC} -ne 0 ]; then
	echo "DEBUG ENABLED - Exiting"
	exit 42
fi

function sec-off {
ping -c 1 ${IP}

curl -u loadbalancer:loadbalancer -X POST \
   --form applianceSecurityMode=custom \
   --form disableRootAccess=off \
   --form disableSSHPass=off \
   --form wui_https_only=on \
   --form wui_https_port=9443 \
   --form wui_https_cert=localhost \
   --form wui_https_ciphers=ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-GCM-SHA256 \
   --form go=Update \
   --insecure "https://${IP}:9443/lbadmin/config/secure.php?action=edit&l=e" -o /dev/null --silent

sshpass -e ssh-copy-id root@${IP}
}

sec-off
./scripts/deploy/deploytrunk.php ${IP} . ${PLATFORM}

${SSHCMD} ${IP} -- wget ${CONFIG_SRC}/config_step1.sh -O /config_step1.sh
${SSHCMD} ${IP} -- wget ${CONFIG_SRC}/config_step2.sh -O /config_step2.sh

${SSHCMD} ${IP} -- chmod +x /config_step*

${SSHCMD} ${IP} -- screen -T xterm /config_step1.sh ${IP}
sleep 60
sec-off
${SSHCMD} ${IP} -- screen -T xterm /config_step2.sh ${LICENSE} ${IP}

exit 0
