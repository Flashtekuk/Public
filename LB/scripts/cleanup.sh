#!/bin/bash

###
#
# cleanup.sh - Bash script to clear as much disk space as possible on a Loadbalancer.org appliance
#
# v0.1 - Neil Stone <support@loadbalancer.org>
#
###

rm /var/tmp/* -rf
rm /tmp/* -rf
rm /etc/httpd_* -rf

rm $(find /var/log -name "*.gz" -not -path "/var/log/releases/*") -rf

mount -t tmpfs -o size=1G tmpfs /tmp

yum install https://downloads.loadbalancer.org/support/ca-certificates-2020.2.41-65.1.el6_10.noarch.rpm
