#!/bin/bash
PATH=/bin

###############################################################################
#
# haproxy-certs.sh - Create symlinks for all PEM files in Loadbalancer.org
#  appliance cert store in a single directory to allow HAProxy to use this as a
#  certificate store.
#
# v1.0 - NStone <support@loadbalancer.org> - 2024-11-20 - Initial write
#
###############################################################################

mkdir -p /etc/loadbalancer.org/certs/dir/
for CERT in $(find /etc/loadbalancer.org/certs/ -type f -name *.pem) ; do
	ln -sf ${CERT} /etc/loadbalancer.org/certs/dir/ ;
done
