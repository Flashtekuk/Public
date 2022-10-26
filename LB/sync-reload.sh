#!/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin

###############################################################################
#
# sync-reload.sh - Script to sync files from primary to secondary node and 
# reload haproxy.
#
# v1.0 - Neil Stone <support@loadbalancer.org> - 2022-10-26
#
###############################################################################

## FILES is a space separated list of files to sync
FILES="/etc/haproxy/neuanalytics_allowed2.txt"

## Shouldn't need to edit below here.
CHANGE=0

for FILE in ${FILES}; do
    md5sum ${FILE} > ${FILE}.md5-1
    cmp -s ${FILE}.md5-1 ${FILE}.md5-2
    EC=${?}
    if [ ${EC} -ne 0 ]; then
        scp ${FILE} lbslave:${FILE} > /dev/null
        let CHANGE=${CHANGE}+1
    cp -f ${FILE}.md5-1 ${FILE}.md5-2
    fi
done

if [ ${CHANGE} -ne 0 ]; then
    ## Restart locally
    service haproxy reload > /dev/null
    ## Restart on secondary
    ssh lbslave -- service haproxy reload > /dev/null
fi
