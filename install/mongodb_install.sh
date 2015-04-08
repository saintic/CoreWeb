#!/bin/bash
#Author:www.saintic.com
#Notes:转载请注明出处！

ROOT_INSTALL=$(cd `dirname $0`; pwd)
. ${ROOT_INSTALL}/../functions

clear
echo "MongoDB是一种分布式文档存储NoSQL数据库，旨在为WEB应用提供可扩展高性能存储解决方案。"
read -p "请输入MongoDB安装的目录:" MONGO_HOME
read -p "是否安装MongoFB for PHP扩展？(y/n)" PHP_API
if [ $PHP_API = "y" ] || [ $PHP_API = "Y" ]; then
	read -p "请输入PHP安装根目录，如果是默认的/usr/local/php/则按Enter回车，若不是请输入具体目录:" PHP_HOME
	if [ "$PHP_HOME" = "" ]; then
        PHP_HOME=/usr/local/php
	fi
	read -p "请输入网站根目录,以部署MongoDB控制台MongoAdmin;如果不需此项,请输入N/n：" WEB_HOME
	if [ $WEB_HOME != "n" ] || [ $WEB_HOME != "N" ]; then
		echo "MongoAdmin控制台管理员及密码:admin/admin,可修改mongoadmin下config.php更改用户名及密码。"
	else
    	echo "MongoDB Linux Cli Command:mongo,未安装web控制台！"
	fi
fi
echo "遵从GPL协议,允许自行修改代码,定制请于网站中联系作者,转载请注明出处,终止脚本按Ctrl+C组合键！"

HEAD && DOWNLOAD_MONGO || exit 1
rpm -q gzip &> /dev/null || yum -y install gzip
if [ "$ARCH" = "x86_64" ]; then
	cd $PACKAGE_PATH ; tar zxf mongodb-linux-x86_64-2.6.5.tgz
	mv mongodb-linux-x86_64-2.6.5 $MONGO_HOME
else
	cd $PACKAGE_PATH ; tar zxf mongodb-linux-i686-2.6.5.gz
	mv mongodb-linux-i686-2.6.5 $MONGO_HOME
fi

mkdir ${MONGO_HOME}/data ; touch ${MONGO_HOME}/mongod.logs
cat > ${MONGO_HOME}/mongod.conf<<EOF
dbpath = ${MONGO_HOME}/data
logpath = ${MONGO_HOME}/mongod.logs
logappend = true
port = 27017
fork = true
auth = true
EOF
${MONGO_HOME}/bin/mongod -f ${MONGO_HOME}/mongod.conf &> /dev/null

echo "PATH=$PATH:${MONGO_HOME}/bin" >> /etc/profile
source /etc/profile

netstat -anptl | grep mongod &> /dev/null
if [ $? = "0" ]
	then
		echo "MongoDB安装完毕，并已启动服务。"
		netstat -anptl | grep mongod
	else
		echo "安装未完成，请检查流程。"
		exit 1
fi
echo "${MONGO_HOME}/bin/mongod -f ${MONGO_HOME}/mongod.conf" >>  /etc/rc.local

#php-mongo api
if [ $PHP_API = "y" ] || [ $PHP_API = "Y" ]; then
	cd $PACKAGE_PATH ; tar zxf mongo-1.5.7.tgz ; cd mongo-1.5.7
	${PHP_HOME}/bin/phpize
	./configure --enable-mongo --with-php-config=${PHP_HOME}/bin/php-config
	make && make test && make install > /tmp/mongo-api
	EXT=$(tail -1 /tmp/mongo-api | awk -F: '{print $2}' | awk '{print $1}')
	if [ -f ${PHP_HOME}/etc/php.ini ]
	then
		echo "extension=${EXT}mongo.so" >> ${PHP_HOME}/etc/php.ini
	else
	    echo "extension=${EXT}mongo.so" >> /etc/php.ini
	fi
fi
#web control
if [ "$WEB_HOME" != "N" ] || [ "$WEB_HOME" != "n" ]
then
    yum -y install unzip
    cd $PACKAGE_PATH ; unzip rockmongo-master.zip ; mv rockmongo-master ${WEB_HOME}/mongoadmin
fi