#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

###
#
# Script to set "Local Configuration" --> "Physical Advanced" settings on Loadbalancer.org appliances
#
# v1.0 - Initial write - 2023-01-26 - Neil Stone <support@loadbalancer.org>
# v1.1 - Additional logic to handle IP address on the CLI - 2023-01-27 - Neil Stone <support@loadbalancer.org>
# v1.2 - Show exit state from cURL if not 0 - 2023-01-27 - Neil Stone <support@loadbalancer.org>
# v1.3 - Quickly check if the LB IP and port are contactable - 2023-01-27 - Neil Stone <support@loadbalancer.org>
# v1.4 - Change MGMT_IFACE varname and provide confirm on exit - 2023-01-27 - Neil Stone <support@loadbalancer.org>
# v1.5 - ping the LB to see if basic life signs - 2023-01-27 - Neil Stone <support@loadbalancer.org>
# v1.6 - Show exit states on all non 0 exits, refer to man page for appropriate binary - 2023-01-27 - Neil Stone <support@loadbalancer.org>
#
###
#
# NOTE: Valid values ARE case sensitive
#
###

if [ ${#} -ne 1 ]; then
	echo "Usage: ${0} IP"
	exit 7
fi

# WebUI credentials
USERNAME=loadbalancer  # WebUI username
PASSWORD=loadbalancer  # WebUI password
LB_IP=${1}             # WebUI IP address
LB_PORT=9443           # WebUI HTTPs port

# Network Proxy
PROXY_IP=""        # default is blank
PROXY_PORT=""      # default is blank
PROXY_USERNAME=""  # default is blank
PROXY_PASSWORD=""  # default is blank

# Management Gateway
MANAGEMENT_IP=""   # default is blank
MANAGEMENT_GATEWAY="" # default is blank

# Firewall
CONNTRACK_TABLE_SIZE=524288 # default is 52488

# Interface Offload
OFFLOAD_ENABLE=on # on | off # default is on

# Online Updates
UPDATE_SERVER=update.loadbalancer.org  # default is update.loadbalancer.org
UPDATE_CHECK=on                        # on | off - default is on

# SMTP Relay
SMTP_RELAY="" # SMTP relay host # default is blank

# Logging
SYSLOG_INTERVAL=30         # default is 30
SYSLOG_BURST=1000          # default is 1000
SYSLOG_DESTINATION=both    # local | remote | both # default is local
SYSLOG_IP=10.69.42.255     # IP | hostname # default is blank
SYSLOG_PORT=514            # default is 514
SYSLOG_PROTO=TCP           # TCP | UDP # default is TCP
SYSLOG_REMOTE_TEMPLATE=""  # default is blank

# Ping LB to see if it's alive
ping -q -c 1 ${LB_IP} 2>/dev/null
PING_EC=${?}
if [ ${PING_EC} -ne 0 ]; then
	echo "Ping to ${LB_IP} failed - exit state ${PING_EC} - check 'man ping' "
	exit ${PING_EC}
fi

# Quickly check if the LB IP and Port are contactable
nc -zv -w 5 ${LB_IP} ${LB_PORT} 2>/dev/null 1>&2
NC_EC=${?}
if [ ${NC_EC} -ne 0 ]; then
	echo "Unable to contact ${LB_IP} on port ${LB_PORT} - exit state ${NC_EC} - check 'man nc' "
	exit ${NC_EC}
fi

# Make the post...
curl --insecure -u ${USERNAME}:${PASSWORD} -X POST \
\
	--form internet_proxy_ip=${PROXY_USERNAME} \
	--form internet_proxy_port=${PROXY_PORT} \
	--form proxyUsername=${PROXY_USERNAME} \
	--form proxyPassword=${PROXY_PASSWORD} \
\
	--form mgt_iface=${MANAGEMENT_IP} \
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
if [ ${CURL_EC} -ne 0 ]; then
	echo "cURL exited with an error - exit state ${CURL_EC} - check 'man curl' "
	exit ${CURL_EC}
fi

echo "Update to ${LB_IP} completed."
exit 0
