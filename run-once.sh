#!/bin/bash

# Env. Variables
# ==============
SERVER_NAME=$SERVER_NAME
DB_HOST=$DB_PORT_3306_TCP_ADDR
DB_HOSTNAME=$DB_PORT_3306_TCP_ADDR
DB_DATABASE=$DB_ENV_MYSQL_DATABASE
DB_USER=$DB_ENV_MYSQL_USER
DB_PASSWORD=$DB_ENV_MYSQL_PASSWORD

# ===============================================================================
# Modify `wp-config.php` File
#
# Need to do swap on the following parts
#
#   // ** MySQL settings - You can get this info from your web host ** //
#   /** The name of the database for WordPress */
#   define( 'DB_NAME', 'database_name_here' );
#
#   /** MySQL database username */
#   define( 'DB_USER', 'username_here' );
#
#   /** MySQL database password */
#   define( 'DB_PASSWORD', 'password_here' );
#
#   /** MySQL hostname */
#   define( 'DB_HOST', 'localhost' );
#
#   ....
#
#   define( 'AUTH_KEY',         'put your unique phrase here' );
#   define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
#   define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
#   define( 'NONCE_KEY',        'put your unique phrase here' );
#   define( 'AUTH_SALT',        'put your unique phrase here' );
#   define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
#   define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
#   define( 'NONCE_SALT',       'put your unique phrase here' );
#
#
#  For all the other keys, we will use `pwgen` (Open-Source Password Generator)
#   to help generate random string.

# Backup the `config` file if it exists.
# `/var/www/html/` is the **webroot**.
if [ -f /var/www/html/wp-config.php ]; then
  cp /var/www/html/wp-config.php /var/www/html/wp-config.php.orig
fi

# Search and replace the **string**.
sed -e "s/database_name_here/$DB_DATABASE/
s/username_here/$DB_USER/
s/password_here/$DB_PASSWORD/
s/localhost/$DB_HOST/
/'AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 32`/
/'SECURE_AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 32`/
/'LOGGED_IN_KEY'/s/put your unique phrase here/`pwgen -c -n -1 32`/
/'NONCE_KEY'/s/put your unique phrase here/`pwgen -c -n -1 32`/
/'AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 32`/
/'SECURE_AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 32`/
/'LOGGED_IN_SALT'/s/put your unique phrase here/`pwgen -c -n -1 32`/
/'NONCE_SALT'/s/put your unique phrase here/`pwgen -c -n -1 32`/" \
/var/www/html/wp-config-sample.php > /var/www/html/wp-config.php

# Increase wordpress WP_MEMORY_LIMIT
#sed -e "s/^<?php/<?php\ndefine(\'WP_MEMORY_LIMIT\', \'96M\')\;/" /var/www/html/wp-config.php > /var/www/html/wp-config.php-$$ && \
#cp /var/www/html/wp-config.php-$$ /var/www/html/wp-config.php 

# Increase wordpress WP_MEMORY_LIMIT
#/bin/cp /var/www/html/wp-includes/default-constants.php /var/www/html/wp-includes/.default-constants.php-$$ && \
#/bin/echo "define('WP_MEMORY_LIMIT', '96M');" >> /var/www/html/wp-includes/default-constants.php 

# Increase wordpress UPLOAD_MAX_FILESIZE 
#/bin/echo "upload_max_filesize = 20M" >> /var/www/html/wp-admin/php.ini && \
#/bin/echo "post_max_size = 20M"       >> /var/www/html/wp-admin/php.ini %% \
#/bin/echo "memory_limit = 64M"        >> /var/www/html/wp-admin/php.ini

# Change user:group for wp-config.php
chown www-data:www-data /var/www/html/wp-config.php

# START ALL Configuration COMMANDS that need to Run Omce
/bin/echo "upate my Timezone"
/bin/echo "$myregion/$mycountry" > /etc/timezone && \
/bin/rm /etc/localtime                           && \
/bin/ln -s /usr/share/zoneinfo/$myregion/$mycountry /etc/localtime

/bin/echo "Change root password"
/bin/echo "root:`pwgen -c -n -1 32`" |chpasswd && \
/bin/rm -rf /root/.ssh

/bin/echo "Create User n Group"
/usr/sbin/groupadd -g 1000 $myloginuser                                              && \
/usr/sbin/useradd -d /home/$myloginuser -g 1000 -m -s /bin/bash -u 1000 $myloginuser && \
/bin/echo "$myloginuser:`pwgen -c -n -1 32`" |chpasswd                               && \
/bin/mkdir /home/$myloginuser/.ssh                                                   && \
/bin/chmod 700 /home/$myloginuser/.ssh

/bin/echo "Create Openssl Self Signed Cert"
export sslcert="myssl-cert"                                                                                                                              && \
/usr/bin/openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/$sslcert.key -out /etc/ssl/certs/$sslcert.crt -subj $mysslsubject && \
/bin/chmod 644 /etc/ssl/certs/$sslcert.crt                                                                                                               && \
/bin/chmod 600 /etc/ssl/private/$sslcert.key

/bin/echo "Update the nginx config file to the final destination"
/bin/echo "Do this in provision for use with docker-compose where u want to expose volume sites-available to Host"
/bin/cp /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default    && \
/bin/rm /etc/nginx/sites-enabled/default                                       && \
/bin/ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

/bin/echo "Remove .run-once file so this will script will run one time only...."
/bin/rm -f /script.d/.run-once

