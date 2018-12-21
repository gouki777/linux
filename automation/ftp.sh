#!/bin/bash
yum install vsftpd db4 db4-utils -y
sleep 3
chkconfig vsftpd on
sleep 1
############vi vsftpd.conf########
sed -i 's/anonymous_enable=YES/anonymous_enable=NO/' /etc/vsftpd/vsftpd.conf
sed -i 's/#chroot_list_enable=YES/chroot_list_enable=YES/' /etc/vsftpd/vsftpd.conf
sed -i 's/#idle_session_timeout=600/idle_session_timeout=900/' /etc/vsftpd/vsftpd.conf
sed -i 's@#chroot_list_file=/etc/vsftpd/chroot_list@chroot_list_file=/etc/vsftpd/vsftpd.chroot_list@' /etc/vsftpd/vsftpd.conf
sed -i 's/#ascii/ascii/' /etc/vsftpd/vsftpd.conf
sed -i 's@xferlog_std_format=YES@xferlog_std_format=NO@' /etc/vsftpd/vsftpd.conf
sed -i 's@#xferlog_file=/var/log/xferlog@xferlog_file=/var/log/vsftpd.log@' /etc/vsftpd/vsftpd.conf
echo "max_per_ip=10" >>/etc/vsftpd/vsftpd.conf
echo "connect_timeout=600" >>/etc/vsftpd/vsftpd.conf
echo "use_localtime=YES" >>/etc/vsftpd/vsftpd.conf
echo "guest_enable=YES" >>/etc/vsftpd/vsftpd.conf
echo "guest_username=ftp" >>/etc/vsftpd/vsftpd.conf
echo "user_config_dir=/etc/vsftpd/vconf" >>/etc/vsftpd/vsftpd.conf
echo "pasv_enable=YES" >>/etc/vsftpd/vsftpd.conf
echo "pasv_min_port=40000" >>/etc/vsftpd/vsftpd.conf
echo "pasv_max_port=40080" >>/etc/vsftpd/vsftpd.conf
echo "pasv_promiscuous=YES" >>/etc/vsftpd/vsftpd.conf
echo "vsftp.conf is OK..."
sleep 3
ftp_account() {
        clear
        read -p "Please enter FTP user: " ftpuser
        read -p "Please enter FTP Directory: " ftpdir
        echo ""
        echo ""
        echo "FTP Account is: $ftpuser"
        echo "FTP Directory is: $ftpdir"
}
ftp_account
while true;do
        read -p "Do you want proceed? (y/N): " Keypress
        case "$Keypress" in
        y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
        break
        ;;
        *)
        ftp_account
        esac
done

ftppwd=$(echo "CD`cat /dev/urandom | head -1 | md5sum | head -c 10`")
echo "$ftpuser" >> /etc/vsftpd/vuser_passwd.txt
echo "$ftppwd" >> /etc/vsftpd/vuser_passwd.txt
db_load -T -t hash -f /etc/vsftpd/vuser_passwd.txt /etc/vsftpd/vuser_passwd.db
chmod 600 /etc/vsftpd/vuser_passwd.db
sleep 3
touch /etc/vsftpd/vsftpd.chroot_list
echo "$ftpuser" >/etc/vsftpd/vsftpd.chroot_list
sleep 1
vconf=/etc/vsftpd/vconf
user_config=$vconf/$ftpuser
sleep 1
mkdir -p $vconf
mkdir -p $ftpdir
sleep 1
echo "local_root=$ftpdir" >$user_config
echo "download_enable=yes" >>$user_config
echo "write_enable=YES" >>$user_config
echo "anon_umask=022" >>$user_config
echo "anon_world_readable_only=NO" >>$user_config
echo "anon_upload_enable=YES" >>$user_config
echo "anon_mkdir_write_enable=YES" >>$user_config
echo "anon_other_write_enable=YES" >>$user_config
echo "local_max_rate=5120000" >>$user_config
echo "use_localtime=YES" >>$user_config
sleep 1
mv /etc/pam.d/vsftpd /etc/pam.d/vsftpd.bak
touch /etc/pam.d/vsftpd 
echo "auth required pam_userdb.so db=/etc/vsftpd/vuser_passwd" >>/etc/pam.d/vsftpd
echo "account required pam_userdb.so db=/etc/vsftpd/vuser_passwd" >>/etc/pam.d/vsftpd
sleep 1
chmod 777 $ftpdir -R
service vsftpd restart
sleep 1
echo "==============================================================================="
echo "VSFTPD install completed"
echo "FTP User: $ftpuser"
echo "FTP Password: $ftppwd"
echo "FTP DIR: $ftpdir"        
echo "==============================================================================="
exit 0
