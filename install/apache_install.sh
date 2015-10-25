#!/bin/bash
#Author:www.saintic.com
#Notes:转载请注明出处！

ROOT_INSTALL=$(cd `dirname $0`; pwd)
. ${ROOT_INSTALL}/../functions

clear
read -p "请输入Apache HTTP Server根目录，回车默认是/usr/local/apache:" APACHE_HOME
read -p "请输入网站域名，回车默认是系统主机名：" APACHE_DN
read -p "请输入管理员邮箱：" APACHE_EMAIL
if [ "$APACHE_HOME" = "" ]; then
	APACHE_HOME=/usr/local/apache
fi
echo -e "\033[31mApache根目录位于$APACHE_HOME,配置文件是/etc/httpd/httpd.conf\033[0m"

HEAD && DOWNLOAD_APACHE || exit 1

yum -y install bzip2 gzip unzip libtool pcre-devel gcc-c++ gcc cmake expat-devel zlib-devel neon-devel openssl-devel cyrus-sasl-devel tar
cd $PACKAGE_PATH ; unzip Apache.zip
tar zxf apr-1.2.12.tar.gz
tar zxf apr-util-1.2.12.tar.gz
tar zxf httpd-2.2.29.tar.gz

#1.Apr,Apr-util	
cd ${PACKAGE_PATH}/apr-1.2.12
./configure --enable-shared && make && make install
cd $PACKAGE_PATH/apr-util-1.2.12
./configure --enable-shared --with-expat=builtin --with-apr=/usr/local/apr/ && make && make install
#2.Apache
cd $PACKAGE_PATH/httpd-2.2.29
./configure  --prefix=$APACHE_HOME --sysconfdir=/etc/httpd --enable-mods-shared=most --enable-modules=most --enable-so --enable-rewrite=shared --enable-ssl=shared --with-ssl --enable-cgi --enable-dav --with-included-apr   --with-apr=/usr/local/apr/bin/apr-1-config --with-apr-util=/usr/local/apr/bin/apu-1-config --enable-static-support --enable-charset-lite
make && make install
cp ${APACHE_HOME}/bin/apachectl /etc/init.d/httpd 
cat >> /etc/init.d/httpd <<EOF
#chkconfig:35 13 52
#description:Apache HTTP Server
EOF
chmod +x /etc/init.d/httpd
chkconfig --add httpd && chkconfig httpd on

sed -i "s/ServerAdmin you@example.com/ServerAdmin ${APACHE_EMAIL}/" /etc/httpd/httpd.conf
if [ "$APACHE_DN" = "" ]; then
	sed -i "146a ServerName $HOSTNAME" /etc/httpd/httpd.conf
else
	sed -i "s/#ServerName www.example.com:80/ServerName ${APACHE_DN}/g" /etc/httpd/httpd.conf
fi

cat >> /etc/profile <<EOF
export PATH=$PATH:${APACHE_HOME}/bin
EOF
source /etc/profile

ln -s ${APACHE_HOME}/bin/* /usr/local/bin/
apachectl -t &> /dev/null && service httpd start || apachectl -t && exit 1

iptables -I INPUT -p tcp --dport 80 -j ACCEPT
service iptables save

apachectl -t &> /dev/null && echo $? &> /dev/null
if [ $? = "0" ]
	then
	echo "Apache搭建完毕!请注意防火墙!"
	else
	echo "Apache部署出错!"
fi

if [ "$SESTATE" = "1" ]; then
	:
else
	read -p "为保证SELinux正常关闭,请输入Y/y键重启系统,否则输入N/n:" YN
    if [ "$YN" = "Y" ] || [ "$YN" = "y" ]; then
    	reboot
    else
    	setenforcing 1 ; exit 1
    fi
fi
