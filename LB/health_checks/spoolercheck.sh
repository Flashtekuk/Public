#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

# Print Spooler and Port Health Check script v1.1
#
# v1.0 - Created by IGraham 2019-09-02
# v1.1 - Modified by Neil Stone 2022-08-11 - Updated download URL, removed reliance on nmap, added intelligence for check port, fixed path issue with newer wmi package, simplified the check process

## This script uses the WMI package (to probe the Windows print spooler service status) obtained from https://downloads.loadbalancer.org/support/rpms/wmi-1.3.14-27.3.x86_64.rpm
#  piped through grep to confirm that both the SMB port 445 and spoolsv service is running. Login using username@domain.com if the print servers belong to an Active Directory Domain.
#  Please be aware if the print servers reside within a domain the DOMAIN variable needs to be in @DOMAIN.COM format

#### Windows credentials ####

USER="Administrator"
PASS="password"
DOMAIN="domain.com"

#### End credentials ####
#### Service names ####

SVCS="spoolsv EQDCEService EQDREService"

#### End service names ####

####
#### NOTHING BELOW HERE SHOULD NEED ADJUSTMENT ####
####

# If less than 3 args, exit
if [ ${#} -lt 3 ]; then
    exit 12
fi

CHECK_IP="${3}"

# HAProxy always passes 4 vars, where check port is 0 unless defined in config.
# ldirectord passes 3 or 4 depending on RIP port definition.

if [ "${4}" == "0" ] || [ -z "${4}" ]; then
    CHECK_PORT="${2}"
else
    CHECK_PORT="${4}"
fi

# Quick connect to port to validate, early, if there's a potential issue
nc -w 2 -zvn ${CHECK_IP} ${CHECK_PORT} >/dev/null || exit 100

EC=0
for SVC in ${SVCS}; do
        OUT=$(wmic -U "${DOMAIN}\\${USER}%${PASS}" //${CHECK_IP} "SELECT Name FROM Win32_Process" | grep ${SVC})
        EC=$(( ${EC} + ${?} ))
done

# Exit state will be the number of services that fail
exit ${EC}
