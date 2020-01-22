#!/bin/bash
# https://ixnfo.com/en/watchdog-script.html
SERVICES="syslog-ng"
DATE=$(date '+%d-%m-%Y %H:%M:%S')

for SERVICE in ${SERVICES}
 do
   service $SERVICE status 2>&1>/dev/null
    if [ $? -ne 0 ];
      then
        service $SERVICE restart
        echo -e "Starting $SERVICE"
        (echo "Subject:Restarting $SERVICE"; echo "$DATE $SERVICE is not running on $HOSTNAME! Restarting!";) | sendmail test@ixnfo.com
      else
        echo -e "$SERVICE OK"
    fi
done

# Root Crontab Entry
# /etc/crontab
*/10 * * * * root /usr/bin/watchdog.sh > /dev/null 2>&1
