#!/bin/bash
##
#
# apt update ; apt upgrade -y ; curl -4 -o /root/webserver-setup.sh https://github.com/Flashtekuk/Public/blob/master/webserver-setup.sh; chmod +x /root/webserver-setup.sh

echo "##############################################"
echo ""
read -p "Enter desired hostname: " SITE_NAME
echo ""
read -s -p "Input MySQL root password: " MYSQL_PASS
echo ""
read -p "Enter email address for letsencrypt: " EMAIL_ADDRESS
echo ""
echo ""
echo "##############################################"

if [ $# -gt 0 ]; then
	INSTALL=${1}
	else
	INSTALL="DRUPAL"
fi

##
# Update and upgrade everything
#
apt update ; apt upgrade -y
apt install -y dnsutils

##
# Set some vars ready for sanity check
#
MY_IP="$(curl ifconfig.me/ip)"
REAL_IP="$(dig +short ${SITE_NAME})"

##
# Sanity check that the DNS record for ${SITE} matched the public IP for this system
#
if [ ${MY_IP} != ${REAL_IP} ]; then
	echo "DNS vs IP mismatch: ${MY_IP} != ${REAL_IP}"
	exit 69
fi

##
# Install required packages
#
apt install -y mariadb-server apache2 php curl screen rsync wget php-mysql php-gd php-dom \
		php-mbstring php-pear php-zip php-dev pwgen git zip unzip certbot \
		python-certbot-apache php-apcu php-curl libphp-phpmailer

DRUPAL_URL="https://www.drupal.org/download-latest/tar.gz"
WEB_ROOT="/var/www/html"
SITE_FILES="${WEB_ROOT}/sites/default/files"

SITE_DB="sitedb"
SITE_DB_USER="sitedbuser"
SITE_DB_PASS="$(pwgen -cnsB 10 1)"

##
# Install php uploadprogress plugin
#
pecl install uploadprogress
echo "extension=uploadprogress.so" > /etc/php/7.3/mods-available/uploadprogress.ini
phpenmod uploadprogress

##
# Generate SSL certificate
#
certbot --apache -n -m ${EMAIL_ADDRESS} --agree-tos --keep -d ${SITE_NAME}
# --test

##
# Configure apache site settings
#
cat << EOF > /etc/apache2/conf-available/mysite.conf
<Directory /var/www/html>
	Options FollowSymLinks
	AllowOverride All
	Require all granted
	RewriteCond  %{REQUEST_FILENAME} !^/$
	RewriteCond  %{REQUEST_FILENAME} !^/(files|misc|uploads)(/.*)?
	RewriteCond  %{REQUEST_FILENAME} !\.(php|ico|png|jpg|gif|css|js|html?)(\W.*)?
	RewriteRule ^(.*)$ /index.php?q=$1 [L,QSA]
</Directory>
EOF

cat << EOF > /etc/apache2/sites-available/ssl-site.conf
<IfModule mod_ssl.c>
        <VirtualHost _default_:443>
		ServerAdmin webmaster@localhost
		DocumentRoot /var/www/html

		ErrorLog ${APACHE_LOG_DIR}/error.log
		CustomLog ${APACHE_LOG_DIR}/access.log combined

		SSLCertificateFile /etc/letsencrypt/live/${SITE_NAME}/fullchain.pem
		SSLCertificateKeyFile /etc/letsencrypt/live/${SITE_NAME}/privkey.pem
		Include /etc/letsencrypt/options-ssl-apache.conf

		<FilesMatch "\.(cgi|shtml|phtml|php)$">
			SSLOptions +StdEnvVars
		</FilesMatch>
		<Directory /usr/lib/cgi-bin>
			SSLOptions +StdEnvVars
		</Directory>
	</VirtualHost>
</IfModule>

EOF

##
# Set SSL ciphers and protocols to sensible settings
#
sed -i.bak /etc/letsencrypt/options-ssl-apache.conf \
	-e 's/SSLProtocol             all -SSLv2 -SSLv3/SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1/' \
	-e 's/SSLCipherSuite          ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS/SSLCipherSuite ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256/'

##
# Enable custom config
#
a2ensite ssl-site
a2enconf mysite

##
# Enable required modules
#
a2enmod rewrite
a2enmod headers
a2enmod remoteip
a2enmod ssl
# Might want this at a later point
#a2enmod http2

##
# Stop so we don't trip over our own feets
#
systemctl stop apache2

##
# Secure MySQL
#
printf "\ny\n${MYSQL_PASS}\n${MYSQL_PASS}\ny\ny\ny\ny\n" | mysql_secure_installation

##
# Create MySQL database and assign rights
#
mysqladmin -u root -p${MYSQL_PASS} create ${SITE_DB}
echo "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON ${SITE_DB}.* TO '${SITE_DB_USER}'@'localhost' IDENTIFIED BY '${SITE_DB_PASS}';" | mysql -u root -p${MYSQL_PASS} ${SITE_DB}

echo ""
echo "MySQL: ${MYSQL_PASS}" >> /root/site_details.txt
echo "Database: ${SITE_DB}" >> /root/site_details.txt
echo "User: ${SITE_DB_USER}" >> /root/site_details.txt
echo "Pass: ${SITE_DB_PASS}" >> /root/site_details.txt
echo ""

unset MYSQL_PASS SITE_DB_PASS

if [ ${INSTALL} = "DRUPAL" ]; then

##
# Move old DocumentRoot files out the way
#
cd ${WEB_ROOT} ; cd ..
mv ${WEB_ROOT} ${WEB_ROOT}-old

##
# Download and unpack Drupal latest
#
wget -c ${DRUPAL_URL}
tar xf tar.gz
mv drupal-* html

##
# Set ownership ahd group write of DocumentRoot files
#
chown -R www-data:www-data ${WEB_ROOT}
chmod -R g+wr ${WEB_ROOT}

##
# Install composer
#
cd ${WEB_ROOT}
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --quiet
rm composer-setup.php
mv composer.phar /usr/local/bin/composer ; chmod +x /usr/local/bin/composer

##
# Install drush
#
curl -OL https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar
mv drush.phar /usr/local/bin/drush ; chmod +x /usr/local/bin/drush

##
# Provide feedback to user for DB settings etc.
#
echo ""
echo "Add the following to ${WEB_ROOT}/sites/default/settings.php once installation is complete;"
echo ""
SITE_NAME_PHP=$(echo ${SITE_NAME}|sed -e 's:\.:\\\.:g' )
MY_IP_PHP=$(echo ${MY_IP}|sed -e 's:\.:\\\.:g' )
echo -e "\$settings['trusted_host_patterns'] = [
  '${MY_IP_PHP}',
  '${MY_IP}',
  '^${SITE_NAME_PHP}$',
  '^.+\.${SITE_NAME_PHP}$'
];"
echo ""

echo ""
echo "After site config run:"
echo "cd ${WEB_ROOT} ; composer require drush/drush"
echo "to add in the drush requirements"
echo ""

##
# In case a cache cleanup is needed
#
echo ""
echo "If things are a little wonky, run;"
echo ""
echo "drush sset system.maintenance_mode 1"
echo "drush cr"
echo "drush sset system.maintenance_mode 0"
echo ""
echo "Enjoy :-)"
echo ""
echo "You should now configure the site via https://${SITE_NAME}"
echo "and the following credentials;"
echo ""
cat /root/site_details.txt
echo ""

fi

##
# Bring Apache2 back up so we can access WebUI...
#
systemctl start apache2
