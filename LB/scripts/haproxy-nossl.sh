#!/bin/bash

################
#
# haproxy-nossl.sh - Bash script to remove the 'ssl-default' options set by v8.9.1
#
# v1.0 - 2023-07-27 - Initial write - Neil Stone <support@loadbalancer.org>
#
################

sed -i.bak '/ssl-default*/d' /etc/haproxy/haproxy.cfg
md5sum /etc/haproxy/haproxy.cfg | cut -f 1 -d\  > /etc/haproxy/haproxy.md5

scp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.md5 lbslave:/etc/haproxy/

service haproxy reload
ssh lbslave -- service haproxy reload
