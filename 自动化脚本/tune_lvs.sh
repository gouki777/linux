#!/bin/bash
install_tuned() {
	############tune list############
	#	 server-powersave
	#	 latency-performance
	#	 laptop-battery-powersave
	#	 laptop-ac-powersave
	#	 enterprise-storage
	#	 throughput-performance
	#	 virtual-host
	#	 virtual-guest
	#	 default
	#	 desktop-powersave
	#	 spindown-disk
	################################
   yum install tuned -y
   tuned-adm profile latency-performance
}
sysctl_tune() {
	echo 50 >/proc/sys/net/core/busy_poll                                          
	echo 50 >/proc/sys/net/core/busy_read
	echo 2048 > /proc/sys/net/ipv4/tcp_dma_copybreak
	echo 600 >/proc/sys/net/core/netdev_budget
	echo 600000 >/proc/sys/net/core/netdev_max_backlog
	echo 409600 >/proc/sys/net/ipv4/tcp_max_syn_backlog
	echo "9174960" > /proc/sys/net/core/rmem_default
	echo "17476000" > /proc/sys/net/core/rmem_max
	echo "9174960" > /proc/sys/net/core/wmem_default
	echo "17476000" > /proc/sys/net/core/wmem_max
	echo "3088629      4118172 6177258" > /proc/sys/net/ipv4/tcp_mem
	echo "92160	6000000	17476000" > /proc/sys/net/ipv4/tcp_rmem
	echo "40960	409600	4096000" > /proc/sys/net/ipv4/tcp_wmem
	echo "600" > /proc/sys/net/core/dev_weight
	echo "0" > /proc/sys/net/core/netdev_tstamp_prequeue
}

sysctl_tune_second() {
    echo 65535 > /proc/sys/net/core/somaxconn
    echo 20480 > /proc/sys/net/core/optmem_max
    echo 3 > /proc/sys/net/ipv4/tcp_retries1
    echo 5 > /proc/sys/net/ipv4/tcp_retries2
    echo 10 > /proc/sys/net/ipv4/tcp_fin_timeout
    echo 0 > /proc/sys/net/ipv4/tcp_tw_reuse
    echo 0 > /proc/sys/net/ipv4/tcp_tw_recycle
    echo 1440000 > /proc/sys/net/ipv4/tcp_max_tw_bucket
}

sysctl_tune_fs() {
    echo 1048576 > /proc/sys/fs/file-max
    echo 1048576 > /proc/sys/fs/nr_open    
}

sysctl_tune_net_core() {
    #napi
    echo 50 >/proc/sys/net/core/busy_poll                                          
    echo 50 >/proc/sys/net/core/busy_read
    echo 600 >/proc/sys/net/core/netdev_budget
    echo "600" > /proc/sys/net/core/dev_weight
    echo "0" > /proc/sys/net/core/netdev_tstamp_prequeue
    echo 409600 > /proc/sys/net/core/netdev_max_backlog
    #memory
    echo 921600 > /proc/sys/net/core/optmem_max
    echo "9174960" > /proc/sys/net/core/rmem_default
    echo "17476000" > /proc/sys/net/core/rmem_max
    echo "9174960" > /proc/sys/net/core/wmem_default
    echo "17476000" > /proc/sys/net/core/wmem_max
    #conn
    echo 65535 > /proc/sys/net/core/somaxconn

}
sysctl_tune_net_ipv4() {
    #packet dma
    echo 2048 > /proc/sys/net/ipv4/tcp_dma_copybreak
    #
    echo 3 > /proc/sys/net/ipv4/tcp_synack_retries
    echo 3 > /proc/sys/net/ipv4/tcp_retries1
    echo 5 > /proc/sys/net/ipv4/tcp_retries2
    echo 409600 >/proc/sys/net/ipv4/tcp_max_syn_backlog
    #tcp memory
    echo "3088629  4118172  6177258" > /proc/sys/net/ipv4/tcp_mem
    echo "92160	6000000	17476000" > /proc/sys/net/ipv4/tcp_rmem
    echo "40960	409600	4096000" > /proc/sys/net/ipv4/tcp_wmem
    #  tcp goodbye
    echo 10 > /proc/sys/net/ipv4/tcp_fin_timeout
    echo 0 > /proc/sys/net/ipv4/tcp_tw_reuse
    echo 0 > /proc/sys/net/ipv4/tcp_tw_recycle
    echo 1440000 > /proc/sys/net/ipv4/tcp_max_tw_bucket
    #
    echo 0 > /proc/sys/net/ipv4/tcp_slow_start_after_idle
    echo 3 > /proc/sys/net/ipv4/tcp_fastopen
#    echo 1 > /proc/sys/net/ipv4/tcp_no_metrics_save
    
}

sysctl_tune_vm() {
    echo 10 > /proc/sys/vm/swappiness
    echo 1  > /proc/sys/vm/dirty_background_ratio
    echo 15 > /proc/sys/vm/dirty_ratio
#    echo 3000 > /proc/sys/vm/dirty_expire_centisecs
#    echo 500 > /proc/sys/vm/dirty_writeback_centisecs
}

nic_tune() {
	ethtool -K $1 gro off
	ethtool -K $1 tso off
	ethtool -G $1 rx "$(ethtool  -g $1 | grep -m 1 -E 'RX:'  | awk '{print $2}')"
	ethtool -G $1 tx "$(ethtool  -g $1 | grep -m 1 -E 'TX:'  | awk '{print $2}')"
	modprobe fq_codel
    tc qdisc add dev $1 root fq_codel 2>/dev/null
}
stop_service() {
	service irqbalance stop
	chkconfig cpuspeed off
	service cpuspeed stop
	chkconfig irqbalance off
	chkconfig cpuspeed off
}
set_affinity()
{
	if [ $VEC -ge 32 ]
	then
		MASK_FILL=""
		MASK_ZERO="00000000"
		let "IDX = $VEC / 32"
		for ((i=1; i<=$IDX;i++))
		do
			MASK_FILL="${MASK_FILL},${MASK_ZERO}"
		done

		let "VEC -= 32 * $IDX"
		MASK_TMP=$((1<<$VEC))
		MASK=$(printf "%X%s" $MASK_TMP $MASK_FILL)
	else
		MASK_TMP=$((1<<$VEC))
		MASK=$(printf "%X" $MASK_TMP)
	fi

	printf "%s" $MASK > /proc/irq/$IRQ/smp_affinity
	printf "%s %d %s -> /proc/irq/$IRQ/smp_affinity\n" $DEV $VEC $MASK ; 
}
network_irq(){

	if [ "$1" = "" ] ; then
	       ARG="$(ifconfig  | grep '^[[:alpha:]]' | awk '$1!~/^(lo|bond|br|docker|virbr)/{print $1}')"
	else      	
		ARG="$*"
	fi


	IRQBALANCE_ON=`ps ax | grep -v grep | grep -q irqbalance; echo $?`
	if [ "$IRQBALANCE_ON" == "0" ] ; then
		killall -9 irqbalance
	fi
	#log="/var/log/lbnic.log";
	#:>$log
	CPU=$(( $((`cat /proc/cpuinfo |grep processor|wc -l`)) - 1 ));
	VEC=$CPU;
	for DEV in $ARG
	do
	  for IRQ in `cat /proc/interrupts |grep ${DEV}| cut  -d:  -f1| sed "s/ //g"`;
	  do
		DIR=`cat /proc/interrupts | egrep -i -e "^$IRQ|^\s+$IRQ"| awk '{print $NF}'`; 
		if [ -n  "$IRQ" ]; then
			  set_affinity;
			  VEC=$(($VEC - 1));
			  if [ "$VEC" -lt 0 ]; then
				  VEC=$CPU;
			  fi
		else
			   echo -e "["`date "+%F %T"`"]\tget $DIR IRQ Failed.";
		fi
	  done

	done
	echo -e "["`date "+%F %T"`"]\tSet down over." ;
}
##################main###############
kernel_version="$(uname -r)"
install_tuned

for nic in $(ifconfig  | grep '^[[:alpha:]]' | awk '$1!~/^(lo|bond|br|docker|^virbr)/{print $1}'  | grep -v ':');
do 
	echo "1.${nic} network_irq"
	network_irq ${nic} 2>/dev/null
	echo "2.${nic} nic_tune"
	nic_tune ${nic} 2>/dev/null

done

echo "3.stop_unnecessary_service"
stop_service 2> /dev/null

echo "4.sysctl_tune_net_core"
sysctl_tune_net_core 2> /dev/null

echo "5.sysctl_tune_net_ipv4"
sysctl_tune_net_ipv4 2> /dev/null

echo "6.sysctl_tune_fs"
sysctl_tune_fs 2>/dev/null

echo "7.sysctl_tune_vm"
sysctl_tune_vm 2>/dev/null