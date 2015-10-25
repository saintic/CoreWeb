#!/bin/bash
#Author:www.saintic.com
#Notes:转载请注明出处！

ROOT_INSTALL=$(cd `dirname $0`; pwd)
. ${ROOT_INSTALL}/../functions
clear
echo -e "\033[35mMemCache是一套分布式的高速缓存系统;Memcached是一个高性能的分布式内存对象缓存系统，用于动态Web应用以减轻数据库负载。\033[0m"
read -p "默认仅安装MemCache系统，如果需要Memcached系统请按Enter回车，否则输入N/n:" MEMCACHED
read -p "请输入PHP安装根目录，如果是默认的/usr/local/php/则按Enter回车，否则请输入具体目录:" PHP_HOME
read -p "如果您需要MemCached网页管理控制台，请直接按Enter回车，否则请输入N/n:" MEMADMIN
	if [ "$MEMADMIN" = "" ]; then
		read -p "请输入LAMP/LNMP网页根目录以部署MemAdmin,其管理用户和密码是admin/admin:" WEB_HOME
	else
		echo -e "033[31m未部署Memcache控制台，您可以通过sudo netstat -anptl | grep memcache查看相关信息。\033[0m"
	fi
    if [ "$PHP_HOME" = "" ]; then
    	PHP_HOME=/usr/local/php
    fi
echo -e "\033[31m遵从GPL协议,允许自行修改代码,定制请联系作者,转载请注明出处,终止脚本按Ctrl+C组合键！\033[0m"

MEMCACHED_ENABLE() {
	yum -y install json json-devel ; cd $PACKAGE_PATH
	tar zxf libmemcached-1.0.18.tar.gz
	tar zxf memcached-api.tar.gz
	cd ${PACKAGE_PATH}/libmemcached-1.0.18
	./configure --prefix=/usr/local/libmemcached --with-memcached && make && make install
	cd ${PACKAGE_PATH}/memcached-2.2.0
	${PHP_HOME}/bin/phpize
	./configure --enable-memcached --with-libmemcached-dir=/usr/local/libmemcached/   --with-php-config=${PHP_HOME}/bin/php-config  --enable-memcached-json --disable-memcached-sasl
	make ; 
make test <<EOF
n
EOF
	make install > ${ROOT}/software/memcached-api.txt
	local EXT2=$(tail -1 ${ROOT}/software/memcached-api.txt | awk -F: '{print $2}' | awk '{print $1}')
	if [ -f ${PHP_HOME}/etc/php.ini ]; then
		echo "extension=${EXT2}memcached.so" >> ${PHP_HOME}/etc/php.ini
	else
		echo "extension=${EXT2}memcached.so" >> /etc/php.ini
	fi
}

HEAD && DOWNLOAD_MEMCACHE || exit 1
yum -y install zlib zlib-devel gcc gcc-c++ openssl-devel json-devel bzip2 gzip
cd $PACKAGE_PATH
tar zxf libevent-2.0.21-stable.tar.gz
tar zxf memcached-1.4.21.tar.gz
tar zxf memcache-api.tar.gz

#No.1 libevent
cd ${PACKAGE_PATH}/libevent-2.0.21-stable
./configure --prefix=/usr/ && make && make install

#No.2 memcache server
cd ${PACKAGE_PATH}/memcached-1.4.21
./configure --with-libevent=/usr && make && make install

#No.3 memcache api
cd ${PACKAGE_PATH}/memcache-2.2.4
${PHP_HOME}/bin/phpize
./configure --enable-memcache --with-php-config=${PHP_HOME}/bin/php-config --with-zlib-dir
make
make test <<EOF
n
EOF
make install > ${ROOT}/software/memcache-api.txt
EXT1=$(tail -1 ${ROOT}/software/memcache-api.txt | awk -F: '{print $2}' | awk '{print $1}')
if [ -f ${PHP_HOME}/etc/php.ini ]
then
	echo "extension=${EXT1}memcache.so" >> ${PHP_HOME}/etc/php.ini
else
	echo "extension=${EXT1}memcache.so" >> /etc/php.ini
fi

#MemCached Enable
if [ "$MEMCACHED" = "" ]; then
	MEMCACHED_ENABLE	
    #Service Daemon
    /usr/local/bin/memcached -d -u root -l 127.0.0.1
    echo "/usr/local/bin/memcached -d -u root  -l 127.0.0.1" >> /etc/rc.local
else
	:
fi

#MemAdmin
if [ "$MEMADMIN" = "" ]; then
	cd $PACKAGE_PATH ; tar zxf memadmin-1.0.12.tar.gz -C $WEB_HOME
fi
