#!/bin/bash
#lanmp
#author:saintic.com

NGINX_VERSION=1.8.0
HTTPD_VERSION=2.2.29
MYSQL_VERSION=5.5.20
PHP_VERSION=5.6.2
PACKAGE_PATH="/data/software"
APP_PATH="/data/app"
lock="/var/lock/subsys/paas.sdi.lock"
CPU=$(grep "processor" /proc/cpuinfo | wc -l)
MEM=$(free -m | awk '/Mem:/{print $2}')
clear
cat<<EOF
####################################################
##           程序版本请修改functions下各参数。    ##
##              若程序出错请查看错误信息。        ##
##作者信息:                                       ##
##    Author:   SaintIC                           ##
##    QQ：      1663116375                        ##
##    Phone:    18201707941                       ##
##    Design:   https://saintic.com/DIY           ##   
####################################################
EOF

function HEAD() {
  if [ $(id -u) != "0" ]; then
   	echo "Error:make sure you are root!" ; exit 1
  fi
  sestatus &> /dev/null
  if [ $? -ne 0 ]; then
    yum -y install policycoreutils
  fi
  SESTATE=$(sestatus | nl | wc -l)
  if [ "$SESTATE" != "1" ]; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
	echo "Please disable SELinux."
  fi
  [ -d $PACKAGE_PATH ] || mkdir -p $PACKAGE_PATH
  [ -d $APP_PATH ] || mkdir -p $APP_PATH
}

function ERROR() {
  echo "Error:Please check this script and input/output!"
}

CREATE_HTTP() {
yum -y install tar bzip2 gzip libtool pcre-devel gcc-c++ gcc cmake make expat-devel zlib-devel neon-devel openssl-devel cyrus-sasl-devel wget
if [ -f $PACKAGE_PATH/httpd-${HTTPD_VERSION}.tar.gz ] || [ -d $PACKAGE_PATH/httpd-$HTTPD_VERSION ] ; then
  rm -rf $PACKAGE_PATH/httpd-${HTTPD_VERSION}*
fi
cd $PACKAGE_PATH
wget -c http://software.saintic.com/core/web/Apache.zip
wget -c http://archive.apache.org/dist/httpd/httpd-${HTTPD_VERSION}.tar.gz
#1.Apr,Apr-util
tar zxf apr-1.2.12.tar.gz
tar zxf apr-util-1.2.12.tar.gz
cd ${PACKAGE_PATH}/apr-1.2.12
./configure --enable-shared && make && make install
cd $PACKAGE_PATH/apr-util-1.2.12
./configure --enable-shared --with-expat=builtin --with-apr=/usr/local/apr/ && make && make install

cd ${PACKAGE_PATH} ; tar zxf httpd-${HTTPD_VERSION}.tar.gz ; cd httpd-${HTTPD_VERSION}
./configure --prefix=${APP_PATH}/apache --sysconfdir=/etc/httpd --enable-mods-shared=most --enable-modules=most --enable-so --enable-rewrite=shared --enable-ssl=shared --with-ssl --enable-cgi --enable-dav --with-included-apr --with-apr=/usr/local/apr/bin/apr-1-config --with-apr-util=/usr/local/apr/bin/apu-1-config --enable-static-support --enable-charset-lite
make && make install
cp ${APP_PATH}/apache/bin/apachectl /etc/init.d/httpd
cat >> /etc/init.d/httpd <<EOF
#chkconfig:35 13 52
#description:Apache HTTP Server
EOF
chmod +x /etc/init.d/httpd
chkconfig --add httpd && chkconfig httpd on
sed -i "s/Listen 80/Listen 81/g" /etc/httpd/httpd.conf
sed -i "s/#ServerName www.example.com:80/ServerName www.saintic.com/g" /etc/httpd/httpd.conf
sed -i "s/ServerAdmin you@example.com/ServerAdmin admin@saintic.com/" /etc/httpd/httpd.conf
${APP_PATH}/apache/bin/apachectl -t
if [ $? -eq  ]; then
  echo -n "Start:/etc/init.d/httpd start" ;
  /etc/init.d/httpd start
else
  echo "Please check httpd.conf"
fi
}


CREATE_NGINX() {
id -u www &> /dev/null || useradd -M -s /sbin/nologin www
if [ -f $PACKAGE_PATH/nginx-${NGINX_VERSION}.tar.gz ] || [ -d $PACKAGE_PATH/nginx-$NGINX_VERSION ] ; then
  rm -rf $PACKAGE_PATH/nginx-${NGINX_VERSION}*
fi
yum -y install tar bzip2 gzip pcre pcre-devel gcc gcc-c++ zlib-devel wget openssl-devel ; cd $PACKAGE_PATH ; wget -c http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && tar zxf nginx-${NGINX_VERSION}.tar.gz && cd nginx-$NGINX_VERSION
./configure --prefix=${APP_PATH}/nginx --user=www --group=www --with-poll_module  --with-http_ssl_module --with-http_gzip_static_module --with-http_stub_status_module --with-http_realip_module --with-pcre && make && make install
${APP_PATH}/nginx/sbin/nginx -t
if [ $? -eq 0 ]; then
  echo -n "Start:${APP_PATH}/nginx/sbin/nginx" ;
  ${APP_PATH}/nginx/sbin/nginx
else
  echo "Please check nginx.conf"
fi
}


CREATE_MYSQL() {
yum -y install tar gzip bzip2 gcc gcc-c++ cmake ncurses-devel mysql wget
id -u mysql &> /dev/null || useradd -M -s /sbin/nologin mysql
if [ -f $PACKAGE_PATH/mysql-${MYSQL_VERSION}.tar.gz ] || [ -d $PACKAGE_PATH/mysql-${MYSQL_VERSION} ] ; then
  rm -rf $PACKAGE_PATH/mysql-${MYSQL_VERSION}*
fi
cd $PACKAGE_PATH ; wget -c http://down1.chinaunix.net/distfiles/mysql-${MYSQL_VERSION}.tar.gz || \
wget -c http://software.saintic.com/core/web/mysql-${MYSQL_VERSION}.tar.gz ; tar zxf mysql-${MYSQL_VERSION}.tar.gz
cd mysql-$MYSQL_VERSION
cmake -DCMAKE_INSTALL_PREFIX=${APP_PATH}/mysql -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=all  -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_DATADIR=${APP_PATH}/mysql/data/ -DMYSQL_USER=mysql -DMYSQL_UNIX_ADDR=/tmp/mysqld.sock -DMYSQL_TCP_PORT=3306 && make && make install
cp -f support-files/my-medium.cnf /etc/my.cnf 
chown -R mysql:mysql ${APP_PATH}/mysql
${APP_PATH}/mysql/scripts/mysql_install_db --basedir=${APP_PATH}/mysql --datadir=${APP_PATH}/mysql/data --user=mysql
cp ${APP_PATH}/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld ; chkconfig mysqld on
/etc/init.d/mysqld start
}

fpm() {
sed -i "s@^pm.max_children.*@pm.max_children = $(($MEM/2/20))@" php-fpm.conf
sed -i "s@^pm.start_servers.*@pm.start_servers = $(($MEM/2/30))@" php-fpm.conf
sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($MEM/2/40))@" php-fpm.conf
sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($MEM/2/20))@" php-fpm.conf
sed -i "s/user = nobody/user = ${user}/g" php-fpm.conf
sed -i "s/group = nobody/group = ${user}/g" php-fpm.conf
sed -i 's#;pid = run\/php-fpm.pid#pid = run/php-fpm.pid#' php-fpm.conf
}


CREATE_PHP() {
if [ -f $PACKAGE_PATH/php-${PHP_VERSION}.tar.gz ] || [ -d $PACKAGE_PATH/php-${PHP_VERSION} ] ; then
  rm -rf $PACKAGE_PATH/php-${PHP_VERSION}*
fi
rm -rf ${PACKAGE_PATH}/libmcrypt-*
rm -rf ${PACKAGE_PATH}/mcrypt-*
rm -rf ${PACKAGE_PATH}/mhash-*
yum -y remove php ; yum -y install tar bzip2 gzip libxml2-devel libtool pcre-devel ncurses-devel bison-devel gcc-c++ gcc make cmake expat-devel zlib-devel gd-devel libcurl-devel bzip2-devel readline-devel libedit-devel perl neon-devel openssl-devel cyrus-sasl-devel php-mbstring php-bcmath gettext-devel curl-devel libjpeg-devel libpng-devel
cd $PACKAGE_PATH ; wget -c http://mirrors.sohu.com/php/php-${PHP_VERSION}.tar.gz
wget -c https://software.saintic.com/core/web/php-lib.tar.gz || wget -c ftp://download.saintic.com/web/php-lib.tar.gz
tar zxf php-lib.tar.gz
tar zxf libmcrypt-2.5.7.tar.gz
tar zxf mhash-0.9.2.tar.gz
tar zxf mcrypt-2.6.4.tar.gz
tar zxf php-${PHP_VERSION}.tar.gz
if [ `uname -p` == "x86_64" ]; then
  ln -s /usr/lib64/libjpeg.so /usr/lib/libjpeg.so &> /dev/null
  ln -s /usr/lib64/libpng.so /usr/lib/libpng.so &> /dev/null
fi
cd ${PACKAGE_PATH}/libmcrypt-2.5.7
./configure && make && make install
ln -s /usr/local/lib/libmcrypt.* /usr/lib64/
cd ${PACKAGE_PATH}/mhash-0.9.2
./configure && make && make install
ln -s /usr/local/lib/libmhash* /usr/lib64/
cd ${PACKAGE_PATH}/mcrypt-2.6.4
./configure && make && make install
cd ${PACKAGE_PATH}/php-$PHP_VERSION
./configure --prefix=${APP_PATH}/php --with-config-file-path=${APP_PATH}/php/etc/ --with-apxs2=${APP_PATH}/apache/bin/apxs --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --enable-inline-optimization --with-curl --enable-mbstring --with-mhash --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --enable-sockets --with-pdo-mysql --enable-pdo --enable-zip --enable-soap --enable-ftp  --enable-shmop --with-bz2 --enable-exif --with-gettext --enable-fpm && make
make test <<EOF
n
EOF
make install
local LINE1=$(sed -i '/DirectoryIndex/ d' /etc/httpd/httpd.conf | grep -n -s -A 1 "IfModule dir_module" /etc/httpd/httpd.conf | grep ":" | awk -F : '{print $1}')
sed -i "${LINE1}a DirectoryIndex index.html index.php" /etc/httpd/httpd.conf
local LINE2=$(grep -n "<IfModule mime_module>" /etc/httpd/httpd.conf | grep ":" | awk -F : '{print $1}')
sed -i "${LINE2}a AddType application/x-httpd-php .php" /etc/httpd/httpd.conf
sed -i 's/DirectoryIndex/DirectoryIndex index.php index.htm/g' /etc/httpd/httpd.conf

[ -f ${APP_PATH}/php/etc/php-fpm.conf.default ] && cd ${APP_PATH}/php/etc/ && cp php-fpm.conf.default php-fpm.conf && fpm

cp -f ${PACKAGE_PATH}/php-${PHP_VERSION}/php.ini-production ${APP_PATH}/php/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 10M/g' ${APP_PATH}/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' ${APP_PATH}/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' ${APP_PATH}/php/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' ${APP_PATH}/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${APP_PATH}/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' ${APP_PATH}/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' ${APP_PATH}/php/etc/php.ini
}

LANMP() {
[ -f $lock ] && echo "Please run \"rm -f $lock\", then run again." && exit 1 || touch $lock
CREATE_HTTP
CREATE_NGINX
CREATE_MYSQL
CREATE_PHP
}

HEAD && LANMP || ERROR

if [ `ps aux | grep -v grep | grep httpd |wc -l` -ge 1 ] && [ `ps aux | grep -v grep | grep nginx |wc -l` ] && [ `ps aux | grep -v grep | grep mysqld |wc -l` ]; then
  rm -f $lock
else
  echo "LANMP haven't finished."
fi

