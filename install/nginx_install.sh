#!/bin/bash
#Author:www.saintic.com
#Notes:转载请注明出处！

ROOT_INSTALL=$(cd `dirname $0`; pwd)
. ${ROOT_INSTALL}/../functions
clear
echo -e "\033[34m脚本会自动检测服务器环境进行配置文件修改，若有不恰之处，请手工修改！\033[0m"
read -p "请输入Nginx安装目录(直接回车默认/usr/local/nginx/)：" NGINX_HOME
read -p "请输入网站域名：" NGINX_DN
read -p "请输入Nginx程序用户(运行用户和运行组同名)：" NGINX_RUN
if [ "$NGINX_HOME" = "" ]; then
	NGINX_HOME=/usr/local/nginx
fi
if [ "$NGINX_DN" = "" ]; then
    NGINX_DN=$HOSTNAME
else
	NGINX_DN=$NGINX_DN
fi
NGINX_CONF() {
	sed -i "s/worker_processes  1;/worker_processes  ${CPU};/g" nginx.conf
	sed -i '13i use epoll;' nginx.conf
	sed -i 's/worker_connections  ....;/worker_connections  13521;/' nginx.conf
	sed -i "s/server_name  localhost;/    server_name  ${NGINX_DN};/" nginx.conf
	sed -i 's/#gzip  on;/gzip on;/' nginx.conf
}

HEAD &&	DOWNLOAD_NGINX || exit 1
yum -y install pcre pcre-devel gcc gcc-c++ zlib-devel openssl-devel
useradd -M -s /sbin/nologin $NGINX_RUN
cd $PACKAGE_PATH ; tar zxf nginx-1.6.2.tar.gz ; cd nginx-1.6.2
./configure --prefix=$NGINX_HOME --sbin-path=/usr/sbin/ --user=$NGINX_RUN --group=$NGINX_RUN --with-poll_module --with-http_ssl_module --with-http_gzip_static_module --with-http_stub_status_module --with-pcre && make && make install
cd ${NGINX_HOME}/conf
NGINX_CONF

cd $PACKAGE_PATH ; mv nginx-service /etc/init.d/nginx ; chmod +x /etc/init.d/nginx
chkconfig --add nginx
chkconfig nginx on

nginx -t &> /dev/null
if [ $? = "0" ]
	then
		/etc/init.d/nginx start
	else
		echo "Nginx Web服务尚未启动！"
		/usr/sbin/nginx -t
fi

[ "$SYS_VERSION" = "5" ] && iptables -I INPUT -p tcp --dport 80 -j ACCEPT && service iptables save
[ "$SYS_VERSION" = "6" ] && iptables -I INPUT -p tcp --dport 80 -j ACCEPT && service iptables save
[ "$SYS_VERSION" = "7" ] && systemctl stop firewalld

nginx -t &> /dev/null  && netstat -anptl | grep nginx &> /dev/null
if [ $? = "0" ]
	then
	echo "Nginx部署完毕!"
	else
	echo "Nginx尚未完成!"
fi

SESTATE=$(sestatus | wc -l)
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