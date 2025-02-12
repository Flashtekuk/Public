#!/bin/bash

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

# Check if this is a cloud deployment
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

git pull |& tee -a ${LOGFILE}
git checkout ${BRANCH} |& tee -a ${LOGFILE}
git pull |& tee -a ${LOGFILE}

if [ ${CLOUD} = 0 ]; then
        echo "Non cloud deployment selected." |& tee -a ${LOGFILE}
        ping -c 1 ${APPLIANCE}
        sec_off

        echo "Copy configure script to ${APPLIANCE} - Starting" |& tee -a ${LOGFILE}
        sshpass -e scp ../finish.sh root@${APPLIANCE}:/root
        echo "Copy configure script to ${APPLIANCE} - Done" |& tee -a ${LOGFILE}
        sleep 1

        echo "DeployRPMs starting..." |& tee -a ${LOGFILE}
        ./scripts/deploy/deployrpms.sh ${BRANCH} ${APPLIANCE} ${PLATFORM} |& tee -a ${LOGFILE}
        echo "DeployRPMs complete." |& tee -a ${LOGFILE}
        sleep 1

        sec_off

        echo "Executing configure script..." |& tee -a ${LOGFILE}
        sshpass -e ssh -t ${APPLIANCE} -- screen /root/finish.sh ${PLATFORM} |& tee -a ${LOGFILE}
        echo "Configure done." |& tee -a ${LOGFILE}
fi

#if [ ${CLOUD} = 1 ]; then
#        echo "Cloud deployment selected." |& tee -a ${LOGFILE}
#        if [ ${PLATFORM} = ec2 ]; then
#                echo "Cloud platform: ${PLATFORM}" |& tee -a ${LOGFILE}
#                # EC2 commands |& tee -a ${LOGFILE}
#                TARGET=byol
#
#        elif [ ${PLATFORM} = gcp ]; then
#                echo "Cloud platform: ${PLATFORM}" |& tee -a ${LOGFILE}
#                # GCP commands |& tee -a ${LOGFILE}
#                # Options are hourly|byol suffixed with prod|support|dev
#                TARGET=byol-support
#		export FORCE_VERSION="v8.9.1"
#
#        elif [ ${PLATFORM} = azure ]; then
#                echo "Cloud platform: ${PLATFORM}"  |& tee -a ${LOGFILE}
#                # Azure commands |& tee -a ${LOGFILE}
#                TARGET=byol
#
#        else
#                echo "Platform: \"${PLATFORM}\" not known" |& tee -a ${LOGFILE}
#        fi
#        scripts/build.sh ${BRANCH} ${PLATFORM} ${TARGET} |& tee -a ${LOGFILE}
#fi

echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Deployment on \"${APPLIANCE}\" running on \"${PLATFORM}\" and branch \"${BRANCH}\" finished."
echo ""
echo "Please check the log for any issues, dumping last 10 lines here."
echo ""
echo "-=:###################:=-"
tail -n 10 ${LOGFILE}
echo "-=:###################:=-"
echo ""
echo " -=: Logfile: ${LOGFILE} :=-"
echo ""
