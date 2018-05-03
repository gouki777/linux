#!/bin/bash
#依赖环境
export PATH=$PATH:/bin:/usr/bin:/usr/local/bin
yum -y install libnl* libpopt* popt-static make gcc --skip-broken
#ipvs加载到内核
name1=$(lsmod|grep ip_vs)
if [ -z "$name1" ] ; then
  modprobe ip_vs
fi
#卸载yum安装包ipvsadm
rpm -e ipvsadm
#编译安装ipvsadm
wget http://www.linuxvirtualserver.org/software/kernel-2.6/ipvsadm-1.26.tar.gz -O /usr/local/src/ipvsadm-1.26.tar.gz
tar zxvf /usr/local/src/ipvsadm-1.26.tar.gz -C /usr/local/src/
cd /usr/local/src/ipvsadm-1.26
make && make install
#安装keepalived#
kernel=$(ls /usr/src/kernels|grep "2.6.")
if [ -z "$kernel" ] ; then
  echo "This system is not kernels-2.6 install Failed"
  exit 0;   
fi
wget http://122.11.50.161:1992/files/keepalived-1.2.10.tar.gz -O /usr/local/src/keepalived-1.2.10.tar.gz
tar zxvf /usr/local/src/keepalived-1.2.10.tar.gz -C /usr/local/src/
cd /usr/local/src/keepalived-1.2.10
./configure --prefix=/usr/local/keepalived --with-kernel-dir=/usr/src/kernels/$kernel/ --enable-snmp
make && make install
#copy必要文件
rm -rf /etc/rc.d/init.d/keepalived
cp -rf keepalived/etc/init.d/keepalived.init.custom /etc/rc.d/init.d/keepalived
cp -rf keepalived/etc/init.d/keepalived.sysconfig.custom /etc/sysconfig/keepalived
echo "options ip_vs conn_tab_bits=20" > /etc/modprobe.d/lvs.conf
chkconfig --add keepalived
chkconfig keepalived on
#启动服务
service keepalived start
#查看相关信息
ipvsadm -Ln
exit 0
