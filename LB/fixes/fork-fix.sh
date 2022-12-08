#!/bin/bash
PATH=/bin:/sbin:/usr/bin

########################################################################################
#
# fork-fix.sh - Script to work around XML to .cf bug for ldirectord 'fork' setting
#
# v0.1 - Neil Stone <support@loadbalancer.org> - 20221208 - Initial commit
#
########################################################################################

CF=/etc/ha.d/conf/ldirectord.cf

WANTFORK=$(grep 'fork' /etc/loadbalancer.org/lb_config.xml |cut -f2 -d\<|cut -f2 -d\>) 
ISFORK=$(grep ^fork ${CF} | cut -f2 -d\= )

if [ ${WANTFORK} != ${ISFORK} ]; then
   sed -i.bak s:fork=${ISFORK}:fork=${WANTFORK}: ${CF}
   echo -n $(md5sum ${CF} |cut -f 1 -d\  ) > /etc/ha.d/conf/ldirectord.md5
   service ldirectord restart
fi

exit 0
