#!/bin/bash
ARGS="-u memcache"
# -c connections
# 指定同时连接到memcached服务的最大数量。默认值为 1024
if [[ ! -z $connections ]]
then
  ARGS=$ARGS" -c "$connections
fi
# -t threads
# 指定处理传入请求时要使用的线程数
if [[ ! -z $threads ]]
then 
  ARGS=$ARGS" -t "$threads
fi
# -m memory
# 分配内存,默认为 64MB/单位MB
if [[ ! -z $memory ]]
then
  ARGS=$ARGS" -m "$memory
fi
# -l interface
# 指定一个网络接口. 默认是侦听所有可用地址 ( INADDR_ANY)。 默认可不填
if [[ ! -z $interface ]]
then
  ARGS=$ARGS" -l "$interface
fi
# -I mem
# 指定允许在memcached实例中存储对象的最大大小。大小支持单位后缀（k千字节， m兆字节）。例如，要将支持的最大对象大小增加到 32MB：
# shell> memcached -I 32m
if [[ ! -z $mem ]]
then
  ARGS=$ARGS" -I "$mem
fi
####################################
echo $ARGS
exec memcached $ARGS
