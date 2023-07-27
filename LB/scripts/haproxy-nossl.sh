#!/bin/bash
set -x

sed -i.bak '/ssl-default*/d' /etc/haproxy/haproxy.cfg
md5sum /etc/haproxy/haproxy.cfg | cut -f 1 -d\  > /etc/haproxy/haproxy.md5

scp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.md5 lbslave:/etc/haproxy/

service haproxy reload
ssh lbslave -- service haproxy reload
