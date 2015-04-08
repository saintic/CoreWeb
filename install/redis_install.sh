#!/bin/bash
#Author:www.saintic.com
#Notes:转载请注明出处！

ROOT_INSTALL=$(cd `dirname $0`; pwd)
. ${ROOT_INSTALL}/../functions
read -p "是否需要PHP扩展？(y/n)" ENABLE_PHP_API
if [ $ENABLE_PHP_API = "y" ] || [ $ENABLE_PHP_API = "Y" ]; then
	read -p "请输入PHP安装目录，默认/usr/local/php则回车：" PHP_HOME
fi
if [ "$PHP_HOME" = "" ]; then
	PHP_HOME=/usr/local/php
fi
clear
HEAD && DOWNLOAD_REDIS || exit 1
cd $PACKAGE_PATH ; tar zxf redis-2.8.17.tar.gz
cd redis-2.8.17
make
make install
cd utils ; sh install_server.sh
echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
sysctl -p &> /dev/null

#php redis api
if [ $ENABLE_PHP_API = "y" ] || [ $ENABLE_PHP_API = "Y" ]; then
	cd ${PACKAGE_PATH} ; tar zxf redis-api.tar.gz ; cd phpredis-2.2.4
	${PHP_HOME}/bin/phpize
	./configure --enable-redis --with-php-config=${PHP_HOME}/bin/php-config
	make && make test && make install > /tmp/redis-api.txt
	EXT=$(tail -1 /tmp/redis-api.txt | awk -F: '{print $2}' | awk '{print $1}')
	if [ -f ${PHP_HOME}/etc/php.ini ]; then
		echo "extension=${EXT}redis.so" >> ${PHP_HOME}/etc/php.ini
	else
	    echo "extension=${EXT}redis.so" >> /etc/php.ini
	fi
fi