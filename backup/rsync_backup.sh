#!/bin/sh
#########################################################
# Script to do incremental rsync backups
# sunny 6/3/2013
# Version 1.0
#########################################################
#
export PATH=$PATH:/bin:/usr/bin:/usr/local/bin

exec 3>>/root/rsync_backup.log
echo "====================================================" >&3
echo -e "\n[`date +%Y/%m/%d\ %H:%M:%S`] Rsync Backup Script start by $RUNUSER PID:$$" >&3

if [ -x /root/bin/mysql_backup.sh ];then
        /root/bin/mysql_backup.sh
        echo -e "[`date +%Y/%m/%d\ %H:%M:%S`] mysqldump databases" >&3
fi


LOCAL_IP=192.168.1.2                #±¾µØIP
RSYNC_SERVER=192.168.1.100          #rsyncSERVER IP
RSYNC_MOUDLE=app_backup
RSYNC_USER=cdi                       
EXCLUDES=/root/bin/rsync_exclude_file 
export RSYNC_PASSWORD=178123        #passwd

SRC='/root /etc /usr/local /var/spool/cron /home /export'

if [ -z "$LOCAL_IP" ];then
        echo -e "[`date +%Y/%m/%d\ %H:%M:%S`] LOCAL_IP is a null values; EXIT" >&3
        exit 1
fi

if [ -f $EXCLUDES ];then
        OPTIONS="--force --ignore-errors --delete -aq --exclude-from=$EXCLUDES"
else
        OPTIONS="--force --ignore-errors --delete -aq"
fi

if [ ! -e /usr/bin/rsync ];then
        echo -e "[`date +%Y/%m/%d\ %H:%M:%S`] rsync no installed, install rsync" >&3
        yum -y install rsync
        if [ $? -ne 0 ];then
                echo -e "[`date +%Y/%m/%d\ %H:%M:%S`] rsync install failed; EXIT" >&3
                exit 1
        fi
fi

## sync data
for BDIR in $SRC
do
        if [ -e $BDIR ];then
                rsync $OPTIONS $BDIR $RSYNC_USER@$RSYNC_SERVER::$RSYNC_MOUDLE/$LOCAL_IP
                echo -e "[`date +%Y/%m/%d\ %H:%M:%S`] sync $BDIR to $RSYNC_SERVER::$RSYNC_MOUDLE/$LOCAL_IP" >&3
        else
                echo -e "[`date +%Y/%m/%d\ %H:%M:%S`] $BDIR no found, sync failed" >&3
        fi
done


echo -e "[`date +%Y/%m/%d\ %H:%M:%S`] Script END" >&3
