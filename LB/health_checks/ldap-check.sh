#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# define IP to be checked
checkIP=${3}

# Explicitly set below variable to "ldap" or "ldaps" as needed if using non-standard port
checkProtocol=""

# Timeout - seconds
checkTimeout="3"

### Should not need to edit below here ###

# define port to be checked
if [ "${4}" == "0" ] || [ -z "${4}" ]; then
    checkPort="${2}"
else
    checkPort="${4}"
fi

# check if it is LDAPS
if [[ "${checkPort}" == "389" ]]; then
    checkProtocol="ldap"
elif [[ "${checkPort}" == "636" ]]; then
    checkProtocol="ldaps"
fi

if ! nc -w "${checkTimeout}" -zn "${checkIP}" "${checkPort}" > /dev/null; then
    exit 42
else
    ldapsearch -H "${checkProtocol}://${checkIP}:${checkPort}" -x | grep -q "LDAP"
    exit ${?}
fi

exit 69
