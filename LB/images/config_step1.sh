#!/bin/bash
#set -x
PATH=/bin:/usr/bin:/usr/local/sbin:/sbin:/usr/sbin
IP=${1}
yes | lbrestore ; lbfirstboot
lb_net_setup.php ${IP}/18 192.168.64.1 192.168.64.1
ip a a ${IP}/18 dev eth0
lbconsoleenable
reboot
