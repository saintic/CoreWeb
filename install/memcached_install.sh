#!/bin/bash
#Author:SaintIC
#Notes:转载请注明出处！
#We SSL Home Page:http://www.saintic.com
clear
echo "MemCache是一套分布式的高速缓存系统;Memcached是一个高性能的分布式内存对象缓存系统，用于动态Web应用以减轻数据库负载。"
echo "软件包均可在http://software.saintic.com/nosql/中获得！"
echo "更多内容及定制需求请访问http://www.saintic.com！"
echo "脚本Memcached对系统要求如下：RHEL/CentOS6.x 64Bit！"
echo "安装完成后请重启您的web服务，即可查看phpinfo中是否存在memcache(d)扩展，若不存在请具体而微自行排错！"
echo "-------------------------------------------------------------------------"
read -p "默认仅安装MemCache系统，如果需要Memcached系统请按Enter回车，否则输入N/n:" MEMCACHED
read -p "请输入PHP安装根目录，如果是默认的/usr/local/php/则按Enter回车，否则请输入具体目录:" PHP_HOME
read -p "如果您需要Memcache(d)网页管理控制台，请直接按Enter回车，否则请输入N/n:" MEMADMIN
	if [ "$MEMADMIN" = "" ]
	then
		read -p "请输入LAMP/LNMP网页根目录以部署MemAdmin,其管理用户和密码是admin/admin:" WEB_HOME
	else
		echo "未部署Memcache(d)控制台，您可以通过sudo netstat -anptl | grep memcache查看相关信息。"
	fi
read -p "您可以自行修改代码，定制请于网站中联系作者，转载注明出处，确认继续按Enter，停止则按Ctrl+C组合键！"

HEAD() {
if [ $(id -u) != "0" ]; then
	echo "Error:请确保以root用户执行此脚本！"
	exit 1
fi
SESTATE=$(sestatus | nl | wc -l)
if [ "$SELINUX" != "1" ]; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi
}

MEMCACHED_ENABLE() {
	if [ "$MEMCACHED" = "" ]; then
		#No.1 libmemcached
		wget ftp://download.saintic.com/nosql/libmemcached-1.0.18.tar.gz
		if [ $? != "0" ]; then
			wget -c http://software.saintic.com/core/nosql/libmemcached-1.0.18.tar.gz
		fi
		tar zxf libmemcached-1.0.18.tar.gz
		cd libmemcached-1.0.18
		./configure --prefix=/usr/local/libmemcached --with-memcached
		make && make install
	
		#No.2 memcached api
		yum -y install json json-devel &> /dev/null
		wget ftp://download.saintic.com/nosql/memcached-api.tar.gz
		if [ $? != "0" ]; then
			wget -c http://software.saintic.com/core/nosql/memcached-api.tar.gz
		fi
		tar zxf memcached-api.tar.gz
		cd memcahed-2.2.0
		if [ "$PHP_HOME" = "" ]; then
			/usr/local/php/bin/phpize
			./configure --enable-memcached --with-libmemcached-dir=/usr/local/libmecached/  --with-php-config=/usr/local/php/bin/php-config  --enable-memcached-json --disable-memcached-sasl && make && make test
			make install > /tmp/memcached-api
			EXT2=$(tail -1 /tmp/memcached-api | awk -F: '{print $2}' | awk '{print $1}')
			if [ -e /usr/local/php/etc/php.ini ]; then
				echo "extension=${EXT2}memcached.so" >> /usr/local/php/etc/php.ini
			else
				echo "extension=${EXT2}memcached.so" >> /etc/php.ini
			fi
		else
			${PHP_HOME}/bin/phpize
			./configure --enable-memcached --with-libmemcached-dir=/usr/local/libmecached/   --with-php-config=${PHP_HOME}/bin/php-config  --enable-memcached-json --disable-memcached-sasl && make && make test
			make install > /tmp/memcached-api
			EXT2=$(tail -1 /tmp/memcached-api | awk -F: '{print $2}' | awk '{print $1}')
			if [ -e ${PHP_HOME}/etc/php.ini ]; then
				echo "extension=${EXT2}memcached.so" >> ${PHP_HOME}/etc/php.ini
			else
				echo "extension=${EXT2}memcached.so" >> /etc/php.ini
			fi
		fi
		return 0
	else
		exit 1
	fi
}

HEAD
if [ $? = "0" ]; then
	yum -y install zlib zlib-devel gcc gcc-c++ openssl-devel json-devel
	#No.1 libevent
	wget ftp://download.saintic.com/nosql/libevent-2.0.21-stable.tar.gz
	if [ $? != "0" ]; then
		wget -c http://software.saintic.com/core/nosql/libevent-2.0.21-stable.tar.gz
	fi
	tar zxf libevent-2.0.21-stable.tar.gz
	cd libevent-2.0.21-stable
	./configure --prefix=/usr/ && make && make install

	#No.2 memcache server
	wget ftp://download.saintic.com/nosql/memcached-1.4.21.tar.gz
	if [ $? != "0" ]; then
		wget -c http://software.saintic.com/core/nosql/memcached-1.4.21.tar.gz
	fi
	tar zxf memcached-1.4.21.tar.gz
	cd memcached-1.4.21
	./configure --with-libevent=/usr && make && make install
	
	#No.3 memcache api
	wget ftp://download.saintic.com/nosql/memcache-api.tar.gz
	if [ $? != "0" ]; then
		wget -c http://software.saintic.com/core/nosql/memcache-api.tar.gz
	fi
	tar zxf memcache-api.tgz
	cd memcache-2.2.4
	if [ "$PHP_HOME" = "" ]
	then
		/usr/local/php/bin/phpize
		./configure --enable-memcache --with-php-config=/usr/local/php/bin/php-config --with-zlib-dir && make && make test
		make install > /tmp/memcache-api
		EXT=$(tail -1 /tmp/memcache-api | awk -F: '{print $2}' | awk '{print $1}')
		if [ -e /usr/local/php/etc/php.ini ]
			then
				echo "extension=${EXT}memcache.so" >> /usr/local/php/etc/php.ini
			else
				echo "extension=${EXT}memcache.so" >> /etc/php.ini
		fi
	else
		${PHP_HOME}/bin/phpize
		./configure --enable-memcache --with-php-config=${PHP_HOME}/bin/php-config --with-zlib-dir
		make && make test
		make install > /tmp/memcache-api
		EXT=$(tail -1 /tmp/memcache-api | awk -F: '{print $2}' | awk '{print $1}')
		if [ -e ${PHP_HOME}/etc/php.ini ]
			then
				echo "extension=${EXT}memcache.so" >> ${PHP_HOME}/etc/php.ini
			else
				echo "extension=${EXT}memcache.so" >> /etc/php.ini
		fi
	fi
fi
#Memcached Enable
if [ "$MEMCACHED" = "" ]; then
	MEMCACHED_ENABLE
fi

#Service Daemon
/usr/local/bin/memcached -d -u root && echo "/usr/local/bin/memcached -d -u root" >> /etc/rc.local

#MemAdmin
if [ "$MEMADMIN" = "" ]; then
	wget -c ftp://download.saintic.com/nosql/memadmin-1.0.12.tar.gz
	if [ $? != "0" ]; then
		wget -c http://software.saintic.com/core/nosql/memadmin-1.0.12.tar.gz
	fi
	tar zxf memadmin-1.0.12.tar.gz
	mv memadmin $WEB_HOME
else
	exit 1
fi
