#!/bin/bash
SMTP_server='smtp.163.com'
username='zabbix@163.com'
password='zabbix1234'
from_email_address='zabbix@163.com'
to_email_address="$1"
message_subject_utf8="$2"
message_body_utf8="$3"

message_subject_gb2312=`iconv -t GB2312 -f UTF-8 << EOF
$message_subject_utf8
EOF`
[ $? -eq 0 ] && message_subject="$message_subject_gb2312" || message_subject="$message_subject_utf8"

message_body_gb2312=`iconv -t GB2312 -f UTF-8 << EOF
$message_body_utf8
EOF`
[ $? -eq 0 ] && message_body="$message_body_gb2312" || message_body="$message_body_utf8"

echo $to_email_address >> /usr/local/zabbix/alertscripts/log
echo $message_subject >> /usr/local/zabbix/alertscripts/log
echo $message_body >> /usr/local/zabbix/alertscripts/log

sendEmail='/usr/local/bin/sendEmail'
$sendEmail -s "$SMTP_server" -xu "$username" -xp "$password" -f "$from_email_address" -t "$to_email_address" -u "$message_subject" -m "$message_body" -o message-content-type=text -o message-charset=gb2312 -o tls=no
