#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
######################
#
#  cipherscan.sh - Bash script to check which ciphers are available on a target system using both available versions of openssl on a Loadbalancer.org appliance.
#  Inspiration from https://www.ise.io/blog/archives/using-openssl-determine-ciphers-enabled-server/
#
#  v0.1 - 2023-07-27 - Initial write - Neil Stone <support@loadbalancer.org>
#  v0.2 - 2023-07-27 - Added basic check for port contactability, renamed a few vaiables - Neil Stone <support@loadbalancer.org>
#  v0.3 - 2023-07-28 - Added support for check support from haproxy.cfg - Neil Stone <support@loadbalancer.org>
#  v0.4 - 2023-07-28 - Relocated a lost 'done' - Neil Stone <support@loadbalancer.org>
#  v0.5 - 2025-01-14 - Made echo statement look prettier (thanks Harry) - Neil Stone <support@loadbalancer.org>
#
######################

if [ ${#} -ne 2 ]; then
    echo "Usage: ${0} IP Port"
    exit 1
fi

SERVER=${1}
PORT=${2}

nc -w 5 -zv ${SERVER} ${PORT}
NC_EC=${?}
if [ ${NC_EC} != 0 ]; then
    echo "Unable to connect to ${SERVER} on port ${PORT}"
    exit 2
fi

for OPENSSL in /usr/local/bin/openssl /usr/bin/openssl; do
    echo "#################################"
    echo "Scanning - ${SERVER}:${PORT} with ${OPENSSL}"
    echo "#################################"
    for VER in ssl2 ssl3 tls1 tls1_1 tls1_2; do
        for CIPHER in $(${OPENSSL} ciphers 'ALL:eNULL' | tr ':' ' '); do
            ${OPENSSL} s_client -connect ${SERVER}:${PORT} -cipher ${CIPHER} -${VER} < /dev/null > /dev/null 2>&1 && echo -e "${VER}:\t${CIPHER}"
        done
    done
done

for OPENSSL in /usr/local/bin/openssl /usr/bin/openssl; do
    echo "#################################"
    echo "Scanning target system for ciphers supported from haproxy.cfg with ${OPENSSL}"
    echo "#################################"
    for VER in ssl2 ssl3 tls1 tls1_1 tls1_2; do
        for CIPHER in $(awk -F\" '/ssl-default-server-ciphers\ /{print $2}' /etc/haproxy/haproxy.cfg |  tr ':' ' '); do
            ${OPENSSL} s_client -connect ${SERVER}:${PORT} -cipher ${CIPHER} -${VER} < /dev/null > /dev/null 2>&1 && echo -e "${VER}:\t${CIPHER}"
        done
    done
    for VER in tls1_3; do
        for CIPHERSUITE in $(awk -F\" '/ssl-default-server-ciphersuites\ /{print $2}' /etc/haproxy/haproxy.cfg |  tr ':' ' '); do
            ${OPENSSL} s_client -connect ${SERVER}:${PORT} -cipher ${CIPHERSUITE} -${VER} < /dev/null > /dev/null 2>&1 && echo -e "${VER}:\t${CIPHERSUITE}"
        done
    done
done

echo "#################################"
echo "Scan completed"
echo "#################################"
