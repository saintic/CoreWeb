#!/bin/bash
#Author:SaintIC
#Notes:转载请注明出处！
#My Home Page:http://www.saintic.com
#This script code num is 2.
clear
echo "运行此脚本请确保系统为CentOS6.x 64Bit Linux！"
echo "Apache根目录位于/usr/local/apache,配置文件是/etc/httpd/httpd.conf"
. ../functions
. ../index.sh

HEAD
if [ $? = "0" ]; then
	DOWNLOAD_APACHE
	yum -y install libtool pcre-devel gcc-c++ gcc cmake expat-devel zlib-devel neon-devel openssl-devel cyrus-sasl-devel
    #1.Apr,Apr-util
	cd $PACKAGE_PATH
	tar zxf apr-1.2.12.tar.gz
	cd apr-1.2.12	
	./configure --enable-shared && make && make install

	cd $PACKAGE_PATH
	tar zxf apr-util-1.2.12.tar.gz
	cd apr-util-1.2.12
	./configure --enable-shared --with-expat=builtin --with-apr=/usr/local/apr/ && make && make install

	#2.Apache
	cd $PACKAGE_PATH
	tar zxf httpd-2.2.29.tar.gz
	cd httpd-2.2.29
	./configure  --prefix=/usr/local/apache/ --sysconfdir=/etc/httpd --enable-mods-shared=most --enable-modules=most --enable-so --enable-rewrite=shared --enable-ssl=shared --with-ssl --enable-cgi --enable-dav --with-included-apr   --with-apr=/usr/local/apr/bin/apr-1-config --with-apr-util=/usr/local/apr/bin/apu-1-config --enable-static-support --enable-charset-lite
	make && make install

	cp /usr/local/apache/bin/apachectl /etc/init.d/httpd 
	echo "#chkconfig:2345 13 52" >> /etc/init.d/httpd
	echo "#description:Apache HTTP Server" >> /etc/init.d/httpd
	chkconfig --add httpd && chkconfig httpd on
	sed -i "s/#ServerName www.example.com:80/ServerName www.saintic.com/g" /etc/httpd/httpd.conf
	/usr/local/apache/bin/apachectl -t &> /dev/null
	if [ $? = "0" ]; then
		/usr/local/apache/bin/apachectl start && echo "已经启动httpd服务！"
	else
		/usr/local/apache/bin/apachectl -t
	fi
fi

iptables -I INPUT -p tcp --dport 80 -j ACCEPT
service iptables save

apachectl -t && echo $? &> /dev/null
if [ $? = "0" ]
	then
	echo "Apache搭建完毕!"
	else
	echo "Apache尚未完成!"
fi

SESTATE=$(sestatus | nl | wc -l)
if [ "$SESTATE" != "1" ]; then
	read -p "为保证SELinux正常关闭,请输入Y/y键重启系统,否则输入N/n:" YN
    if [ "$YN" = "Y" ] || [ "$YN" = "y" ]
    then
    	reboot
    else
    	exit 1
    fi
else
	exit 0
fi

