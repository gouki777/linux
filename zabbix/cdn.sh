#!/bin/bash
####################
# 160305 sunny make
####################
if [ $# != 2 ] ; then ®é¢˜
echo "Usage: `basename $0` -p [cdnid|cdntotal|cdnweb|cdnmedia|help]" >&2
exit 1
fi
#################
date1=`(date "+%Y%m%d%H%M")`
date3=5
date2=`date "+%Y%m%d%H%M" -d "-$date3 minute"`
date4=$((date2/5*5))           #quzhengshud
##############################
name2=$2
case $name2 in
cdntotal)
 /usr/bin/curl "https://api.chinacache.com/reportdata/bandwidth/allChannels?username=chinadaily&pass=C7h1t808&starttime=$date4&endtime=$date4&withtime=true&layerdetail=false&format=json" 2>/dev/null|awk '/avg/{print $2}'|awk -F"," 'NR==4{print $1}'
;;
cdnweb)
 /usr/bin/curl "https://api.chinacache.com/reportdata/bandwidth/allChannels?username=chinadaily&pass=C7h1t808&starttime=$date4&endtime=$date4&withtime=true&layerdetail=false&format=json" 2>/dev/null|awk '/avg/{print $2}'|awk -F"," 'NR==2{print $1}'
;;
cdnmedia)
 /usr/bin/curl "https://api.chinacache.com/reportdata/bandwidth/allChannels?username=chinadaily&pass=C7h1t808&starttime=$date4&endtime=$date4&withtime=true&layerdetail=false&format=json" 2>/dev/null|awk '/avg/{print $2}'|awk -F"," 'NR==3{print $1}'
;;
[0-9][0-9][0-9]*)
 /usr/bin/curl "https://api.chinacache.com/reportdata/monitor/queryByChannels?type=bandiwidth&withtime=false&layerdetail=false&username=chinadaily&pass=C7h1t808&channelId="$2"&starttime="$date4"&endtime="$date4"&format=json" 2>/dev/null|awk -F'"' NR==8'{print $4}'
;;
*)
echo "Usage: `basename $0` -p [cdnid|cdntotal|cdnweb|cdnmedia|help]"
;;
esac
exit 0
