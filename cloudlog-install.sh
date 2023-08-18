#!/bin/bash

echo ""
read -s -p "Input desired MySQL root password: " MYSQL_PASS
echo ""

PHPVER=7.4
INSTPATH=/var/www/html
DB="cloudlog"
DB_USER="cloudloguser"
DB_PASS="$(pwgen -cnsB 10 1)"

##################### Below here be dragons ########################################

apt install -y git htop rsync curl pwgen screen wget mariadb-server apache2 \
	php${PHPVER} php${PHPVER}-curl php${PHPVER}-mysql \
	php${PHPVER}-mbstring php${PHPVER}-xml # php${PHPVER}-openssl

rm -rf ${INSTPATH}
mkdir ${INSTPATH}
git clone https://github.com/magicbug/Cloudlog.git ${INSTPATH}
chown -R www-data:www-data ${INSTPATH}

a2enmod php${PHPVER}
a2enmod rewrite
systemctl restart apache2

printf "\ny\n${MYSQL_PASS}\n${MYSQL_PASS}\ny\ny\ny\ny\n" | mysql_secure_installation
mysqladmin -u root -p${MYSQL_PASS} create ${DB}
echo "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON ${DB}.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';" | mysql -u root -p${MYSQL_PASS} ${DB}
unset MYSQL_PASS

echo ""
echo "All done..."
echo ""

echo "Database name: ${DB}" | tee -a /root/cloudlog-creds.txt
echo "Database user: ${DB_USER}" | tee -a /root/cloudlog-creds.tx
echo "Database pass: ${DB_PASS}" | tee -a /root/cloudlog-creds.tx
echo ""

unset DB
unset DB_USER
unset DB_PASS
unset PHPVER
