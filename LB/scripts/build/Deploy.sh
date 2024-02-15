#!/bin/bash
#set -x

if [ ${#} -ne 3 ]; then
        echo "Usage: ${0} IP branch platform"
        exit 3
fi

LOGDIR=${HOME}/buildlogs
mkdir -p ${LOGDIR}
LOGFILE=${LOGDIR}/$(date +%s).log
APPLIANCE=${1}
BRANCH=${2}
PLATFORM=${3}
export SSHPASS=loadbalancer
HOSTNAME=$(hostname)
CLOUD=0

ping -c 1 ${APPLIANCE}

if [ "${PLATFORM}" = "aws" ] || [ "${PLATFORM}" = "amazonwebservices" ]; then
        PLATFORM=ec2
fi

if [ "${PLATFORM}" = "ec2" ] || [ "${PLATFORM}" = "gcp" ]  || [ "${PLATFORM}" = "azure" ] ; then
        CLOUD=1
fi

function sec_off () {
        echo "Adjusting security..."
        curl --user loadbalancer:loadbalancer \
                --request POST \
                --form applianceSecurityMode=custom \
                --form disableRootAccess=off \
                --form disableSSHPass=off \
                --form wui_https_only=on \
                --form wui_https_port=9443 \
                --form wui_https_cert=localhost \
                --form wui_https_ciphers=ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-GCM-SHA256 \
                --form go=Update \
                --insecure "https://${APPLIANCE}:9443/lbadmin/config/secure.php?action=edit&l=e" -o /dev/null --silent
        echo "Uploading SSH public key..."
        curl -u loadbalancer:loadbalancer -X POST \
                --form hostname="${HOSTNAME}" \
                --form username="root" \
                --form public_key=@"${HOME}/.ssh/id_ecdsa.pub" \
                --insecure "https://${APPLIANCE}:9443/lbadmin/config/security.php?action=upload_pub_user" -o /dev/null --silent
        echo "Security adjustments completed..."
}

sec_off

git pull |& tee -a ${LOGFILE}
git checkout ${BRANCH} |& tee -a ${LOGFILE}
git pull |& tee -a ${LOGFILE}

if [ -f ./scripts/rpm/fetchlocalrpms.sh ]; then
        echo "FetchLocalRPMs starting"
        ./scripts/rpm/fetchlocalrpms.sh ${BRANCH} |& tee -a ${LOGFILE}
        echo "FetchLocalRPMs complete"
        sleep 1

        echo "FetchCloudRPMs starting"
        ./scripts/rpm/fetchcloudrpms.sh ${BRANCH} |& tee -a ${LOGFILE}
        echo "FetchCloudRPMs complete."
        sleep 1
fi

echo "BuildRPM starting..."
./scripts/rpm/buildrpm.sh ${BRANCH} |& tee -a ${LOGFILE}
echo "BuildRPM complete."
sleep 1

if [ ${CLOUD} = 0 ]; then
        echo "Copy configure script to ${APPLIANCE} - Starting"
        sshpass -e scp ../configure.sh root@${APPLIANCE}:/root
        echo "Copy configure script to ${APPLIANCE} - Done"
        sleep 1
fi

echo "DeployRPMs starting..."
./scripts/deploy/deployrpms.sh ${BRANCH} ${APPLIANCE} ${PLATFORM} |& tee -a ${LOGFILE}
echo "DeployRPMs complete."
sleep 1

sec_off

if [ ${CLOUD} = 0 ]; then
        sshpass -e scp ../configure.sh root@${APPLIANCE}:/root
        sshpass -e ssh -t ${APPLIANCE} -- screen /root/configure.sh ${APPLIANCE}
        echo "Configure done."
fi

if [ ${PLATFORM} = "ec2" ]; then
        ssh root@${APPLIANCE} -- "yes | lbrestore ; yes | lbec2 ; yes | lbamiprep ; yes | lbfirstboot"
fi


#clear

echo ""
echo " -=: Logfile: ${LOGFILE} :=-"
echo ""
