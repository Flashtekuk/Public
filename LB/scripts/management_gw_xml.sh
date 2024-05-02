#!/bin/bash

# management_gw_xml.sh - Append required XML section to lb_config.xml for v8.9.1 to v8.11.1 upgrade
#
# v1.0 - 2024-05-02 - Initial write - Neil Stone <support@loadbalancer.org>

CFG=/etc/loadbalancer.org/lb_config.xml

sed -i.$(date -d "now" +%s) '/<\/config>/d' ${CFG}

cat << EOF >> ${CFG}
    <management_gateway>
            <gateway>no</gateway>
            <sidecar>no</sidecar>
            <ip>portal.loadbalancer.org</ip>
            <port>443</port>
            <adopted>no</adopted>
    </management_gateway>
</config>
EOF
