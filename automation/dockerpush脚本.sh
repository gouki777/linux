#!/bin/bash
export PATH=$PATH:/bin:/usr/bin:/usr/local/bin
rm -rf dockerpush.log
exec 3>>dockerpush.log
echo "====================================================" >&3
echo -e "\n[`date +%Y/%m/%d\ %H:%M:%S`] read PID:$$" >&3
###########################################
tmpfile=$$.fifo  #创建管道名称
mkfifo $tmpfile       #创建管道
exec 4<>$tmpfile      #创建文件标示4，以读写方式操作管道$tmpfile
rm $tmpfile           #将创建的通道文件清楚
thred=9    #指定并发数线程+1
#####变量###########
#获取dockerhub名下资源库
k8stree=`curl -s https://hub.docker.com/v2/repositories/mirrorgooglecontainers/?page_size=1000 | jq -r .results[].name|grep -E "kube|k8s"|grep -v -E "s390|arm|ppc64"`
#转化为数组
sum_name=($k8stree)
formk8s="mirrorgooglecontainers/"
tok8s="registry.cn-hangzhou.aliyuncs.com/criss/"
#为并发线程创建相应的个数占位
for (( i=1; i<=$thred;i++)); do
   echo "";
done >&4
for((i=0;i<"${#sum_name[@]}";i++));do
  for I in `curl -s https://hub.docker.com/v2/repositories/mirrorgooglecontainers/${sum_name[$i]}/tags/?page_size=1000 | jq -r '.results[].name'|grep -v -E "windows|beta"|grep -v ${sum_name[$i]}`; do
 read -u4
 {
    docker pull "$formk8s${sum_name[$i]}:$I";
    docker tag  $formk8s${sum_name[$i]}:$I $tok8s${sum_name[$i]}:$I
    docker push $tok8s${sum_name[$i]}:$I
    #docker rmi "$formk8s${sum_name[$i]}:$I";
    #docker rmi $tok8s${sum_name[$i]}:$I
    echo "[`date +%Y/%m/%d\ %H:%M:%S`] PID:$$ ${sum_name[$i]} $I" >&3;sleep 1;
echo >&4
}&
done
done
wait
exec 4>&-
    echo -e "\n[`date +%Y/%m/%d\ %H:%M:%S`] END PID:$$" >&3
exit 0;
