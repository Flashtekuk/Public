#!/bin/bash

###############################################################################
#                                                                             #
# certtest.sh - Simple script to check SSL certificates for validity          #
#                                                                             #
# (C) 2019 Loadbalancer.org                                                   #
#                                                                             #
# Will accept file names at the CLI, or will scan certs path and check those  #
#                                                                             #
# v1.1 - 2024-04-19 - Neil Stone <support@loadbalancer.org>                   #
#                                                                             #
#                                                                             #
###############################################################################

if [ $# -ge 1 ]; then
    CERTS="${*}"
else
    CERTS="$(find /etc/loadbalancer.org/certs/* -type f -name "*.pem" ! -name 'server.pem')"
#    CERTS="$(find `pwd` -type f -name "*.pem" ! -name 'server.pem' ! -name 'key*.pem')"
fi

#if [ ${CALLED_FROM_INIT} = yes ]; then
#if [ ${NAME} = stunnel ]; then
#    CERTS=$(grep cert /etc/stunnel/stunnel.conf |cut -f 2 -d\=)
#fi


NOW=$(date -d "now" +%s)

if [ ${SHLVL} = 2 ]; then
    FAIL="\e[91mFAIL\e[39m"
    PASS="\e[32mPASS\e[39m"
else
    FAIL=FAIL
    PASS=PASS
fi

echo -e "################################################################################"

for cert in ${CERTS}; do
    cert=$(readlink -f $cert)
    echo -e "Testing: ${cert}"

### General info about cert
    openssl x509 -subject -startdate -enddate  -noout -in ${cert}

### Check for 'stuff' bug
    grep -q ^stuff ${cert}
    stuffstate=$?
    if [ ${stuffstate} -eq 0 ]; then
        echo -e "${FAIL} - STUFF present"
    else
        echo -e "${PASS} - STUFF not present"
    fi

### Check for private key

    openssl rsa -in ${cert} -noout -text > /dev/null 2>/dev/null
    pkey_state=$?
    if [ ${pkey_state} -ne 0 ]; then
        echo -e "$FAIL - No private key present"
        echo -e "################################################################################"
    else
        echo -e "$PASS - Private key present"

### Check modulus
        PRIV_MOD=$(openssl rsa -noout -modulus -in ${cert})
        CERT_MOD=$(openssl x509 -noout -modulus -in ${cert})

        if [ ${PRIV_MOD} = ${CERT_MOD} ]; then
            echo -e "$PASS - Private key matches cert"
        else
            echo -e "$FAIL - Cert and private key mismatch"
        fi

### Check for start
        START_DATE=$(date -d "`openssl x509 -noout -startdate -in ${cert} | cut -f 2 -d\= `" +%s)
        if [ ${NOW} -lt ${START_DATE} ] ; then
            echo -e "$FAIL - Certificate has not started"
        else
            echo -e "$PASS - Certificate has started"
        fi

### Check for expiry
        EXPIRE_DATE=$(date -d "`openssl x509 -noout -enddate -in ${cert} | cut -f 2 -d\= `" +%s)
        if [ ${NOW} -gt ${EXPIRE_DATE} ] ; then
            echo -e "$FAIL - Certificate has expired"
        else
            echo -e "$PASS - Certificate is still valid"
        fi

### stunnel test...
#
#        cat << EOF > /tmp/stunnel-test.conf
#
#foreground = yes
#pid = /tmp/stunnel-test.pid
#
#[stunnel-test]
#        cert = ${cert}
#        ciphers = ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DHE-RSA-AES256-SHA256
#        accept = 127.6.6.6:8443
#        connect = 127.6.6.6:8080
#        delay = yes
#        options = NO_SSLv3
#        options = NO_TLSv1
#        options = NO_TLSv1.1
#        options = CIPHER_SERVER_PREFERENCE
#        options = DONT_INSERT_EMPTY_FRAGMENTS
#        renegotiation = no
#        local = 127.6.6.6
#        TIMEOUTclose = 0
#EOF
#        stunnelstate=0
#        /usr/bin/timeout -s 15 5s stunnel /tmp/stunnel-test.conf 2>&1 | grep "^\[\!\]" && stunnelstate=1
#        if [ ${stunnelstate} = 1 ] ; then
#            echo -e "${FAIL} - stunnel test fails to start"
#        else
#            echo -e "${PASS} - stunnel starts"
#        fi
#
    echo -e "################################################################################"
    fi
done

### Clean up on aisle 3
#rm -f /tmp/stunnel-test.conf
#rm -f /tmp/stunnel-test.pid

# END
