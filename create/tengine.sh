#/bin/bash
clear
TENGINE_VERSION=2.1.1
PACKAGE_PATH="/data/software"
APP_PATH="/data/app"
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

CREATE_TENGINE() {
id -u www &> /dev/null || useradd -M -s /sbin/nologin www
[ -d $PACKAGE_PATH/tengine-$tengine_VERSION ] && rm -rf $PACKAGE_PATH/tengine-$tengine_VERSION
yum -y install tar bzip2 gzip pcre pcre-devel gcc gcc-c++ zlib-devel wget openssl-devel jemalloc
cd $PACKAGE_PATH
wget -c http://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz
tar zxf tengine-${TENGINE_VERSION}.tar.gz
cd tengine-$TENGINE_VERSION
./configure --prefix=${APP_PATH}/tengine --user=www --group=www --with-jemalloc --with-poll_module  --with-http_ssl_module --with-http_gzip_static_module --with-http_stub_status_module --with-http_realip_module --with-pcre && make && make install
${APP_PATH}/tengine/sbin/nginx -t &> /dev/null
ln -s ${APP_PATH}/tengine/sbin/nginx /usr/sbin/nginx
if [ $? -eq 0 ]; then
  echo "Start:/usr/sbin/nginx" ; /usr/sbin/tengine
  echo "/usr/sbin/nginx" >> /etc/rc.local
else
  echo "Please check nginx.conf" && exit
fi
}

HEAD && CREATE_TENGINE || echo "HEAD function is wrong, quit."
if [ `ps aux | grep -v grep | grep tengine |wc -l` -ge 1 ]; then
  echo "Start Successful."
else
  echo "tengine haven't finished."
fi
