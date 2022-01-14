#!/bin/bash
#set -x
PATH=/bin:/usr/bin:/usr/local/sbin:/sbin:/usr/sbin
LICENSE=${1}
IP=${2}

rm -rf /var/www/html_*
chattr -i /var/www/html/lbadmin/inc/model.inc
rm -rf /etc/httpd_*
rm -rf /tmp/*
rm -f /etc/loadbalancer.org/lb_config.xml.{old,slave}
rm -rf /etc/loadbalancer.org/certs/[!server.???][!backup]

> /root/.ssh/known_hosts
> /root/.ssh/authorized_keys
> /root/.ssh/authorized_keys2

yum clean all
yes | ${LICENSE}
yes | lbrestore
ip a a ${IP}/18 dev eth0

rm -rf /tmp/* /tmp/.*[!.]

for ZEROPATH in root var/log ; do
        echo "$(date) - Starting zero padding in /${ZEROPATH}"
        dd if=/dev/zero of=/${ZEROPATH}/zero.dat bs=1M; sync && sleep 1 && sync && rm -f /${ZEROPATH}/zero.dat
        echo "$(date) - Finished zero pad in /${ZEROPATH}"
done

lblogclean
source /root/.bashrc
perform_cleanboot
ip a a ${IP}/18 dev eth0
rm -f /config_step?.sh
