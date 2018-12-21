#!/bin/sh

TMP_FILE="/tmp/wslog_query_client.log"
#Usage
Usage() {
	echo "wslog_query_client.sh [query_url] [user] [passwd] [start_time] [end_time] [channels]"
	return 0
}
#check input parameters
if [ $# -eq 1 ]; then
	if [ "$1" = "-h" ]; then
		Usage
		exit 0
	else
		Usage
		exit -1
	fi
elif [ $# -ne 6 ]; then
	Usage
	exit -1
fi
#params set
url=$1
user=$2
passwd=`echo $3 | sed 's/&/%26/g' `
start_time=$4
end_time=$5
channels=$6

#access logQuery access API
curl -D $TMP_FILE $1
cat $TMP_FILE | grep "HTTP/" | grep "302" > /dev/null
if [ $? -ne 0 ]; then
	exit -2
fi
#redirect to verify url with user and passwd
TMP_URL=`cat $TMP_FILE | grep "Location: "|sed 's/\r//' | awk '{print $2}' | sed 's/http:/https:/'`
TMP_URL="${TMP_URL}?u=$user&p=$passwd&channel=$channels"
curl -k -D $TMP_FILE $TMP_URL
cat $TMP_FILE | grep "HTTP/" | grep "302" > /dev/null
if [ $? -ne 0 ]; then
	exit -3
fi
#redirect to query url with start_time, end_time and channels
TMP_URL=`cat $TMP_FILE | grep "Location: "|sed 's/\r//' | awk '{print $2}'`
TMP_URL="${TMP_URL}&start_time=$start_time&end_time=$end_time&channels=$channels"
curl -D $TMP_FILE $TMP_URL
#check query result
cat $TMP_FILE | grep "HTTP/" | grep "200" > /dev/null
if [ $? -ne 0 ]; then
	exit -4
fi
exit 0
