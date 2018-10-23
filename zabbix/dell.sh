#!/bin/bash
#cd /shell && wget 115.29.36.6/upload/8.07.14_MegaCLI.zip && unzip 8.07.14_MegaCLI.zip &&
cd Linux/
rpm -ivh MegaCli-8.07.14-1.noarch.rpm 
sed -i 's/Defaults    requiretty/#Defaults    requiretty/' /etc/sudoers
echo "zabbix ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/zabbix
echo "UserParameter=delldisk.status,sudo MegaCli -pdlist -aall |grep 'Firmware state'|awk -F: '{print $2}'" \
 >>/usr/local/zabbix/etc/zabbix_agentd.conf
sed -i 's/# EnableRemoteCommands=0/EnableRemoteCommands=1/' /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i 's/# AllowRoot=0/AllowRoot=1/' /usr/local/zabbix/etc/zabbix_agentd.conf
/etc/init.d/zabbix_agentd restart
sleep 1
name1=`arch`
if [ "$name1" = x86_64 ]; then
ln -sf /opt/MegaRAID/MegaCli/MegaCli64 /usr/bin/MegaCli
else
ln -sf /opt/MegaRAID/MegaCli/MegaCli /usr/bin/MegaCli
fi
exit 0
