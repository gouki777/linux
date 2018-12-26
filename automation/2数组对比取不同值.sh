#!/bin/bash
arry_list1=(1 2 3 4 5 6 7 8 9)
arry_list2=(3 5 8)
declare -a diff_list  #声明数组
t=0
flag=0
echo arry_list1=${arry_list1[@]}
echo arry_list2=${arry_list2[@]}

for list1_num in "${arry_list1[@]}"
do
    echo list1_num is ${list1_num}
    for list2_num in "${arry_list2[@]}"
    do
        echo list2_num is ${list2_num}
        if [[ "${list1_num}" == "${list2_num}" ]]; then
            flag=1   #定义整形变量
            break
        fi
    done
    if [[ $flag -eq 0 ]]; then  #对比2数组如有不同的加入diff_list新数组里最后输出diff数组
        diff_list[t]=$list1_num
        t=$((t+1))
    else
        flag=0
    fi
done
echo diff_list=${diff_list[@]}
