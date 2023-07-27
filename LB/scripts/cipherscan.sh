#!/bin/bash
PATH=/usr/bin:
######################
#
#  cipherscan.sh - Bash script to check which ciphers are available on a target system using both available versions of openssl on a Loadbalancer.org appliance.
#  Inspiration from https://www.ise.io/blog/archives/using-openssl-determine-ciphers-enabled-server/
#
#  v0.1 - 2023-07-23 - Initial write - Neil Stone <support@loadbalancer.org>
#
######################

if [ ${#} -ne 2 ]; then
    echo "Usage: ${0} IP Port"
    exit 1
fi

server=${1}
port=${2}

for openssl in /usr/local/bin/openssl /usr/bin/openssl; do
    echo "#################################"
    echo "Scanning - ${server}:${port}" with ${openssl}
    echo "#################################"

    for v in ssl2 ssl3 tls1 tls1_1 tls1_2 tls1_3; do
        for c in $(${openssl} ciphers 'ALL:eNULL' | tr ':' ' '); do
            ${openssl} s_client -connect ${server}:${port} -cipher ${c} -${v} < /dev/null > /dev/null 2>&1 && echo -e "${v}:\t${c}"
        done
    done
done

echo "#################################"
echo "Scan completed"
echo "#################################"
