#!/bin/bash
if [ $# != 3 ] ; then 
echo "Usage: `basename $0` -ip [ip] [24/16/8]" >&2
exit 1
fi
case $3 in
24)
	for (( a=0; a<=255;a++)); do
	echo $2.$a
done
;;
16)
	for (( a=0; a<=255;a++)); do
         if [ $a -lt 256 ] ; then
		 for (( b=1; b<=255;b++)); do
		 echo "$2"."$a"."$b"
	 done
	 fi
	 done
;;
8)
	for ((a=0; a<=255;a++)) ; do
		if [ $a -lt 256 ] ; then
			for (( b=0; b<=255;b++)) do
				if [ $b -lt 256 ] ; then
					for (( c=1; c<=255;c++)) do
						echo "$2"."$a"."$b"."$c"
					done
				fi
			done
		fi
	done
;;
*)
echo "Usage: `basename $0` -ip [ip] [24/16/8]"
;;
esac
exit 0
