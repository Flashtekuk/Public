#!/bin/bash
PATH=/usr/bin

#####
#
# multi_port.sh - Health check to check if port1 is available, if not check port2, of both are unavailable, fail
#
# v1.0 - Neil Stone <support@loadbalancer.org> - 20231016 - Initial write
#
#####


PORT1=8082
PORT2=80
TIMEOUT=2

DEST=${3}

nc -zvn ${DEST} ${PORT1} -w ${TIMEOUT}
EC1=${?}

if [ ${EC1} -eq 0 ];
	then
		exit 0
	else
		nc -zvn ${DEST} ${PORT2} -w ${TIMEOUT}
		EC2=${?}
fi

exit ${EC2}
