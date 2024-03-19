#!/bin/bash

if [ ! -z $HISTFILE ]; then
    echo "HISTFILE set, please 'unset HISTFILE' and run again"
    exit 2
fi

if [ ${#} -ne 1 ]; then
    echo
    echo "Usage: ${0} [hyperv|kvm|xen|vmware|vultimate|cloudian|v1000|v4000|vultimate|hardware]"
    echo
    exit 3
fi

BRAND="default"
PARTNER="0"
PLATFORM=${1}
SCRIPT=${0}

if [ ${PLATFORM} = 'vmware' ]; then
    LIC_CMD='lbva'
elif [ ${PLATFORM} = 'hyperv' ]; then
    LIC_CMD='lbhyperv'
elif [ ${PLATFORM} = 'kvm' ]; then
    LIC_CMD='lbkvm'
elif [ ${PLATFORM} = 'xen' ]; then
    LIC_CMD='lbxen'
elif [ ${PLATFORM} = 'vultimate']; then
    LIC_CMD='changehealthcarevultimate'
    BRAND='changehealthcare'
    PARTNER=1
elif [ ${PLATFORM} = 'cloudian']; then
    LIC_CMD='cloudianhyperbalance 1'
    BRAND='cloudian'
    PARTNER=1
elif [ ${PLATFORM} = 'v1000']; then
    LIC_CMD='gehealthcarevonethousand'
    BRAND='gehealthcare'
    PARTNER=1
elif [ ${PLATFORM} = 'v4000']; then
    LIC_CMD='gehealthcarevfourthousand'
    BRAND='gehealthcare'
    PARTNER=1
elif [ ${PLATFORM} = 'vultimate']; then
    LIC_CMD='gehealthcarevultimate'
    BRAND='gehealthcare'
    PARTNER=1
else # Default to hardware
    LIC_CMD='lbsprime'
fi

grep "\$DEBUG = False\;" /var/www/html/lbadmin/inc/lbadmin_config.php
grep_EC=${?}
if [ ${grep_EC} -ne 0 ];then
    echo "Debug not False in lbadmin_config.php... exiting"
    exit 4
fi

echo > /etc/loadbalancer.org/patches
echo > /root/.ssh/known_hosts
echo > /root/.ssh/authorized_keys2

chattr -i /var/www/html/lbadmin/inc/model.php

rm -rf /var/www/html_*
rm -rf /etc/httpd_*
rm -rf /tmp/*
rm -f /etc/loadbalancer.org/lb_config.xml.{old,slave}
rm -rf /etc/loadbalancer.org/certs/[!server.???][!backup]

yum clean all

yes | ${LIC_CMD}
lbbrand ${BRAND}
lblogclean
yes | lbrestore

echo "Zero padding... will take some time..."
for file in /zero.dat /var/log/zero.dat; do
    echo “Starting ${file}”
    dd if=/dev/zero of=${file} bs=1M
    sync ; sleep 1 ; sync
    echo “Removing ${file}”
    rm -f ${file}
    echo “Complete ${f}”
    echo ""
done
echo "Zero padding done..."

yes | lbinit
lblogclean
lbrestore
if [ ${PARTNER} = 0 ]; then
    sed -i 's/<hide>yes/<hide>no/' /etc/loadbalancer.org/lb_config.xml"
fi
lbfirstboot"
find / -xdev -name ".bash_history" -exec rm -rf {} \;

shutdown -h 0

rm -f ${SCRIPT}

exit 0