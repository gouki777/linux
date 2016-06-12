#!/bin/bash
###############
#2015-2-5
#sunny make
###############
DBdate=` date +%Y%m%d `
dbdate1=`date -d $(date -d "-10 day" +%Y%m%d) +%s`
dbdate2=`date -d $(date -d "-10 day" +%Y%m%d) +%s`
User=zabbix
Passwd="cndy.org"
/usr/bin/mysqldump zabbix > /shell/${DBdate}zabbix.sql -u$User -p$Passwd   #备份DB
sleep 2
##############优化清理历史数据##########
/usr/bin/mysql -u$User -p$Passwd -e "
use zabbix;
delete from events where 'clock' <$dbdate1;
delete from history where 'clock' <$dbdate1;
delete from history_uint where 'clock' <$dbdate1;
delete from trends where 'clock' <$dbdate2;
delete from trends_uint where 'clock' <$dbdate2;
optimize table events,trends,trends_uint,history,history_uint;
"
exit 0
