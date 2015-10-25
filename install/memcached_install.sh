#!/bin/bash
#Author:www.saintic.com
#Notes:转载请注明出处！

ROOT_INSTALL=$(cd `dirname $0`; pwd)
. ${ROOT_INSTALL}/../functions

clear
echo "MemCache是一套分布式的高速缓存系统;Memcached是一个高性能的分布式内存对象缓存系统，用于动态Web应用以减轻数据库负载。"
read -p "默认仅安装MemCache系统，如果需要Memcached系统请按Enter回车，否则输入N/n:" MEMCACHED
read -p "请输入PHP安装根目录，如果是默认的/usr/local/php/则按Enter回车，否则请输入具体目录:" PHP_HOME
if [ "$PHP_HOME" = "" ]; then
	PHP_HOME=/usr/local/php
fi
read -p "如果您需要Memcache(d)网页管理控制台，请直接按Enter回车，否则请输入N/n:" MEMADMIN
	if [ "$MEMADMIN" = "" ]; then
		read -p "请输入LAMP/LNMP网页根目录以部署MemAdmin,其管理用户和密码是admin/admin:" WEB_HOME
	else
		echo "未部署Memcache控制台，您可以通过sudo netstat -anptl | grep memcache查看相关信息。"
	fi
echo "遵从GPL协议,允许自行修改代码,定制请于网站中联系作者,转载请注明出处,终止脚本按Ctrl+C组合键！"

MEMCACHED_ENABLE() {
yum -y install json json-devel
cd $PACKAGE_PATH ; tar zxf libmemcached-1.0.18.tar.gz ;	cd libmemcached-1.0.18
./configure --prefix=/usr/local/libmemcached --with-memcached && make && make install
cd $PACKAGE_PATH ; tar zxf memcached-api.tar.gz ; cd memcached-2.2.0
${PHP_HOME}/bin/phpize
./configure --enable-memcached --with-libmemcached-dir=/usr/local/libmemcached/   --with-php-config=${PHP_HOME}/bin/php-config  --enable-memcached-json --disable-memcached-sasl
make && make test && make install > /tmp/memcached-api
local EXT2=$(tail -1 /tmp/memcached-api | awk -F: '{print $2}' | awk '{print $1}')
if [ -f ${PHP_HOME}/etc/php.ini ]; then
	echo "extension=${EXT2}memcached.so" >> ${PHP_HOME}/etc/php.ini
else
	echo "extension=${EXT2}memcached.so" >> /etc/php.ini
fi
}

HEAD && DOWNLOAD_MEMCACHE || exit 1
yum -y install zlib zlib-devel gcc gcc-c++ openssl-devel json-devel
#No.1 libevent
cd $PACKAGE_PATH ; tar zxf libevent-2.0.21-stable.tar.gz ; cd libevent-2.0.21-stable
./configure --prefix=/usr/ && make && make install

#No.2 memcache server
cd $PACKAGE_PATH ; tar zxf memcached-1.4.21.tar.gz ; cd memcached-1.4.21
./configure --with-libevent=/usr && make && make install
	
#No.3 memcache api
cd $PACKAGE_PATH ; tar zxf memcache-api.tar.gz ; cd memcache-2.2.4
${PHP_HOME}/bin/phpize
./configure --enable-memcache --with-php-config=${PHP_HOME}/bin/php-config --with-zlib-dir
make && make test && make install > /tmp/memcache-api
local EXT=$(tail -1 /tmp/memcache-api | awk -F: '{print $2}' | awk '{print $1}')
if [ -f ${PHP_HOME}/etc/php.ini ]
then
	echo "extension=${EXT}memcache.so" >> ${PHP_HOME}/etc/php.ini
else
	echo "extension=${EXT}memcache.so" >> /etc/php.ini
fi

#Memcached Enable
if [ "$MEMCACHED" = "" ]; then
	MEMCACHED_ENABLE
else
	:
fi

#Service Daemon
/usr/local/bin/memcached -d -u root && echo "/usr/local/bin/memcached -d -u root" >> /etc/rc.local

#MemAdmin
if [ "$MEMADMIN" = "" ]; then
	cd $PACKAGE_PATH ; tar zxf memadmin-1.0.12.tar.gz
	mv memadmin $WEB_HOME
else
	exit 0
fi
