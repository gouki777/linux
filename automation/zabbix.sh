#!/bin/bash
groupadd -g 777 zabbix
useradd -u 777 -g zabbix zabbix
yum install make gcc net-snmp-devel -y
sleep 2
wget http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/2.2.4/zabbix-2.2.4.tar.gz/download -O zabbix-2.2.4.tar.gz
sleep 1
tar zxvf zabbix-2.2.4.tar.gz -C /usr/local/
sleep 1
mkdir -p /usr/local/zabbix/log/
cd /usr/local/zabbix-2.2.4
./configure --prefix=/usr/local/zabbix --enable-agent --with-net-snmp
make && make install
echo "zabbix_agent install is OK,Give me some time.debug the content..."
sleep 2
zabbix_account() {
        clear
        read -p "Please enter zabbix server ip: " user1
        read -p "Please enter host ip: " user2
        echo ""
        echo ""
        echo "zabbix server ip is: $user1"
        echo "my ip is: $user2"
}
zabbix_account
while true;do
        read -p "Do you want proceed? (y/N): " Keypress
        case "$Keypress" in
        y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
        break
        ;;
        *)
        zabbix_account
        esac
done
sleep 2
cp -r misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
chmod 755 /etc/init.d/zabbix_agentd
cp /usr/local/zabbix/etc/zabbix_agentd.conf /usr/local/zabbix/etc/zabbix_agentd.conf.bak
sed -i "s/^Server=127.0.0.1/Server=${user1}/" /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i "s/^ServerActive=127.0.0.1/ServerActive=${user1}/" /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i 's/# UnsafeUserParameters=0/UnsafeUserParameters=1/g' /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i 's#LogFile=.*$#LogFile=/usr/local/zabbix/log/zabbix_agentd.log#g' /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i "s/Hostname=Zabbix server/Hostname=$user2/g" /usr/local/zabbix/etc/zabbix_agentd.conf
chown zabbix:zabbix /usr/local/zabbix -R
echo "zabbix-agent    10050/tcp               # Zabbix Agent" >>/etc/services
echo "zabbix-agent    10050/udp               # Zabbix Agent" >>/etc/services
echo "zabbix-agent    10051/tcp               # Zabbix Trapper" >>/etc/services
echo "zabbix-agent    10051/udp               # Zabbix TrApper" >>/etc/services
sed -i 's#BASEDIR=/usr/local#BASEDIR=/usr/local/zabbix#g' /etc/init.d/zabbix_agentd
chkconfig zabbix_agentd on
sleep 1
/etc/init.d/zabbix_agentd restart
echo "zabbix_agent install is OK."
echo "test one"
ps -aux|grep zabbix
