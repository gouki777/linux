#!/bin/bash
##################################
# Zabbix for phpfpmstatus
# 2016-03-25 make sunny
##################################
# Zabbix requested parameter
ZBX_REQ_DATA="$1"
 
# FPM defaults
URL="http://127.0.0.1:9999/phpfpmstatus"
WGET_BIN="/usr/bin/wget"
 
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)

ERROR_NO_ACCESS_FILE="-0.9900"
ERROR_NO_ACCESS="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_DATA="-0.9903" # either can not connect /        bad host / bad port
 
# save the FPM stats in a variable for future parsing
FPM_STATS=$($WGET_BIN -q $URL -O - 2> /dev/null)
 
# error during retrieve
if [ $? -ne 0 -o -z "$FPM_STATS" ]; then
  echo $ERROR_DATA
  exit 1
fi
 
#
# Extract data from FPM stats
#
RESULT=$(echo "$FPM_STATS" | sed -n -r "s/^$ZBX_REQ_DATA: +([0-9]+)/\1/p")
if [ $? -ne 0 -o -z "$RESULT" ]; then
    echo $ERROR_WRONG_PARAM
    exit 1
fi

echo $RESULT

exit 0
