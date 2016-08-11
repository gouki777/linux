#!/bin/bash
sum_name=(1 2 3 4 5 6)            #数组
 echo ${sum_name[*]};             #遍历数组里所有元素
 echo ${sum_name[@]};             #所有元素*和@一个意思
 echo ${#sum_name[*]};            #遍历数组个数
 echo ${sum_name[3]};             #遍历出数组中第3个元素
for((i=0;i<"${#sum_name[@]}";i++));do 
 echo ${sum_name[$i]};            #遍历数组中逐一列出数组1-6的元素 for
done