#!/bin/bash

echo << EOF > /usr/local/sbin/iface_busid
#!/bin/sh
for iface in "$@"; do
        cd -P /sys/class/net/$iface/device >& /dev/null || continue
        while [ $PWD != / ]; do
                case "$(readlink "$PWD/subsystem")" in
                */pci|*/vmbus)
                        echo "$iface    $(basename "$PWD")"
                        break
                        ;;
                *)
                  cd -P .. >& /dev/null || break
                        ;;
                esac
        done
done
EOF

rm -f /etc/udev/rules.d/70-lbo-set-iface-names.rules
reboot
