#!/bin/bash
#
#########################################################
# Mysql Database Backup Script
# sunny 18/09/2015
# Version 1.1
#########################################################

export PATH=$PATH:/bin:/usr/bin:/usr/local/bin:/usr/local/mysql/bin

### Mysql Info
BACKUP_USER="root"                  #mysql帐号
BACKUP_PASSWD="admin"               #mysql密码
BACKUP_HOME="/mysqlback"            
BACKUP_DATE=`date +%Y%m%d`                 
BACKUP_DIR="$BACKUP_HOME/$BACKUP_DATE"

MYSQLBIN='/usr/local/mysql/bin'
DATADIR='/export/data/mysql'        #mysql_datadir存放位置
DATABASES=`echo 'show databases;' | $MYSQLBIN/mysql -u$BACKUP_USER -p$BACKUP_PASSWD |sed -n '3,$p' |grep -v performance_schema`
save_days=30       #本地保存30

umask 077

if [ ! -d $BACKUP_DIR ];then
        mkdir -p $BACKUP_DIR
fi

exec 3>>/root/mysqlbackup.log
echo -e "\n[`date +%Y/%m/%d\ %H:%M:%S`] Database Backup Script start by $RUNUSER PID:$$" >&3

### backup mysql
DATA_SIZE=`du -sk $DATA_DIR| awk -F" " '{print $1}'`
DISK_INFO=(`df -k / | sed -n '2,$p'`)
DISK_SPACE=`echo ${DISK_INFO[3]}`
/usr/bin/test $DISK_SPACE -gt $(($DATA_SIZE+1024000))
RETVAL=$?
if [ $RETVAL -ne 0 ];then
        echo "Disk does not have space"
        exit 1
else
        cd $BACKUP_DIR
        for DB in $DATABASES
        do
                echo -e "[`date +%Y/%m/%d\ %H:%M:%S`] $DB backup start" >&3
                $MYSQLBIN/mysqldump --opt -u$BACKUP_USER -p$BACKUP_PASSWD $DB |gzip >${DB}-`date +%Y%m%d`.sql.gz
                echo -e "[`date +%Y/%m/%d\ %H:%M:%S`] $DB backup end" >&3
                echo "" >&3
        done
fi
########## delete 30 day mysql backup#########
find $BACKUP_HOME -mtime +$save_days -exec rm -rf {} \;
exit 0
