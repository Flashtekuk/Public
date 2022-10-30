#!/bin/bash


###############################################################################
#                                                                             #
# import_floating_ips.sh - Script to import floating IP addresses from        #
#   HAProxy manual configuration on Loadbalancer.org appliance                #
#                                                                             #
# (C) 2022 Loadbalancer.org                                                   #
#                                                                             #
# v1.0 - 2022-10-30 - Neil Stone <support@loadbalalcer.org>                   #
#                                                                             #
#                                                                             #
###############################################################################

for IP in $(awk '/^bind/ {print $2}' /etc/haproxy/haproxy_manual.cfg | cut -f 1 -d\: | sort -u); do
   echo "Adding Floating IP: ${IP}"
   lbcli --action add-floating-ip --ip ${IP}
   sleep 1
done
