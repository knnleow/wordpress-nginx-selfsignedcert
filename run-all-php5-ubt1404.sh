#!/bin/bash

/bin/echo "RUN ALL Custom Script Here...."

# Initialize first run
if [[ -e /script.d/.run-once ]]; then
    /script.d/run-once.sh
fi

/bin/echo "Starting nginx"
/usr/sbin/service nginx stop && \
/usr/sbin/service nginx start

/bin/echo "Starting php5-fpm"
/usr/sbin/service php5-fpm stop && \
/usr/sbin/service php5-fpm start

/usr/bin/tail -f /var/log/*log /var/log/nginx/*log
