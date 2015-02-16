#!/bin/bash
#Author:SaintIC
#Notes:转载请注明出处！
#We SSL Home Page:http://www.saintic.com
#技术参数：MongoDB默认端口号tcp/27017,如果开启了SELinux,则如下允许:semanage port -a -t mongodb_port_t -p tcp 27017
clear
echo "MongoDB是一种分布式文档存储NoSQL数据库，旨在为WEB应用提供可扩展高性能存储解决方案。"
echo "软件包均可在http://software.saintic.com/nosql中获得！"
echo "更多内容及定制需求请访问http://www.saintic.com！"
echo "安装完成后请重启您的web服务器，即可查看phpinfo中是否存在mongo扩展，若不存在请具体而微自行排错！"
echo "------------------------------------------------------"
echo "MongoDB Web控制台管理员及密码：admin/admin,可修改mongoadmin下config.php更改用户名及密码。"
echo "------------------------------------------------------"
read -p "请输入MongoDB安装的目录:" MONGO_HOME
read -p "请输入PHP安装根目录，如果是默认的/usr/local/php/则按Enter回车，若不是请输入具体目录:" PHP_HOME
read -p "请输入LAMP/LNMP网页根目录(以"/"结尾)，以便部署MongoDB网页控制台mongoadmin,如果不需此项，请直接按Enter回车:" WEB_HOME
read -p "您可以自行修改代码，定制请联系作者，转载注明出处，确认继续按Enter，停止则按Ctrl+C组合键！" 

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error:请确保以root用户执行此脚本！"
    exit 1
fi

#Disable SeLinux
SESTATE=$(sestatus | nl | wc -l)
if [ "$SELINUX" != "1" ]; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

ARCH=$(uname -p)
#根据系统下载源码包
if [ "$ARCH" = "x86_64" ] || [ $ARCH = "amd64" ]
then
	wget -c ftp://download.saintic.com/nosql/mongodb-linux-x86_64-2.6.5.tgz
	if [ $? != "0" ]; then
		wget -c http://software.saintic.com/core/nosql/mongodb-linux-x86_64-2.6.5.tgz
	tar zxf mongodb-linux-x86_64-2.6.5.tgz
	mv mongodb-linux-x86_64-2.6.5 $MONGO_HOME
	mkdir ${MONGO_HOME}/data
	touch ${MONGO_HOME}/mongod.logs
	echo "dbpath = $MONGO_HOME/data
logpath = $MONGO_HOME/mongod.logs
logappend = true
port = 27017
fork = true
auth = true" > ${MONGO_HOME}/mongod.conf
	$MONGO_HOME/bin/mongod -f $MONGO_HOME/mongod.conf &> /dev/null
else
	wget ftp://download.saintic.com/nosql/mongodb-linux-i686-2.6.5.gz
	tar zxf mongodb-linux-i686-2.6.5.gz
	mv mongodb-linux-i686-2.6.5 $MONGO_HOME
	mkdir ${MONGO_HOME}/data
	touch ${MONGO_HOME}/mongod.logs
	echo "dbpath = ${MONGO_HOME}/data
logpath = ${MONGO_HOME}/mongod.logs
logappend = true
port = 27017
fork = true
auth = true" > ${MONGO_HOME}mongod.conf
	${MONGO_HOME}/bin/mongod -f ${MONGO_HOME}/mongod.conf &> /dev/null
fi
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

#web control
if [ "$WEB_HOME" = "" ]
        then
                echo "MongoDB Linux Cli Command:mongo,未安装web控制台！"
        else
                yum -y install unzip &> /dev/null
                wget ftp://download.saintic.com/nosql/rockmongo-master.zip
                unzip rockmongo-master.zip
                mv rockmongo-master ${WEB_HOME}/mongoadmin
fi

#php-mongo api
wget ftp://download.saintic.com/nosql/mongo-1.5.7.tgz
tar zxf mongo-1.5.7.tgz
cd mongo-1.5.7
if [ "$PHP_HOME" = "" ]
	then
		/usr/local/php/bin/phpize 
		./configure --enable-mongo --with-php-config=/usr/local/php/bin/php-config
		make && make test && make install > /tmp/mongo-api
		EXT=$(tail -1 /tmp/mongo-api | awk -F: '{print $2}' | awk '{print $1}')
		if [ -e /usr/local/php/etc/php.ini ]
			then
				echo "extension=${EXT}mongo.so" >> /usr/local/php/etc/php.ini
			else
			    echo "extension=${EXT}mongo.so" >> /etc/php.ini
		fi
	else
		${PHP_HOME}/bin/phpize
		./configure --enable-mongo --with-php-config=${PHP_HOME}/bin/php-config
		make && make test && make install > /tmp/mongo-api
		EXT=$(tail -1 /tmp/mongo-api | awk -F: '{print $2}' | awk '{print $1}')
		if [ -e ${PHP_HOME}/etc/php.ini ]
			then
				echo "extension=${EXT}mongo.so" >> ${PHP_HOME}/etc/php.ini
			else
			    echo "extension=${EXT}mongo.so" >> /etc/php.ini
		fi
fi
