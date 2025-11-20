#!/bin/bash

######
#
# max-buffers.sh - Script to set max ring buffers on network interfaces
#
# v1.0 - 2025-11-20 - Neil Stone <support@loadbalancer.org>
#
######

if [ $# -ne 1 ] ; then
    echo "Usage: $0 ethX"
    exit 3
fi

INTERFACE=${1}

# Get the max values and set them
MAX_RX=$(ethtool -g "${INTERFACE}" | awk /RX:/'{print $NF}' | head -1)
MAX_TX=$(ethtool -g "${INTERFACE}" | awk /TX:/'{print $NF}' | head -1)

if [ -n "${MAX_RX}" ] && [ -n "${MAX_TX}" ]; then
    ethtool -G "${INTERFACE}" rx "${MAX_RX}"
    ethtool -G "${INTERFACE}" tx "${MAX_TX}"
fi
