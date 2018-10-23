#/bin/bash
echo "zabbix ALL=NOPASSWD: /usr/sbin/hpacucli *" >>/etc/sudoers
sed -i 's/Defaults    requiretty/#Defaults    requiretty/' /etc/sudoers
echo "UserParameter=disk.status,sudo hpacucli ctrl slot=0 pd all show status|awk '{print $9}'" >>/usr/local/zabbix/etc/zabbix_agentd.conf
sed -i 's/# EnableRemoteCommands=0/EnableRemoteCommands=1/' /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i 's/# AllowRoot=0/AllowRoot=1/' /usr/local/zabbix/etc/zabbix_agentd.conf
/etc/init.d/zabbix_agentd restart
