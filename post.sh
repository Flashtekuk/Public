#!/bin/bash

gpasswd -a neil www-data

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.4.0/utils/wp-completion.bash
mv wp-completion.bash /etc/bash_completion.d/

# Netdata monitoring
curl -s https://packagecloud.io/install/repositories/netdata/netdata/script.deb.sh | bash
apt install -y netdata
netdata-claim.sh -token=piBpU6UlFvRHCrLybO8oaqY3yBcIvo7OleJSX6gFHMAwD1ijLkAtA4RKzYFhnqmk8dDc3ctxP27L-Wj-xQPC9SeQqYRGkgLgjUIM8lYE4f7bpKLQOU3ls-Gs69i3OMw13r-24VM -rooms=b16a5c65-1e08-4a38-80d1-dbd8685cf31d -url=https://app.netdata.cloud
/etc/init.d/netdata restart
