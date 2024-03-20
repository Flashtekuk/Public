#!/bin/bash

if [ ${#} -ne 1 ]; then
        echo "Usage: ${0} branch"
        exit 3
fi

LOGDIR=${HOME}/buildlogs
mkdir -p ${LOGDIR}
LOGFILE=${LOGDIR}/rpmbuild-$(date +%s).log
BRANCH=${1}

git pull |& tee -a ${LOGFILE}
git checkout ${BRANCH} |& tee -a ${LOGFILE}
git pull |& tee -a ${LOGFILE}

echo "FetchLocalRPMs starting" |& tee -a ${LOGFILE}
./scripts/rpm/fetchlocalrpms.sh ${BRANCH} |& tee -a ${LOGFILE}
echo "FetchLocalRPMs complete" |& tee -a ${LOGFILE}

echo "FetchCloudRPMs starting" |& tee -a ${LOGFILE}
./scripts/rpm/fetchcloudrpms.sh ${BRANCH} |& tee -a ${LOGFILE}
echo "FetchCloudRPMs complete." |& tee -a ${LOGFILE}

echo "BuildRPM starting..." |& tee -a ${LOGFILE}
./scripts/rpm/buildrpm.sh ${BRANCH} |& tee -a ${LOGFILE}
echo "BuildRPM complete." |& tee -a ${LOGFILE}

echo ""
echo ""
echo ""
echo ""
echo "RPM build of branch \"${BRANCH}\" finished."
echo ""
echo "Please check the log for any issues, dumping last 10 lines here."
echo ""
echo "-=:###################:=-"
tail -n 10 ${LOGFILE}
echo "-=:###################:=-"
echo ""
echo " -=: Logfile: ${LOGFILE} :=-"
echo ""
