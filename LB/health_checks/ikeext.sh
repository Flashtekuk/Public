#!/bin/bash

rip="${3}"
timeout=3
sshuser=root

result=$(timeout ${timeout} ssh -l ${sshuser} ${rip} -- 'get-service ikeext | select status -ExpandProperty status')

if [[ "${result}" == *"Running"* ]]; then
    exit 0
else
    exit 42
fi
