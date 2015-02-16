#!/bin/bash
#Author:SaintIC
#Notes:转载请注明出处！
#My Home Page:http://www.saintic.com
clear
echo "运行此脚本请确保系统为CentOS6.x 64Bit Linux！"
echo "软件包均可在http://software.saintic.com中获得！"
echo "作者:SaintIC,更多内容请访问http://www.saintic.com!"
echo '此脚本交互式输入目录标准格式是不以"/"结尾，例如/usr/local/php!'
echo "--------------------------------------------------"
echo "安装PHP请先确保安装了WEB/DB服务器，建议是本地安装Apache/Nginx+MySQL!"
read -p "请输入MySQL安装根目录:" MYSQL_HOME
read -p "请输入Web服务器类型,Apache为A/a,Nginx为N/n:" WEB_TYPE
	if [ "$WEB_TYPE" = "A" ] || [ "$WEB_TYPE" = "a" ]; then
		read -p "请输入Apache安装根目录:" APACHE_HOME
	else
		read -p "请输入Nginx安装根目录:" NGINX_HOME
		read -p "请输入Nginx程序用户:" NGINX_USER
		read -p "请输入Nginx程序组:" NGINX_GROUP
	fi
read -p "请输入您希望的PHP安装根目录,默认是/usr/local/php/,若是默认请按Enter回车,否则请输入具体目录:" PHP_HOME
	if [ "$PHP_HOME" = "" ]; then
		echo "PHP根目录位于/usr/local/php/，配置文件是/etc/php.ini"
	else
		echo "PHP根目录位于$PHP_HOME,配置文件是/etc/php.ini"
	fi
echo "--------------------------------------------------"
read -p "请输入软件解压目录,请确保路径正确,否则按Ctrl+C终止:" PACKAGE_PATH

function HEAD() {
	if [ $(id -u) != "0" ]; then
    	echo "Error:请确保以root用户执行此脚本！"
    	exit 1
	fi
	SESTATE=$(sestatus | nl | wc -l)
	if [ "$SELINUX" != "1" ]; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
		sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
	fi
}

function PHP-FPM() {
	cp php-fpm.conf.default php-fpm.conf
	sed -i "s/user = nobody/user = ${NGINX_USER}/g" php-fpm.conf
	sed -i "s/group = nobody/group = ${NGINX_GROUP}/g" php-fpm.conf
}

function PHP_TYPE_CONF() {
	if [ "$WEB_TYPE" = "A" ] || [ "$WEB_TYPE" = "a" ]; then
		if [ "$PHP_HOME" = "" ]; then
			./configure --prefix=/usr/local/php --with-config-file-path=/etc --with-apxs2=${APACHE_HOME}/bin/apxs  --with-mysql=$MYSQL_HOME --with-mysqli=${MYSQL_HOME}/bin/mysql_config --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --enable-inline-optimization --with-curl --enable-mbstring --with-mhash --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --enable-sockets --with-pdo-mysql --enable-pdo --enable-zip --enable-soap --enable-ftp  --enable-shmop --with-bz2 --enable-exif --with-gettext
			make && make install
		else
			./configure --prefix=$PHP_HOME --with-config-file-path=/etc --with-apxs2=${APACHE_HOME}/bin/apxs  --with-mysql=$MYSQL_HOME --with-mysqli=${MYSQL_HOME}/bin/mysql_config --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --enable-inline-optimization --with-curl --enable-mbstring --with-mhash --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --enable-sockets --with-pdo-mysql --enable-pdo --enable-zip --enable-soap --enable-ftp  --enable-shmop --with-bz2 --enable-exif --with-gettext
			make && make install
		fi
	else
		if [ "$PHP_HOME" = "" ]; then
			./configure --prefix=/usr/local/php --with-config-file-path=/etc --enable-fpm --with-mysql=$MYSQL_HOME --with-mysqli=${MYSQL_HOME}/bin/mysql_config --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --enable-inline-optimization --with-curl --enable-mbstring --with-mhash --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --enable-sockets --with-pdo-mysql --enable-pdo --enable-zip --enable-soap --enable-ftp  --enable-shmop --with-bz2 --enable-exif --with-gettext
			make && make install
			cd /usr/local/php/etc/
			PHP-FPM
		else
			./configure --prefix=$PHP_HOME --with-config-file-path=/etc --enable-fpm --with-mysql=$MYSQL_HOME --with-mysqli=${MYSQL_HOME}/bin/mysql_config --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --enable-inline-optimization --with-curl --enable-mbstring --with-mhash --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --enable-sockets --with-pdo-mysql --enable-pdo --enable-zip --enable-soap --enable-ftp  --enable-shmop --with-bz2 --enable-exif --with-gettext
			make && make install
			cd ${PHP_HOME}/etc/
			PHP-FPM
		fi
	fi
}

HEAD
if [ $? = "0" ]; then
	yum -y install wget unzip
	wget ftp://download.saintic.com/web/php.zip
	if [ $? != "0" ]; then
		wget -c http://software.saintic.com/core/web/php.zip
	fi
	unzip php.zip -d $PACKAGE_PATH
	yum -y remove php
	yum -y install libxml2-devel libtool pcre-devel ncurses-devel bison-devel gcc-c++ gcc make cmake expat-devel zlib-devel gd-devel libcurl-devel bzip2-devel readline-devel libedit-devel perl neon-devel openssl-devel cyrus-sasl-devel php-mbstring php-bcmath gettext-devel curl-devel libjpeg-devel libpng-devel
	#部署PHP
	cd $PACKAGE_PATH
	tar zxf libmcrypt-2.5.7.tar.gz
	tar zxf mhash-0.9.2.tar.gz
	tar zxf mcrypt-2.6.4.tar.gz 
	tar jxf php-5.4.33.tar.bz2
	tar zxf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz

	ln -s /usr/lib64/libjpeg.so /usr/lib/libjpeg.so &> /dev/null
	ln -s /usr/lib64/libpng.so /usr/lib/libpng.so &> /dev/null

	cd ${PACKAGE_PATH}/libmcrypt-2.5.7
	./configure && make && make install
	ln -s /usr/local/lib/libmcrypt.* /usr/lib64/

	cd ${PACKAGE_PATH}/mhash-0.9.2
	./configure && make && make install
	ln -s /usr/local/lib/libmhash* /usr/lib64/

	cd ${PACKAGE_PATH}/mcrypt-2.6.4
	./configure && make && make install

	cd ${PACKAGE_PATH}/php-5.4.33
	PHP_TYPE_CONF
	rm -f /etc/php.ini && cp ${PACKAGE_PATH}/php-5.4.33/php.ini-production /etc/php.ini
	if [ "$PHP_HOME" = "" ]; then
		ln -s /etc/php.ini /usr/local/php/etc/php.ini
	else
		ln -s /etc/php.ini ${PHP_HOME}/etc/php.ini
	fi
	sed -i 's/post_max_size = 8M/post_max_size = 10M/g' /etc/php.ini
	sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' /etc/php.ini
	sed -i 's/;date.timezone =/date.timezone = PRC/g' /etc/php.ini
	sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php.ini
	sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini
	sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /etc/php.ini
	sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php.ini
    #sed -i 's/DirectoryIndex/DirectoryIndex index.php index.html/g' /etc/httpd/httpd.conf
	#添加ZO模块
	cd $PACKAGE_PATH
	if [ "$PHP_HOME" = "" ]; then
		cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so /usr/local/php/
		echo "[Zend Guard]
zend_extension=/usr/local/php/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path= ">> /etc/php.ini
		ln -s /usr/local/php/bin/* /usr/local/bin/ &> /dev/null
		ln -s /usr/local/php/sbin/* /usr/local/sbin/* &> /dev/null
	else
		cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so $PHP_HOME
		echo "[Zend Guard]
zend_extension=${PHP_HOME}/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path= ">> /etc/php.ini
		ln -s ${PHP_HOME}/bin/* /usr/local/bin/ &> /dev/null
		ln -s ${PHP_HOME}/sbin/* /usr/local/sbin/ &> /dev/null
	fi
fi
