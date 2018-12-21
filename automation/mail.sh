#!/bin/bash
export LANG="zh_CN.gb2312"
###############################
echo '<!DOCTYPE html><html><body><p><pre>' > /ptmail.log
cat /ptmail.out >>/ptmail.log
echo '<pre/><p/><body/><html/>' >> /ptmail.log
###################################################################
sed -i '1i\<!DOCTYPE html><html><body><p><pre>' /vctop_timeout
echo '<pre/><p/><body/><html/>' >> /vctop_timeout
/usr/local/bin/sendEmail -s smtp.dnion.com -xu "ymbj" -xp "Pass...." -f "fjx@qq.com" -t "112@qq.com,456@sohu.com" -u "ATS_core" -o message-content-type=html -o message-charset=zh_CN.gb2312 -o tls=no -m </ptmail.log
/usr/local/bin/sendEmail -s smtp.dnion.com -xu "ymbj" -xp "Pass...." -f "fjx@qq.com" -t "112@qq.com,456@sohu.com" -u "ATS_top_timeout-18000" -o message-content-type=html -o message-charset=zh_CN.gb2312 -o tls=no -m </vctop_timeout
exit 0