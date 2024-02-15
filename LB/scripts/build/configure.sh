#!/bin/bash
#set -x

TERM=xterm

if [ $# -lt 1 ]; then
        echo "ERROR: Need IP"
        exit 2
else
        IP=$1
#       chmod +x /etc/rc.d/rc.tproxy
        yes | lbinit # Can be removed 'soon'
        yes | lbrestore
        lbfirstboot
        lb_net_setup.php ${IP}/18 192.168.64.1 192.168.64.1
        ip a a ${IP}/18 dev eth0
#       chmod -x /etc/rc.d/rc.tproxy
        htpasswd -b /etc/loadbalancer.org/passwords loadbalancer loadbalancer
        lbconsoleenable
#       ln -s /var/www/html/lbadmin/config/gslb_install_existing.php /var/www/html/lbadmin/inc/gslb_install_existing.php
        reboot
        rm -f /root/configure.sh
fi
