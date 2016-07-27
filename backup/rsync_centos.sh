#!/bin/bash
# -------------------------------
# Revision:    v1 
# Date:        2015-11-05
# Author:      sunny
# ------------------------------- 
 
# base value
# 要同步的源
#YUM_SITE='rsync://mirrors.kernel.org/centos/'
YUM_SITE='rsync://rsync.mirrors.ustc.edu.cn/centos/'
#YUM_SITE='rsync://cernet.mirrors.ustc.edu.cn/'
# 本地存放目录
#LOCAL_PATH='/var/ftp/centos/'
LOCAL_PATH='/export/ftp/centos/'
# 需要同步的版本，我只需要5和6版本的
#LOCAL_VER='5 5.* 6 6.*'
LOCAL_VER='5.* 6.* 7.*'
# 同步时要限制的带宽
#BW_limit=512000
# 记录本脚本进程号
LOCK_FILE='/var/log/yum_server.pid'
# 如用系统默认rsync工具为空即可。
# 如用自己安装的rsync工具直接填写完整路径
RSYNC_PATH=''
#清理如下内容，不然可能因为日期造成其他更新失败BU
#rm -rf /export/ftp/centos/6/os/x86_64/repodata/*

# check rsync tool
if [ -z $RSYNC_PATH ]; then
    RSYNC_PATH=`/usr/bin/whereis rsync|awk ' ''{print $2}'`
    if [ -z $RSYNC_PATH ]; then
        echo 'Not find rsync tool.'
        echo 'use comm: yum install -y rsync'
    fi
fi
 
# sync yum source
for VER in $LOCAL_VER;
do
    # Check whether there are local directory
    if [ ! -d "$LOCAL_PATH$VER" ] ; then
        echo "Create dir $LOCAL_PATH$VER"
        `/bin/mkdir -p $LOCAL_PATH$VER`
    fi

# sync yum source
     echo "Start sync $LOCAL_PATH$VER"
#    $RSYNC_PATH -avrtH --delete --bwlimit=$BW_limit --exclude "isos" $YUM_SITE$VER $LOCAL_PATH$VER
#    $RSYNC_PATH -avrtH --delete --bwlimit=$BW_limit --exclude "isos" $YUM_SITE$VER $LOCAL_PATH
     $RSYNC_PATH -vzrtopguH --ignore-errors --delete --force --exclude "isos" $YUM_SITE$VER $LOCAL_PATH
done
 
# clean lock file
`/bin/rm -rf $LOCK_FILE`

#rsync RPM-GPG-KEY and times.txt
     $RSYNC_PATH -vzrtopguH --ignore-errors --delete --force --exclude "isos" $YUM_SITE'RPM-GPG-KEY*' $LOCAL_PATH
     $RSYNC_PATH -vzrtopguH --ignore-errors --delete --force --exclude "isos" $YUM_SITE'timestamp.txt' $LOCAL_PATH
echo "sync end."
exit 1
