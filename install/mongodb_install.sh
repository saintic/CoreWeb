#!/bin/bash
#Author:www.saintic.com
#Notes:转载请注明出处！

ROOT_INSTALL=$(cd `dirname $0`; pwd)
. ${ROOT_INSTALL}/../functions ; clear

MONGO_DEFAULT_CONF() {
if [ "$ARCH" = "x86_64" ]; then
	tar zxf mongodb-linux-x86_64-2.6.5.tgz
	mv mongodb-linux-x86_64-2.6.5 /mongodb
else
	tar zxf mongodb-linux-i686-2.6.5.gz
	mv mongodb-linux-i686-2.6.5 /mongodb
fi
mkdir -p /mongodb/data
cat > /mongodb/mongod.conf <<EOF
dbpath = /mongodb/data
logpath = /mongodb/mongod.log
logappend = true
bind_ip = 127.0.0.1
port = 27017
fork = true
auth = true
pidfilepath = /var/run/mongod.pid
nohttpinterface = true
EOF
/mongodb/bin/mongod -f /mongodb/mongod.conf &
ln -s /mongodb/bin/* /usr/local/bin/
echo "/mongodb/bin/mongod -f /mongodb/mongod.conf" >> /etc/rc.local
}

MONGO_DIY_CONF() {
cd $PACKAGE_PATH
	if [ "$ARCH" = "x86_64" ]; then
		tar zxf mongodb-linux-x86_64-2.6.5.tgz
		mv mongodb-linux-x86_64-2.6.5 $MONGO_HOME
	else
		tar zxf mongodb-linux-i686-2.6.5.gz
		mv mongodb-linux-i686-2.6.5 $MONGO_HOME
	fi
	mkdir $DATA && touch $LOG
cat > ${MONGO_HOME}/mongod.conf <<EOF
dbpath = $DATA
logpath = $LOG
logappend = true
bind_ip = 127.0.0.1
port = $PORT
fork = true
auth = true
pidfilepath = /var/run/mongod.pid
nohttpinterface = true
EOF
	${MONGO_HOME}/bin/mongod -f ${MONGO_HOME}/mongod.conf &
	ln -s ${MONGO_HOME}/bin/* /usr/local/bin/
	echo "${MONGO_HOME}/bin/mongod -f ${MONGO_HOME}/mongod.conf &" >> /etc/rc.local
}

web_control() {
if [ "$ENABLE_WEB_CONTROL" = "y" ] || [ "$ENABLE_WEB_CONTROL" = "Y" ]; then
    yum -y install unzip
    cd $PACKAGE_PATH ; unzip rockmongo-master.zip ; mv rockmongo-master ${WEB_HOME}/mongoadmin
fi
}

api() {
	cd $PACKAGE_PATH ; tar zxf mongo-1.5.7.tgz ; cd mongo-1.5.7
	${PHP_HOME}/bin/phpize
	./configure --enable-mongo --with-php-config=${PHP_HOME}/bin/php-config
	make && make test && make install > ${ROOT}/software/mongo-api.txt
	EXT3=$(tail -1 ${ROOT}/software/mongo-api.txt | awk -F: '{print $2}' | awk '{print $1}')
	if [ -f ${PHP_HOME}/etc/php.ini ]
	then
		echo "extension=${EXT3}mongo.so" >> ${PHP_HOME}/etc/php.ini
	else
	    echo "extension=${EXT3}mongo.so" >> /etc/php.ini
	fi
}

echo -e "\033[33m以下输入默认选项请直接回车！\033[0m"

read -p "是否需要PHP扩展？(y/n)" ENABLE_PHP
if [ "$ENABLE_PHP" = "y" ] || [ "$ENABLE_PHP" = "Y" ]; then
	read -p "请输入PHP安装根目录，如果是默认的/usr/local/php/则按Enter回车，若不是请输入具体目录:" PHP_HOME
	if [ "$PHP_HOME" = "" ]; then
	  PHP_HOME=/usr/local/php
	fi
fi

read -p "是否采用MongoDB默认配置项？(y/n)" ENABLE_DEFAULT_CONF
  if [ "$ENABLE_DEFAULT_CONF" = "y" ] || [ "ENABLE_DEFAULT_CONF" = "Y" ]; then
	echo -e "\033[33m您已采用默认配置,MongoDB根目录是/mongodb!\033[0m"
  else
	echo -e "\033[33m请在交互式模式输入您需要的参数！\033[0m"
	read -p "请输入MongoDB安装根目录:" MONGO_HOME
	echo -e "\033[33m根目录是${MONGO_HOME},以下涉及目录或文件请直接填写名称即可！\033[0m"
	read -p "请输入MongoDB数据目录:" DATA
	read -p "请输入MongoDB监听端口:" PORT
	read -p "请输入MongoDB日志文件:" LOG
	echo -e "\033[33m更多定制请参考配置文件！\033[0m"
	DATA=${MONGO_HOME}/${DATA}
	LOG=${MONGO_HOME}/${LOG}
	echo -e "\033[33mMongoDB数据目录是${DATA},监听端口是${PORT},日志文件是${LOG}！\033[0m"
  fi

read -p "是否部署MongoDB网页控制台(y/n):" ENABLE_WEB_CONTROL
  if [ "$ENABLE_WEB_CONTROL" = "N" ] || [ "$ENABLE_WEB_CONTROL" = "n" ]; then
    echo "MongoDB Linux Cli Command:mongo;未安装MongoDB Web控制台！"
  else
  	read -p "请输入web控制台安装目录:" WEB_HOME
	echo -e "\033[33mMongoAdmin控制台管理员及密码:admin/admin,可修改${WEB_HOME}/mongoadmin下config.php更改用户名及密码。\033[0m"
  fi

echo -e "\033[33m遵从GPLv2协议,允许自由修改代码,定制请联系作者,转载请注明出处,终止脚本请按Ctrl+C组合键！\033[0m"

HEAD && DOWNLOAD_MONGO || exit 1
cd $PACKAGE_PATH

if [ "$ENABLE_DEFAULT_CONF" = "y" ] || [ "$ENABLE_DEFAULT_CONF" = "Y" ]; then
	MONGO_DEFAULT_CONF
elif [ "$ENABLE_DEFAULT_CONF" = "n" ] || [ "$ENABLE_DEFAULT_CONF" = "N" ]; then
	MONGO_DIY_CONF
fi

if [ "$ENABLE_PHP" = "y" ] || [ "$ENABLE_PHP" = "Y" ]; then
	api
else
	:
fi

web_control

netstat -anptl | grep mongod &> /dev/null
if [ "$?" = "0" ]; then
	echo "MongoDB安装完毕，并已启动服务。"
	netstat -anptl | grep mongod
else
	echo "安装未完成，请检查流程。" ; exit 1
fi
