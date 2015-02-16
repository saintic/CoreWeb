#!/bin/bash
#Author:www.saintic.com
#version: v1.0.0
#Note: Global functions.
clear
unset HEAD
unset DOWNLOAD_NGINX
unset DOWNLOAD_APACHE
unset DOWNLOAD_MYSQL

function HEAD() {
	if [ $(id -u) != "0" ]; then
    	echo "Error:请确保以root用户执行此脚本！"
    	exit 1
	fi
	SESTATE=$(sestatus | nl | wc -l)
	if [ "$SESTATE" != "1" ]; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
		sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config &> /dev/null
	fi
}

function DOWNLOAD_NGINX() {
	yum -y install wget 
	cd $PACKAGE_PATH
	wget -c ftp://download.saintic.com/web/nginx-1.6.2.tar.gz
	if [ $? != "0" ]; then
		wget -c http://software.saintic.com/core/web/nginx-1.6.2.tar.gz	
		if [ $? != "0" ]; then
			wget -c http://nginx.org/download/nginx-1.6.2.tar.gz
		fi
	fi
}

function DOWNLOAD_APACHE() {
	cd $PACKAGE_PATH
	wget ftp://download.saintic.com/web/Apache.zip
	if [ $? != "0" ]; then
		wget -c http://software.saintic.com/core/web/Apache.zip
	fi
	unzip Apache.zip -d $PACKAGE_PATH
}

function DOWNLOAD_MYSQL() {
	cd $PACKAGE_PATH
	wget -c ftp://download.saintic.com/web/mysql-5.5.20.tar.gz
	if [ $? != "0" ]; then
		wget -c http://software.saintic.com/core/web/mysql-5.5.20.tar.gz
	fi
}

function SH_CODE_NUM_1() {
	sh ${ROOT}/install/nginx_install.sh
}

function SH_CODE_NUM_2() {
	sh ${ROOT}/install/apache_install.sh
}

function SH_CODE_NUM_3() {
	sh ${ROOT}/install/mysql_install.sh
}

function SH_CODE_NUM_4() {
	sh ${ROOT}/install/memcached_install.sh
}

function SH_CODE_NUM_5() {
	sh ${ROOT}/install/mongodb_install.sh
}

function SH_CODE_NUM_6() {
	sh ${ROOT}/install/php_install.sh
}

function SH_CODE_NUM_7() {
	sh ${ROOT}/install/redis_install.sh
}

: :||:<<\COMMENTS
function INSTALL() {
	if [ $"CODE_NUM_1" = "END" ]; then
		SH_CODE_NUM_1
	fi
	if [ $"CODE_NUM_2" = "END" ]; then
		SH_CODE_NUM_1
		SH_CODE_NUM_2
	fi
	if [ $"CODE_NUM_3" = "END" ]; then
		SH_CODE_NUM_1
		SH_CODE_NUM_2
		SH_CODE_NUM_3
	fi
	if [ $"CODE_NUM_4" = "END" ]; then
		SH_CODE_NUM_1
		SH_CODE_NUM_2
		SH_CODE_NUM_3
		SH_CODE_NUM_4
	fi
	if [ $"CODE_NUM_5" = "END" ]; then
		SH_CODE_NUM_1
		SH_CODE_NUM_2
		SH_CODE_NUM_3
		SH_CODE_NUM_4
		SH_CODE_NUM_5
	fi
	if [ $"CODE_NUM_6" = "END" ]; then
		SH_CODE_NUM_1
		SH_CODE_NUM_2
		SH_CODE_NUM_3
		SH_CODE_NUM_4
		SH_CODE_NUM_5
		SH_CODE_NUM_6
	else
		SH_CODE_NUM_1
		SH_CODE_NUM_2
		SH_CODE_NUM_3
		SH_CODE_NUM_4
		SH_CODE_NUM_5
		SH_CODE_NUM_6
		SH_CODE_NUM_7
	fi
}
COMMENTS


ROOT=$(cd `dirname $0` ; pwd)
PACKAGE_PATH=${ROOT}/software

echo "此脚本是CoreWeb索引文件，请根据需求输入!"
echo "CoreWeb项目是SDI针对LANMP及常用NoSQL所编写的Shell脚本程序，版本1.0.0!"
echo "#####################################################################"
echo "项目分支   代码号" "请在交互式输入中输入代码号(数字)，以进行相应部署!"
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo "Nginx        1"
echo "Httpd        2"
echo "MySQL        3"
echo "MemCached    4"
echo "MongoDB      5"
echo "PHP          6"
echo "Redis        7"
echo "######################################################################"

read -p "请输入对应代码号部署单个服务,若需多项服务请直接回车选择：" CODE_NUM

expr $CODE_NUM + 0 &>/dev/null
if [ $? = "0" ] && [ $CODE_NUM != "" ]; then
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
else
	read -p "请输入第一项服务代码号:" CODE_NUM_1
	read -p "请输入第二项服务代码号,输入'END'代码结束多选项:" CODE_NUM_2
	if [ $"CODE_NUM_2" != "END" ]; then
	    read -p "请输入第三项服务代码号,输入'END'代码结束多选项:" CODE_NUM_3
	else

	fi
	if [ $"CODE_NUM_3" != "END" ]; then
	    read -p "请输入第四项服务代码号,输入'END'代码结束多选项:" CODE_NUM_4
	fi
	if [ $"CODE_NUM_4" != "END" ]; then
	    read -p "请输入第五项服务代码号,输入'END'代码结束多选项:" CODE_NUM_5
	fi
	if [ $"CODE_NUM_5" != "END" ]; then
	    read -p "请输入第六项服务代码号,输入'END'代码结束多选项:" CODE_NUM_6
	fi
	if [ $"CODE_NUM_6" != "END" ]; then
	    read -p "请输入第七项服务代码号,已自动结束多选项:" CODE_NUM_7
	fi
fi

  		SH_CODE_NUM_1
  		SH_CODE_NUM_2

		SH_CODE_NUM_2
		SH_CODE_NUM_3
		SH_CODE_NUM_4
		SH_CODE_NUM_5
		SH_CODE_NUM_6
		SH_CODE_NUM_7