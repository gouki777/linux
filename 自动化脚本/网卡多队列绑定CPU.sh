#!/bin/sh
# setting up irq affinity according to /proc/interrupts
# 2008-11-25 Robert Olsson
# 2009-02-19 updated by Jesse Brandeburg
#
# > Dave Miller:
# (To get consistent naming in /proc/interrups)
# I would suggest that people use something like:
#       char buf[IFNAMSIZ+6];
#
#       sprintf(buf, "%s-%s-%d",
#               netdev->name,
#               (RX_INTERRUPT ? "rx" : "tx"),
#               queue->index);
#
#  Assuming a device with two RX and TX queues.
#  This script will assign:
#
#       eth0-rx-0  CPU0
#       eth0-rx-1  CPU1
#       eth0-tx-0  CPU0
#       eth0-tx-1  CPU1
#
#  2013-11-27 yzc 修改:
#  1): 支持自动判断cpu核心。
#  2): 绑定cpu时候，优先绑定最大核心ID的cpu。
#  3): 按照顺序把所有网卡队列依次绑定到不同的cpu核心上。
#      比如有2张4队列的网卡，会把8个队列分别绑定到“7、6、5、4、3、2、1、0”核心上；
#      如果cpu核心数不足8个，比如有4个核心，会分别绑定在“3、2、1、0、3、2、1、0”cpu核心上。
#      一个版本是依次把各个网卡队列绑定在cpu核心上，比如有2张4队列网卡，都会分别绑定在“0、1、2、3”cpu上
#  4): centos6.1内核2.6.3以上应该是自动支持irq 内核3。0+默认支持
#
#  2014-06-10 yzc 修改：
#  1): 兼容redhat 5.x 系统上的多队列网卡表述方式，获取DIR和IRQ的方式做了调整。
#  

set_affinity()
{
    MASK=$((1<<$VEC))
    printf "[%s]\t%s VEC=%d mask=%X for /proc/irq/%d/smp_affinity RawData=%s\n" "`date "+%F %T"`" \
	$DIR \
	$VEC \
	$MASK \
	$IRQ \
	`cat /proc/irq/$IRQ/smp_affinity` >> $log;
    printf "%X" $MASK > /proc/irq/$IRQ/smp_affinity
    #echo $DEV mask=$MASK for /proc/irq/$IRQ/smp_affinity
    #echo $MASK > /proc/irq/$IRQ/smp_affinity
}

if [ "$1" = "" ] ; then
        echo "Description:"
        echo "    This script attempts to bind each queue of a multi-queue NIC"
        echo "    to the same numbered core, ie tx0|rx0 --> cpu0, tx1|rx1 --> cpu1"
        echo "usage:"
        echo "    $0 eth0 [eth1 eth2 eth3]"
fi


# check for irqbalance running
IRQBALANCE_ON=`ps ax | grep -v grep | grep -q irqbalance; echo $?`
if [ "$IRQBALANCE_ON" == "0" ] ; then
#        echo " WARNING: irqbalance is running and will"
#        echo "          likely override this script's affinitization."
#        echo "          Please stop the irqbalance service and/or execute"
#        echo "          'killall irqbalance'"
	killall -9 irqbalance
fi

#
# Set up the desired devices.
#
log="/var/log/lbcpu-nic.log";
CPU=$(( $((`cat /proc/cpuinfo |grep processor|wc -l`)) - 1 ));
VEC=$CPU;
for DEV in $*
do
  #GET NIC-Queue-Number
  for IRQ in `cat /proc/interrupts |grep ${DEV}| cut  -d:  -f1| sed "s/ //g"`;
  do
        DIR=`cat /proc/interrupts | egrep -i -e "^$IRQ|^\s+$IRQ"| awk '{print $NF}'`; # Get IRQ corresponding DIR name.
        if [ -n  "$IRQ" ]; then
		  set_affinity;
		  VEC=$(($VEC - 1));
		  if [ "$VEC" -lt 0 ]; then
		          VEC=$CPU;
		  fi
        else
		   echo -e "["`date "+%F %T"`"]\tget $DIR IRQ Failed." >> $log;
        fi
  done
done
echo -e "["`date "+%F %T"`"]\tSet down over." >> $log;