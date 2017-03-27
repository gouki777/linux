#!/bin/bash
export PATH=$PATH:/bin:/usr/bin:/usr/local/bin
###############################
function log_name() {
for((i=0;i<"${#name1[@]}";i++));do
nowtime=$(date "+%Y%m%d%H%M")
   mkdir -p ./backlog;
   ionice -c2 -n7 cp -rf ${name1[$i]} ${name1[$i]}-${nowtime};
   ionice -c2 -n7 echo >${name1[$i]};
   sleep 2;
   ionice -c2 -n7 tar zcvf ${name1[$i]}-${nowtime}.gz ${name1[$i]}-${nowtime};
   ionice -c2 -n7 rm -rf ${name1[$i]}-${nowtime};
   ionice -c2 -n7 mv -f *.gz ./backlog;
done
save_days=5 #保存日志时间
find ./backlog -mtime +$save_days -exec rm -rf {} \;
}
##########切nginx日志判断#######
if [ -e /usr/local/nginx/logs ]; then
  cd /usr/local/nginx/logs
    if [ -z `cat /home/fivemin/config/fiveconf.ini|grep INPATH|grep -o nginx` ]; then
      name1=(error.log access.log);
    else
      name1=(error.log);
    fi
  log_name;
else
  echo "this system not find nginx_logs";
fi
########切vcache日志判断#########
if [ -e /usr/local/squid/var/logs ]; then
  cd /usr/local/squid/var/logs
    if [ -z `cat /home/fivemin/config/fiveconf.ini|grep INPATH|grep -o squid` ]; then
      name1=(diags.log manager.log error.log merge_url.log access.log traffic.out);
      else
      name1=(diags.log manager.log error.log merge_url.log traffic.out);
    fi
  log_name;
  else
  echo "this system not find vcache_logs";
fi
########切推送日志判断###########
if [ -e /usr/local/squid/var/log/trafficserver/dir_purge ]; then
  cd /usr/local/squid/var/log/trafficserver/dir_purge
  name1=(purge.log run.log urls.log)
  log_name;
  else
  echo "this system not find purge_log";
fi
#######core日志清理#############
ulimit -c 15000000
cd /usr/local/squid/
echo "1" >/proc/sys/kernel/core_uses_pid
find /usr/local/squid/ -name "core*" -mtime +1 -exec rm -rf {} \;
sleep 1;
for i in `find ./ -name 'core*'  -mtime -1`; do
nowtime1=$(date "+%Y%m%d")
mkdir -p /tmp/core/$nowtime1
file=$(ls -l $i|awk '{printf $6$7"_"$8"\t"$9}')
gdb /usr/local/squid/bin/traffic_server $i <<EOF >/tmp/core/$nowtime1/$i 2>/dev/null
bt
EOF
sleep 1;
rm -rf /usr/local/squid/$i;
done
find /tmp/core/ -mtime +5 -exec rm -rf {} \;
####################################################
exit 0