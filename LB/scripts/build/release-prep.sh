#!/bin/bash

###
# release-prep.sh
#
# v1.0 - NStone - 2025-06-27
###

PLATFORM=${1:-$(virt-what)}
echo "Deploying on: ${PLATFORM}"

if [ ${PLATFORM} = vmware ]; then
   LICENSE="lbva"
elif [ ${PLATFORM} = kvm ]; then
   LICENSE="lbkvm"
elif [ ${PLATFORM} = hyperv ]; then
   LICENSE="lbhyperv"
elif [ ${PLATFORM} = xen ]; then
   LICENSE="lbxen"
else
   echo "Hypervisor not detected: Exiting"
   exit 42
fi

# Tidy up filesystem
   rm -rf /var/www/html_*
   rm -rf /etc/httpd_*
   rm -rf /tmp/*
   rm -f /etc/loadbalancer.org/lb_config.xml.{old,slave}
   rm -rf /etc/loadbalancer.org/certs/[!server.???][!backup]

   chattr -i /var/www/html/lbadmin/inc/model.php

# Make sure Debug is False in /var/www/html/lbadmin/inc/lbadmin_config.*
   grep \$DEBUG /var/www/html/lbadmin/inc/lbadmin_config.php | grep False || 'echo "DEBUG set, exiting" ; exit 69'

# Remove any entries in /root/.ssh/
   truncate -s 0 /root/.ssh/known_hosts
   truncate -s 0 /root/.ssh/authorized_keys
   truncate -s 0 /root/.ssh/authorized_keys2

# Clean up yum
   yum clean all

# Apply license and perform primary log clean

   yes | ${LICENSE}
   lblogclean
   yes | lbrestore

# Zero padding
for file in /root/zero.dat /var/log/zero.dat; do
   echo “Starting ${file}” && \
   dd if=/dev/zero of=${file} bs=1M ; sync && sleep 1 && sync && \
   echo “Removing ${file}” && \
   rm -vf ${file} && \
   echo “Complete ${file}” && \
   echo;
done


# Final clear up:
   yes | lbinit
   lblogclean
   echo "Next, run:- history -c ; lbcleanboot"

# Commit suicide
   rm -fv ${0}
