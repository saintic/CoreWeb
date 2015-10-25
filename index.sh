#!/bin/bash
#Author:www.saintic.com
#Version: v1.0.0
#Note:转载请注明出处！

. ./functions ; clear
echo "脚本环境为CentOS/RHEL6.x 64Bit,目前仅支持单个服务,请输入所需服务代码!"
echo "CoreWeb项目是SDI针对LANMP及常用NoSQL所编写的Shell脚本程序，版本1.0.0!"
echo "#####################################################################"
echo "项目分支   代码号   请在交互式输入中输入代码号(数字)，以进行相应部署!"
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo "Nginx        1"
echo "Httpd        2"
echo "MySQL        3"
echo "MemCached    4"
echo "MongoDB      5"
echo "PHP          6"
echo "Redis        7"
echo "######################################################################"
read -p "请输入对应代码号部署单服务,如需多个服务请多次执行此脚本：" CODE_NUM
case $CODE_NUM in
	1)
		echo "Nginx"
		SH_CODE_NUM_1
		;;
	2)
		echo "Httpd"
		SH_CODE_NUM_2
		;;
	3)
		echo "MySQL"
		SH_CODE_NUM_3
		;;
	4)
		echo "MemCached"
		SH_CODE_NUM_4
		;;
	5)
		echo "MongoDB"
		SH_CODE_NUM_5
		;;
	6)
		echo "PHP"
		SH_CODE_NUM_6
		;;
	7)
		echo "Redis"
		SH_CODE_NUM_7
		;;
	*)
		echo "不匹配代码号,脚本不执行"
		exit 1
		;;
esac