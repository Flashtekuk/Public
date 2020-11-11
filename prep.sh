#!/bin/bash
##
#
# apt update ; apt upgrade -y ; curl -4 -o /root/prep.sh https://raw.githubusercontent.com/Flashtekuk/Public/master/prep.sh; chmod +x /root/prep.sh

##
# Install packages
#
apt install -y screen rsync htop curl qemu-guest-agent xinetd

##
# My personal customisations
#
mkdir -p /root/.ssh -m 0600
echo "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJd2lcSaoR2rpBhonj08A5ouX0EaoIqhzuHcD8rc7TjMHh8qHtCO20mfVl73AXUNGg2hNSDzhMeWHvSGf5au2/4= neil@threadripper" >> /root/.ssh/authorized_keys
echo "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCcrLX1MVmzCsxz7KiHyjdICZU91hnrok5IY9E6kIoZK0Q379xiNEYuGSBCuitZcumYd41bra+hyaM/pQMBMb1A= neil@IntTest1" >> /root/.ssh/authorized_keys

groupadd wheel
gpasswd -a neil wheel

sed -i.bak -e 's/# auth       sufficient pam_wheel.so trust/auth       sufficient pam_wheel.so trust/g' /etc/pam.d/su

cp -a /root/.ssh /home/neil ; chown neil.neil /home/neil/.ssh -R ; chmod 0700 /home/neil/.ssh

echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'" >> /root/.bashrc

cat << EOF > /etc/xinetd.d/lb-feedback
# default: on
# description: lb-feedback socket server
service lb-feedback
{
   port            = 3333
   socket_type     = stream
   flags           = REUSE
   wait            = no
   user            = nobody
   server          = /usr/bin/lb-feedback.sh
   log_on_success  += USERID
   log_on_failure  += USERID
   disable         = no
}
EOF

cat << EOF > /usr/bin/lb-feedback.sh
#!/bin/bash
LOAD=\`/usr/bin/vmstat 1 2| /usr/bin/tail -1| /usr/bin/awk '{print \$15;}' | /usr/bin/tee\`
echo "\${LOAD}%"
#This outputs a 1 second average CPU idle
EOF
chmod +x /usr/bin/lb-feedback.sh

echo "lb-feedback 3333/tcp # Loadbalancer.org feedback daemon" >> /etc/services

service xinetd restart

#
# End of my personal customisations
##

##
# Download webserver-setup.sh
#
curl -o /root/webserver-setup.sh https://raw.githubusercontent.com/Flashtekuk/Public/master/webserver-setup.sh
curl -o /root/post.sh https://raw.githubusercontent.com/Flashtekuk/Public/master/post.sh
chmod +x /root/*.sh
