#!/bin/bash
###################
# sunny 2014/9/25 
# version 1.0     
###################
LOGFILE="/var/log/502bad_reboot_php.log"
MY_URL="http://abc.com/"
RESULT=`curl -o /dev/null -m 10 --connect-timeout 10 -s -w %{http_code} $MY_URL`
if [ "$RESULT" = "502" ]; then
killall php-fpm
sleep 1
/usr/local/php/sbin/php-fpm
echo "[`date +%y%m%d/%H:%M`]reboot php-fpm" >>${LOGFILE}
fi
exit 0
