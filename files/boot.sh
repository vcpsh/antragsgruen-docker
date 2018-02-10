#!/bin/bash

if [ ! -z ${TIMEZONE+x} ]; then echo "$TIMEZONE" > /etc/timezone fi

if [ -z ${WWW_UID+x} ]; then WWW_UID="$(id -u $WORKINGUSER)"; export WWW_UID; fi
if [ -z ${WWW_GID+x} ]; then WWW_GID="$(id -g $WORKINGGROUP)"; export WWW_GID; fi

if [ ! -z ${SMTP_HOST+x} ] && [ ! -z ${SMTP_FROM+x} ] && [ ! -z ${SMTP_PASS+x} ]; then
    j2 /templates/msmtprc.j2 > /etc/msmtprc
fi

chown -R $WORKINGUSER:$WORKINGGROUP $WORKINGDIR

cd $WORKINGDIR
sudo -u $WORKINGUSER composer global require "fxp/composer-asset-plugin:1.3.1"
sudo -u $WORKINGUSER composer install --prefer-dist
sudo -u $WORKINGUSER npm install
sudo -u $WORKINGUSER npm run build

if [ -f $WORKINGDIR/config/config.json ]; then
    sudo -u $WORKINGUSER expect -c "spawn $WORKINGDIR/yii migrate; expect -re \"Apply the above migrations?.*\"; send 'yes\r\n';"
else
    sudo -u $WORKINGUSER touch $WORKINGDIR/config/INSTALLING
fi
