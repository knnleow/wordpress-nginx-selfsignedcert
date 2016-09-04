FROM ubuntu:16.04

MAINTAINER Kuenn Leow <knnleow@gmail.com>

EXPOSE 80 443

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

ARG mysslsubject="/C=SG/ST=Singapore/L=Singapore/O=demo.co/OU=DEMO_Lab/CN=svr01.demo.co/emailAddress=user01@demo.co"
ARG myloginuser="demouser"
ARG myregion="Asia"
ARG mycountry="Singapore"

RUN apt-get update && apt-get upgrade -y 
RUN apt-get autoremove -y

RUN TITLE="Install all my common packages" && \
apt-get install -y \
 apache2-utils \
 curl \
 vim \
 wget \
 whois \
 inetutils-ping \
 lynx \
 telnet \
 host \
 dnsutils \
 htdig \
 pwgen \
 python-setuptools \
 unzip \
 git

RUN TITLE="Install php packages" && \ 
apt-get install -y \
 php7.0 \
 php7.0-fpm \
 php7.0-mysql

RUN TITLE="Install mysql client" && \
apt-get install -y \
 mysql-client

RUN TITLE="Install Wordpress Dependencies" && \
apt-get install -y \
 php7.0-curl \
 php7.0-gd \
 php7.0-intl \
 php7.0-imap \
 php7.0-mcrypt \
 php7.0-pspell \
 php7.0-recode \
 php7.0-sqlite \
 php7.0-tidy \
 php7.0-xmlrpc \
 php7.0-xsl \
 php7.0-cli \
 php-pear \
 php-imagick \
 php-memcache

RUN TITLE="Install nginx packages" && \
apt-get install -y \
 nginx

RUN TITLE="Add template.d n  script.d Folders" && \
 rm -f /etc/nginx/sites-enabled/default
ADD template.d/nginx/default-kuenn-php7.0-fastcgi-selfsignedcert  /etc/nginx/sites-enabled/default
ADD script.d/run-all.sh-php7-ubt1604 /script.d/run-all.sh
ADD script.d/run-once.sh /script.d/run-once.sh
ADD script.d/run-once.txt /script.d/.run-once

RUN TITLE="Change Permission script.d Folders" && \
 chmod 755 /script.d/*.sh

RUN TITLE="PHP-fpm Config - cgi.fix_pathinfo 0" && \
 cp /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini-$$ && \
 sed -i -e "s/;cgi.fix_pathinfo\s*=\s*1/cgi.fix_pathinfo = 0/g" /etc/php/7.0/fpm/php.ini
RUN TITLE="PHP-fpm Config - expose_php Off" && \
 sed -i -e "s/expose_php\s*=\s*On/expose_php = Off/g"           /etc/php/7.0/fpm/php.ini
RUN TITLE="PHP-fpm Config - upload_max_filesize 10M" && \
 sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 10M/g; \
            s/post_max_size\s*=\s*8M/post_max_size = 10M/g"     /etc/php/7.0/fpm/php.ini
RUN TITLE="PHP-fpm Config - post_max_size 10M" && \
 sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 10M/g"     /etc/php/7.0/fpm/php.ini
RUN TITLE="PHP-fpm Config - daemonize no" && \
 cp /etc/php/7.0/fpm/php-fpm.conf /etc/php/7.0/fpm/php-fpm.conf-$$ && \
 sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g"            /etc/php/7.0/fpm/php-fpm.conf
RUN TITLE="PHP-fpm Config - catch_workers_output yes" && \
 cp /etc/php/7.0/fpm/pool.d/www.conf /etc/php/7.0/fpm/pool.d/www.conf-$$ && \
 sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g; s/listen\s*=\s*\/var\/run\/php\/7.0\/fpm.sock/listen = 127.0.0.1:9000/g; \
            s/;listen.allowed_clients\s*=\s*127.0.0.1/listen.allowed_clients = 127.0.0.1/g" /etc/php/7.0/fpm/pool.d/www.conf
RUN TITLE="PHP-fpm Config - listen 127.0.0.0:9000" && \
 sed -i -e "s/listen\s*=\s*\/var\/run\/php\/7.0\/fpm.sock/listen = 127.0.0.1:9000/g"        /etc/php/7.0/fpm/pool.d/www.conf
RUN TITLE="PHP-fpm Config - listen.allowed_clients 127.0.0.1" && \
 sed -i -e "s/;listen.allowed_clients\s*=\s*127.0.0.1/listen.allowed_clients = 127.0.0.1/g" /etc/php/7.0/fpm/pool.d/www.conf

RUN TITLE="Install Wordpress" && \
 cd /var/www/ && \
 curl -o wp-latest.tar.gz https://wordpress.org/latest.tar.gz && \
 tar -xvf wp-latest.tar.gz && \
 rm wp-latest.tar.gz

RUN TITLE="Copy Wordpress to **webroot** - /var/www/html" && \
 mv /var/www/html /var/www/html-original && \
 mv /var/www/wordpress /var/www/html && \
 chown -R www-data:www-data /var/www/html

RUN TITLE="update Wordpress php.ini - increase upload_max_filesize post_max_size memory_limit" && \
 echo "upload_max_filesize = 20M" > /var/www/html/wp-admin/php.ini && \
 echo "post_max_size = 20M"      >> /var/www/html/wp-admin/php.ini && \
 echo "memory_limit = 64M"       >> /var/www/html/wp-admin/php.ini

RUN TITLE="Create phpinfo.php file - Troubleshotting" && \
 /bin/echo "<?php phpinfo (); ?>" > /var/www/html/phpinfo.php.txt 

RUN TITLE="Create nginx web folders" && \
 mkdir /var/www/html/peoples && \
 mkdir /var/www/html/products && \
 mkdir /var/www/html/static && \
 mkdir /var/www/html/.well-known

# Command to run
ENTRYPOINT ["/script.d/run-all.sh"]
CMD [""]
