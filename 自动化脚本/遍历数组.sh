#!/bin/bash
sum_name=(1 2 3 4 5 6)            #����
 echo ${sum_name[*]};             #��������������Ԫ��
 echo ${sum_name[@]};             #����Ԫ��*��@һ����˼
 echo ${#sum_name[*]};            #�����������
 echo ${sum_name[3]};             #�����������е�3��Ԫ��
for((i=0;i<"${#sum_name[@]}";i++));do 
 echo ${sum_name[$i]};            #������������һ�г�����1-6��Ԫ�� for
done