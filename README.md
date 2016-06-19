# wordpress-nginx-selfsignedcert
Docker wordpress on nginx, php-fpm, self-sign-cert, ubuntu 16.04

## Description
A Dockerfile that installs ubuntu 16.04 with wordpress 4.5.2, nginx 1.10.0, and php-fpm 7.0 based on
docker-wordpress-nginx-fpm-ssl. Database not included.

Use the following docker-compose.yml for quick stand up wordpress with mysql 5.7.
Create File: docker-compose.yml

# docker-compose.yml

    wordpress:
        image: knnleow/mynginxwordpress_args:1.1
            environment:
            SERVER_NAME: www.demo.co
            mysslsubject: "/C=SG/ST=Singapore/L=Singapore/O=demo.co/OU=DEMO_Lab/CN=svr01.demo.co/emailAddress=admin@demo.co"
            myloginuser: admin
            myregion: Asia
            mycountry: Singapore
        ports:
            - "80:80"
            - "443:443"
        links:
            - mysql:db
        volumes:
            - ./nginx/log:/var/log/nginx
            - ./nginx/sites-available:/etc/nginx/sites-available
            - ./letsencrypt:/etc/letsencrypt

    mysql:
        image: mysql:5.7
        environment:
            # DB prefix is determine by the links alias definition above from wordpress
            # MYSQL_ROOT_PASSWORD: mysql variable map up as DB_ENV_MYSQL_ROOT_PASSWORD
            # MYSQL_DATABASE:  mysql variable mapped up as DB_ENV_MYSQL_DATABASE
            # MYSQL_USER: mysql variable mapped up as DB_ENV_MYSQL_USER 
            # MYSQL_PASSWORD: mysql variable mapped up as DB_ENV_MYSQL_PASSWORD
            MYSQL_ROOT_PASSWORD: 12qwaszx34erdfcv
            MYSQL_DATABASE: wordpressDB01
            MYSQL_USER: wordpressUSER01
            MYSQL_PASSWORD: 21wqsaxz43refdvc
        volumes:
            - ./mysql/backup:/backup
            
