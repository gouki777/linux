#!/bin/bash
#############################
#多线程 2016-08-02 sunyufeng#
#############################
export PATH=$PATH:/bin:/usr/bin:/usr/local/bin
exec 3>>/tmp/ws.log
echo "====================================================" >&3
echo -e "\n[`date +%Y/%m/%d\ %H:%M:%S`] Download wslog is Begin $RUNUSER PID:$$" >&3

tmpfile=$$.fifo  #创建管道名称
mkfifo $tmpfile       #创建管道
exec 4<>$tmpfile      #创建文件标示4，以读写方式操作管道$tmpfile
rm $tmpfile           #将创建的通道文件清楚
thred=4               #线程
###################################
seq='aaa.com bbb.com ccc.com'
logfile="/data/logs/wslog/"
username=name1
password=passwdWS1234
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
sleep 5;
 read -u4
sleep 5;
{
mkdir -p "$logfile""$I"
logurl=`/bin/bash /shell/wslog_query_client.sh "http://dx.wslog.chinanetcenter.com/logQuery/access" "$username" "$password" "$date7-0000" "$date7-2359" "$I" 2>/dev/null|awk '{print $12}'|cut -d '"' -f2|cut -d '"' -f1`
sleep 1;
##############循环10次获取值#########
 for ((i=1; i<=10; i++)); do
  if [ -z "$logurl" ] ; then
     sleep 5;
     logurl=`/bin/bash /shell/wslog_query_client.sh "http://dx.wslog.chinanetcenter.com/logQuery/access" "$username" "$password" "$date7-0000" "$date7-2359" "$I" 2>/dev/null|awk '{print $12}'|cut -d '"' -f2|cut -d '"' -f1`
    else
########跳出for循环######continue跳到下次循环#########
      break;
  fi
 done
echo -e "[`date +%Y/%m/%d\ %H:%M:%S`] Loading... $I" >&3
wget -c -q $logurl -O  "$logfile""$I"/"$I"."$date8".gz
#############
echo >&4
}&
done
wait
#############切日志脚本######
for I in $seq ; do
sleep 2;
 read -u4
{
biglog=`du -k "$logfile""$I"/"$I"."$date8".gz|awk '{print $1}'`
if [ $biglog -gt 1000000 ] ; then
    cd "$logfile""$I"/
    zcat "$logfile""$I"/"$I"."$date8".gz |split -b 18500m -d - "$logfile""$I"/"$I"."$date8"_;
    sleep 1
    gzip "$logfile""$I"/"$I"."$date8"_*;
    rm -rf "$logfile""$I"/"$I"."$date8".gz
 fi
echo >&4
}&
done
wait
exec 4>&-
#########################清理原日志和30天前的################################
#for I in $seq ; do
#rm -rf "$logfile""$I"/"$I"."$date8".gz
#sleep 1
#done
#delete 30 days ago log files
find /data/logs/wslog -mtime +30 -exec rm -rf {} \;
echo -e "\n[`date +%Y/%m/%d\ %H:%M:%S`] Download wslog is END $RUNUSER PID:$$" >&3
exit 0
