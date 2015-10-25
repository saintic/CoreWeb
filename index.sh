#!/bin/bash
#Author:www.saintic.com
#Version: v2.0.0
#Note:转载请注明出处！

. ./functions ; clear
[ -d $PACKAGE_PATH ] || mkdir -p $PACKAGE_PATH
[ -x ${ROOT}/index.sh ] || chmod +x index.sh
echo -e "\033[31m脚本环境为CentOS/RHEL，请先阅读README.md，请根据需求输入所需服务代码！\033[0m"
echo -e "\033[31mCoreWeb项目是SDI针对LANMP及常用NoSQL所编写的Shell脚本程序，版本2.0.0！\033[0m"
echo -e "\033[35m##################################################################### \033[0m"
echo -e "\033[32m项目分支   代码号   请在交互式输入中输入代码号(数字)，以进行相应部署！\033[0m"
echo -e "\033[35m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ \033[0m"
echo -e "\033[32mNginx--------1\033[0m"
echo -e "\033[32mHttpd--------2\033[0m"
echo -e "\033[32mMySQL--------3\033[0m"
echo -e "\033[32mPHP----------4\033[0m"
echo -e "\033[32mMongoDB------5\033[0m"
echo -e "\033[32mMemCached----6\033[0m"
echo -e "\033[32mRedis--------7\033[0m"
echo -e "\033[35m##################################################################### \033[0m"
echo -e -n "\033[34m请输入对应代码号部署服务: \033[0m"
read -p "" CODE_NUM

if [ "$CODE_NUM" != "" ]; then
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
			echo "PHP"
			SH_CODE_NUM_4
			;;
		5)
			echo "MongoDB"
			SH_CODE_NUM_5
			;;
		6)
			echo "MemCached"
			SH_CODE_NUM_6
			;;
		7)
			echo "Redis"
			SH_CODE_NUM_7
			;;
		*)
			error
			exit 1
			;;
	esac
else
	error
fi