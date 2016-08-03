#!/bin/bash
#############################
#多线程 2016-08-02 sunny    #
#############################
export PATH=$PATH:/bin:/usr/bin:/usr/local/bin
exec 3>>/tmp/ws.log
echo "====================================================" >&3
echo -e "\n[`date +%Y/%m/%d\ %H:%M:%S`] Download wslog is Begin $RUNUSER PID:$$" >&3

tmpfile=$$.fifo  #创建管道名称
mkfifo $tmpfile       #创建管道
exec 4<>$tmpfile      #创建文件标示4，以读写方式操作管道$tmpfile
rm $tmpfile           #将创建的通道文件清楚
thred=3               #线程
###################################
seq='aaa.com bbb.com ccc.com'
logfile="/data/logs/wslog/"
username=name1
password=passwd123456
date8=`date "+%Y%m%d" -d "-1 day"`
date2=`date "+%Y" -d "-1 day"`
date3=`date "+%m" -d "-1 day"`
date4=`date "+%d" -d "-1 day"`
date5=`printf "%02d\n" $date3`
date6=`printf "%02d\n" $date4`
date7="$date2"-"$date3"-"$date4"
#####为并发线程创建相应的个数占位##########
for (( i=1; i<=$thred;i++)); do
   echo "";
done >&4
###########sleep15 WSapi获取间隔问题频繁容易获取不到url############
for I in $seq ; do
sleep 15;
 read -u4
sleep 15;
{
mkdir -p "$logfile""$I"
logurl=`/bin/bash /shell/wslog_query_client.sh "http://dx.wslog.chinanetcenter.com/logQuery/access" "$username" "$password" "$date7-0000" "$date7-2359" "$I" 2>/dev/null|awk '{print $12}'|cut -d '"' -f2|cut -d '"' -f1`
sleep 15;
wget -c -q $logurl -O  "$logfile""$I"/"$I"."$date8".gz
echo >&4
}&
done
wait
###################大于1G切分日志###########
for I in $seq ; do
sleep 2;
 read -u4
{
biglog=`du -k "$logfile""$I"/"$I"."$date8".gz|awk '{print $1}'`
if [ $biglog -gt 1000000 ] ; then
    cd "$logfile""$I"/
    zcat "$logfile""$I"/"$I"."$date8".gz |split -b 19000m -d - "$logfile""$I"/"$I"."$date8"_;
    sleep 1
    gzip "$logfile""$I"/"$I"."$date8"_*;
 fi
echo >&4
}&
done
wait
exec 4>&-
############切分后,删除总包，重新打包gz########################
for I in $seq ; do
rm -rf "$logfile""$I"/"$I"."$date8".gz
sleep 1
done
#delete 30 days ago log files
find "$logfile" -mtime +$save_days -exec rm -rf {} \;
echo -e "\n[`date +%Y/%m/%d\ %H:%M:%S`] Download wslog is END $RUNUSER PID:$$" >&3
exit 0