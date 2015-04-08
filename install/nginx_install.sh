#!/bin/bash
#Author:www.saintic.com
#Notes:转载请注明出处！

ROOT_INSTALL=$(cd `dirname $0`; pwd)
. ${ROOT_INSTALL}/../functions

clear
echo "运行此脚本请确保系统为CentOS6.x 64Bit Linux！"
echo "Nginx根目录位于/usr/local/nginx/,程序用户是nginx，服务名是nginx。"

HEAD
if [ $? = "0" ]; then
	DOWNLOAD_NGINX
	yum -y install bzip2 gzip pcre pcre-devel gcc gcc-c++ zlib-devel openssl-devel
	cd $PACKAGE_PATH ; tar zxf nginx-1.6.2.tar.gz ; cd nginx-1.6.2
	groupadd -g 80 nginx ; useradd -M -s /sbin/nologin -u 80 -g nginx nginx
	./configure --prefix=/usr/local/nginx --sbin-path=/usr/sbin/ --user=nginx --group=nginx  --with-poll_module  --with-file-aio  --with-http_ssl_module --with-http_gzip_static_module --with-http_stub_status_module  --with-pcre
	make && make install
	cd $PACKAGE_PATH ; mv nginx-service /etc/init.d/nginx ; chmod +x /etc/init.d/nginx
	chkconfig --add nginx && chkconfig nginx on
	nginx -t &> /dev/null
	if [ $? = "0" ]
		then
			/etc/init.d/nginx start
		else
			echo "Nginx web服务尚未启动！"
			/usr/sbin/nginx -t
	fi
fi

iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
service iptables save

nginx -t &> /dev/null
if [ $? = "0" ]
	then
	echo "Nginx搭建完毕!"
	else
	echo "Nginx尚未完成!"
fi

if [ "$SESTATE" = "1" ]; then
	:
else
	read -p "为保证SELinux正常关闭,请输入Y/y键重启系统,否则输入N/n:" YN
    if [ "$YN" = "Y" ] || [ "$YN" = "y" ]; then
    	reboot
    else
    	exit 1
    fi
fi

