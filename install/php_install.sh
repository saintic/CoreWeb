#!/bin/bash
#Author:www.saintic.com
#Notes:转载请注明出处！
ROOT_INSTALL=$(cd `dirname $0`; pwd)
. ${ROOT_INSTALL}/../functions

clear
echo "安装PHP请先确保安装了WEB、DB服务器，建议是本地安装Apache/Nginx+MySQL!"
read -p "请输入MySQL安装根目录:" MYSQL_HOME
read -p "请输入Web服务器类型,Apache为A/a,Nginx为N/n:" WEB_TYPE
	if [ "$WEB_TYPE" = "A" ] || [ "$WEB_TYPE" = "a" ]; then
		read -p "请输入Apache安装根目录:" APACHE_HOME
	else
		read -p "请输入Nginx安装根目录:" NGINX_HOME
		read -p "请输入Nginx程序用户:" NGINX_USER
		read -p "请输入Nginx程序组:" NGINX_GROUP
	fi
read -p "请输入您希望的PHP安装根目录,默认/usr/local/php/请按Enter回车,否则请输入具体目录:" PHP_HOME
	if [ "$PHP_HOME" = "" ]; then
		PHP_HOME=/usr/local/php
		echo "PHP根目录位于$PHP_HOME,配置文件是/etc/php.ini"
	else
		echo "PHP根目录位于$PHP_HOME,配置文件是/etc/php.ini"
	fi
echo "------------------------------------------------------------"

function PHP_FPM() {
	cp php-fpm.conf.default php-fpm.conf
	sed -i "s/user = nobody/user = ${NGINX_USER}/g" php-fpm.conf
	sed -i "s/group = nobody/group = ${NGINX_GROUP}/g" php-fpm.conf
}

function PHP_TYPE_CONF() {
	if [ "$WEB_TYPE" = "A" ] || [ "$WEB_TYPE" = "a" ]; then
		./configure --prefix=$PHP_HOME --with-config-file-path=/etc --with-apxs2=${APACHE_HOME}/bin/apxs  --with-mysql=$MYSQL_HOME --with-mysqli=${MYSQL_HOME}/bin/mysql_config --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --enable-inline-optimization --with-curl --enable-mbstring --with-mhash --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --enable-sockets --with-pdo-mysql --enable-pdo --enable-zip --enable-soap --enable-ftp  --enable-shmop --with-bz2 --enable-exif --with-gettext
		make
make test <<EOF
n
EOF
		make install
	else
		./configure --prefix=$PHP_HOME --with-config-file-path=/etc --enable-fpm --with-mysql=$MYSQL_HOME --with-mysqli=${MYSQL_HOME}/bin/mysql_config --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --enable-inline-optimization --with-curl --enable-mbstring --with-mhash --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --enable-sockets --with-pdo-mysql --enable-pdo --enable-zip --enable-soap --enable-ftp  --enable-shmop --with-bz2 --enable-exif --with-gettext
		make
make test <<EOF
n
EOF
		make install
		cd ${PHP_HOME}/etc/
		PHP_FPM
	fi
}

HEAD
if [ $? = "0" ] && [ $ARCH = "x86_64" ]; then
    cd $PACKAGE_PATH
	DOWNLOAD_PHP
	yum -y install unzip ; unzip php.zip
	yum -y remove php ; yum -y install bzip2 gzip libxml2-devel libtool pcre-devel ncurses-devel bison-devel gcc-c++ gcc make cmake expat-devel zlib-devel gd-devel libcurl-devel bzip2-devel readline-devel libedit-devel perl neon-devel openssl-devel cyrus-sasl-devel php-mbstring php-bcmath gettext-devel curl-devel libjpeg-devel libpng-devel
	tar zxf libmcrypt-2.5.7.tar.gz
	tar zxf mhash-0.9.2.tar.gz
	tar zxf mcrypt-2.6.4.tar.gz 
	tar jxf php-5.4.33.tar.bz2
	tar zxf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz    #x86_64,需要在index.sh重定义32Bit System.

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
	cp -f ${PACKAGE_PATH}/php-5.4.33/php.ini-production /etc/php.ini
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
	cd $PACKAGE_PATH
	cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so $PHP_HOME
cat >> /etc/php.ini<<EOF
[Zend Guard]
zend_extension=${PHP_HOME}/ZendGuardLoader.so
zend_loader.enable=1
EOF

cat >> /etc/profile<<EOF
export PATH=$PATH:${PHP_HOME}/bin/
export PATH=$PATH:${PHP_HOME}/sbin/
EOF

fi