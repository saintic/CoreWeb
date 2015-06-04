#!/bin/bash
#Author:www.saintic.com
#Notes:转载请注明出处！
ROOT_INSTALL=$(cd `dirname $0`; pwd)
. ${ROOT_INSTALL}/../functions
clear

function GET() {
read -p "请输入MySQL安装根目录:" MYSQL_HOME
read -p "请输入Web服务器类型,Apache为A/a,Nginx为N/n:" WEB_TYPE
	if [ "$WEB_TYPE" = "A" ] || [ "$WEB_TYPE" = "a" ]; then
		read -p "请输入Apache安装根目录:" APACHE_HOME
	else
		read -p "请输入Nginx程序用户:" NGINX_USER
	fi
}

echo "安装PHP请先确保安装了WEB、DB服务器，仅允许本地安装的Apache/Nginx+MySQL!"
GET
read -p "请输入您希望的PHP安装根目录,默认/usr/local/php/请按Enter回车,否则请输入具体目录:" PHP_HOME
	if [ "$PHP_HOME" = "" ]; then
		PHP_HOME="/usr/local/php"
	fi
echo "PHP根目录位于$PHP_HOME,配置文件是/etc/php.ini，链接到${PHP_HOME}/etc/php.ini"
echo "----------------------------------------------------------------------------"

function PHP_TYPE_CONF() {
	if [ "$WEB_TYPE" = "A" ] || [ "$WEB_TYPE" = "a" ]; then
		./configure --prefix=$PHP_HOME --with-config-file-path=/etc --with-apxs2=${APACHE_HOME}/bin/apxs  --with-mysql=$MYSQL_HOME --with-mysqli=${MYSQL_HOME}/bin/mysql_config --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --enable-inline-optimization --with-curl --enable-mbstring --with-mhash --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --enable-sockets --with-pdo-mysql --enable-pdo --enable-zip --enable-soap --enable-ftp --enable-shmop --with-bz2 --enable-exif --with-gettext
		make
make test <<EOF
n
EOF
		make install
		local LINE1=$(sed -i '/DirectoryIndex/ d' /etc/httpd/httpd.conf | grep -n -s -A 1 "IfModule dir_module" /etc/httpd/httpd.conf | grep ":" | awk -F : '{print $1}')
		sed -i "${LINE1}a DirectoryIndex index.html index.php" /etc/httpd/httpd.conf
		local LINE2=$(grep -n "<IfModule mime_module>" /etc/httpd/httpd.conf | grep ":" | awk -F : '{print $1}')
		sed -i "${LINE2}a AddType application/x-httpd-php .php" /etc/httpd/httpd.conf
	else
		./configure --prefix=$PHP_HOME --with-config-file-path=/etc --enable-fpm --with-mysql=$MYSQL_HOME --with-mysqli=${MYSQL_HOME}/bin/mysql_config --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --enable-inline-optimization --with-curl --enable-mbstring --with-mhash --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --enable-sockets --with-pdo-mysql --enable-pdo --enable-zip --enable-soap --enable-ftp  --enable-shmop --with-bz2 --enable-exif --with-gettext
		make
make test <<EOF
n
EOF
		make install
		cd ${PHP_HOME}/etc ; cp php-fpm.conf.default php-fpm.conf
		sed -i "s@^pm.max_children.*@pm.max_children = $(($MEM/2/20))@" php-fpm.conf
		sed -i "s@^pm.start_servers.*@pm.start_servers = $(($MEM/2/30))@" php-fpm.conf
		sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($MEM/2/40))@" php-fpm.conf
		sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($MEM/2/20))@" php-fpm.conf
		sed -i "s/user = nobody/user = $NGINX_USER/g" php-fpm.conf
		sed -i "s/group = nobody/group = $NGINX_USER/g" php-fpm.conf
		sed -i 's#;pid = run\/php-fpm.pid#pid = run/php-fpm.pid#' php-fpm.conf
	fi
}

HEAD
if [ $? = "0" ]; then
    cd $PACKAGE_PATH ; DOWNLOAD_PHP
    yum -y install unzip ; unzip php.zip
	yum -y remove php ; yum -y install bzip2 gzip libxml2-devel libtool pcre-devel ncurses-devel bison-devel gcc-c++ gcc make cmake expat-devel zlib-devel gd-devel libcurl-devel bzip2-devel readline-devel libedit-devel perl neon-devel openssl-devel cyrus-sasl-devel php-mbstring php-bcmath gettext-devel curl-devel libjpeg-devel libpng-devel
	tar zxf libmcrypt-2.5.7.tar.gz
	tar zxf mhash-0.9.2.tar.gz
	tar zxf mcrypt-2.6.4.tar.gz 
	tar jxf php-5.4.33.tar.bz2

	#x86_64,需要在index.sh重定义32Bit System.
	tar zxf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz    

	if [ "$ARCH" = "x86_64" ]; then
		ln -s /usr/lib64/libjpeg.so /usr/lib/libjpeg.so &> /dev/null
		ln -s /usr/lib64/libpng.so /usr/lib/libpng.so &> /dev/null
		ln -s /usr/lib64/libldap* /usr/lib/ &> /dev/null
	fi

	cd ${PACKAGE_PATH}/libmcrypt-2.5.7
	./configure && make && make install
	ln -s /usr/local/lib/libmcrypt.* /usr/lib64/

	cd ${PACKAGE_PATH}/mhash-0.9.2
	./configure && make && make install
	ln -s /usr/local/lib/libmhash* /usr/lib64/

	cd ${PACKAGE_PATH}/mcrypt-2.6.4
	./configure && make && make install

	cd ${PACKAGE_PATH}/php-5.4.33
	PHP_TYPE_CONF ; cp -f ${PACKAGE_PATH}/php-5.4.33/php.ini-production /etc/php.ini
	ln -s /etc/php.ini ${PHP_HOME}/etc/php.ini
   
    init_fpm="${PACKAGE_PATH}/php-5.4.33/sapi/fpm/init.d.php-fpm"
	[ -f $init_fpm ] && cp $init_fpm /etc/init.d/php-fpm && chmod +x /etc/init.d/php-fpm && chkconfig --add php-fpm && chkconfig php-fpm on

	sed -i 's/post_max_size = 8M/post_max_size = 10M/g' /etc/php.ini
	sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' /etc/php.ini
	sed -i 's/;date.timezone =/date.timezone = PRC/g' /etc/php.ini
	sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php.ini
	sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini
	sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /etc/php.ini
	sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php.ini

	cd $PACKAGE_PATH ; cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so $PHP_HOME
cat >> /etc/php.ini <<EOF
[Zend Guard]
zend_extension=${PHP_HOME}/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=
EOF
echo "export PATH=$PATH:$PHP_HOME/bin:$PHP_HOME/sbin" >> /etc/profile
fi