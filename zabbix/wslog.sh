#!/bin/bash
################
# wslog.sh
#2016-7-14 sun
#####################
logfile="/data/logs/wslog/"
username=wsapiname
password=wsapipasswd
date8=`date "+%Y%m%d" -d "-1 day"`
date2=`date "+%Y" -d "-1 day"`
date3=`date "+%m" -d "-1 day"`
date4=`date "+%d" -d "-1 day"`
date5=`printf "%02d\n" $date3`
date6=`printf "%02d\n" $date4`
date7="$date2"-"$date3"-"$date4"
######################
seq='a.com b.com c.com'
for I in $seq ; do
mkdir -p "$logfile""$I"
logurl=`/bin/bash /shell/wslog_query_client.sh "http://dx.wslog.chinanetcenter.com/logQuery/access" "$username" "$password" "$date7-0000" "$date7-2359" "$I" 2>/dev/null|awk '{print $12}'|cut -d '"' -f2|cut -d '"' -f1`
wget -c -q $logurl -O  "$logfile""$I"/"$I"."$date8".gz &
########API接口有5秒限制########
sleep 10 
done
#delete 30 days ago nginx log files
save_days=30
find "$logfile" -mtime +$save_days -exec rm -rf {} \;
exit 0
