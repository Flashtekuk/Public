#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

###
#
# Script to set "Local Configuration" --> "Physical Advanced" settings on Loadbalancer.org appliances
#
# v1.0 - Initial write - 2023-01-26 - Neil Stone <support@loadbalancer.org>
#
###
#
# NOTE: Valid values ARE case sensitive
#
###

USERNAME=loadbalancer # WebUI username
PASSWORD=loadbalancer # WebUI password
LB_IP=192.168.87.1 # WebUI IP address
LB_PORT=9443 # WebUI HTTPs port

# Network Proxy
PROXY_IP=WebProxy # default is blank
PROXY_PORT=3128 # default is blank
PROXY_USERNAME=MyProxyUsername # default is blank
PROXY_PASSWORD=MyProxyPassword # default is blank

# Management Gateway
MANAGEMENT_IFACE=192.168.87.1 # default is blank
MANAGEMENT_GATEWAY= # default is blank

# Firewall
CONNTRACK_TABLE_SIZE=524288 # default is 52488

# Interface Offload
OFFLOAD_ENABLE=on # on | off # default is on

# Online Updates
UPDATE_SERVER=update.loadbalancer.org # default is update.loadbalancer.org
UPDATE_CHECK=on # on | off - default is on

# SMTP Relay
SMTP_RELAY=192.168.120.225 # SMTP relay host # default is blank

# Logging
SYSLOG_INTERVAL=30
SYSLOG_BURST=1000
SYSLOG_DESTINATION=both # local | remote | both # default to local
SYSLOG_IP=192.168.120.250 # IP | hostname # default is blank
SYSLOG_PORT=514
SYSLOG_PROTO=TCP # TCP | UDP
SYSLOG_REMOTE_TEMPLATE="" # default is blank

curl --insecure -u ${USERNAME}:${PASSWORD} -X POST \
\
	--form internet_proxy_ip=${PROXY_USERNAME} \
	--form internet_proxy_port=${PROXY_PORT} \
	--form proxyUsername=${PROXY_USERNAME} \
	--form proxyPassword=${PROXY_PASSWORD} \
\
	--form mgt_iface=${MANAGEMENT_IFACE} \
	--form management_gateway=${MANAGEMENT_GATEWAY} \
\
	--form conntrack_table_size=${CONNTRACK_TABLE_SIZE} \
\
	--form enable_offload=${OFFLOAD_ENABLE} \
\
	--form update_server=${UPDATE_SERVER} \
	--form auto_check_for_updates=${UPDATE_CHECK} \
\
	--form smarthost=${SMTP_RELAY} \
\
	--form syslog_ratelimit_interval=${SYSLOG_INTERVAL} \
	--form syslog_ratelimit_burst=${SYSLOG_BURST} \
	--form syslog_destination=${SYSLOG_DESTINATION} \
	--form syslog_remote_ip=${SYSLOG_IP} \
	--form syslog_remote_port=${SYSLOG_PORT} \
	--form syslog_remote_protocol=${SYSLOG_PROTO} \
	--form syslog_remote_template="${SYSLOG_REMOTE_TEMPLATE}" \
\
	--silent --output /dev/null \
	https://${LB_IP}:${LB_PORT}/lbadmin/config/physicaladv.php?action=set

CURL_EC=${?}

exit ${CURL_EC}
