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
  if [ -z `cat /xxxx|grep -o nginx` ]; then
    name1=(error.log access.log);
  else
    name1=access.log;
  fi
  log_name;
else
  echo "this system not find nginx_logs";
fi

exit 0;