#!/bin/bash
#Author:saintic.com
clear
PACKAGE_PATH="/data/software"
APP_PATH="/data/app"
lock="/var/lock/subsys/paas.sdi.lock"

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

CREATE_MEMCACHE() {
yum -y install wget tar gzip bzip2 zlib zlib-devel gcc gcc-c++ openssl-devel json json-devel
if [ -f $PACKAGE_PATH/libevent-2.0.22-stable.tar.gz ] || [ -d $PACKAGE_PATH/libevent-2.0.22-stable ] ; then
  rm -rf $PACKAGE_PATH/libevent-2.0.22-stable
fi
#libevent
cd $PACKAGE_PATH ; wget -c http://jaist.dl.sourceforge.net/project/levent/libevent/libevent-2.0/libevent-2.0.22-stable.tar.gz
[ "$?" -ne 0 ] && wget -c https://codeload.github.com/libevent/libevent/tar.gz/release-2.0.22-stable && mv release-2.0.22-stable libevent-2.0.22-stable.tar.gz
tar zxf libevent-2.0.22-stable.tar.gz ; cd libevent-2.0.22-stable
./configure --prefix=/usr/ && make && make install
#memcache
if [ -f $PACKAGE_PATH/memcached-1.4.24.tar.gz ] || [ -d $PACKAGE_PATH/memcached-1.4.24 ] ; then
  rm -rf $PACKAGE_PATH/memcached-1.4.24*
fi
cd $PACKAGE_PATH ;  wget -c  http://memcached.org/files/memcached-1.4.24.tar.gz
tar zxf memcached-1.4.24.tar.gz ; cd memcached-1.4.24
./configure --with-libevent=/usr && make && make install
}

api() {
local memcache_api_version=2.2.7
cd $PACKAGE_PATH ; wget -c http://pecl.php.net/get/memcache-${memcache_api_version}.tgz
tar zxf memcache-${memcache_api_version}.tgz ; cd memcache-$memcache_api_version
${APP_PATH}/php/bin/phpize
./configure --enable-memcache --with-php-config=${APP_PATH}/php/bin/php-config --with-zlib-dir
make
make test <<EOF
n
EOF
make install > /tmp/memcache-api
local EXT3=$(tail -1 /tmp/memcache-api | awk -F: '{print $2}' | awk '{print $1}')
echo "extension=${EXT3}memcache.so" >> ${APP_PATH}/php/etc/php.ini
}

memcache() {
CREATE_MEMCACHE
#api
}

HEAD && memcache || ERROR

