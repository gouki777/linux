#!/bin/bash
#set the path to nginx log files
log_files_path="/usr/local/nginx/logs/" #日志路径
log_files_dir=${log_files_path}$(date -d "yesterday" +"%Y")$(date -d "yesterday" +"%m")
#set nginx log files you want to cut
log_files_name=(abc.com efg.com) #多log+空格，注这里日志不写.log
#set the path to nginx.
nginx_sbin="/usr/local/nginx/sbin/nginx"
#Set how long you want to save
save_days=30 #保存日志时间
############################################
#Please do not modify the following script #
############################################
mkdir -p $log_files_dir
log_files_num=${#log_files_name[@]}
#cut nginx log files
for((i=0;i<$log_files_num;i++));do
mv ${log_files_path}${log_files_name[i]}.log ${log_files_dir}/${log_files_name[i]}_$(date -d "yesterday" +"%Y%m%d").log
done
#delete 30 days ago nginx log files
find $log_files_path -mtime +$save_days -exec rm -rf {} \;
$nginx_sbin -s reload
