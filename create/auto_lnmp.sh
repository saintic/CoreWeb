#!/bin/bash
#set -x 
#yum安装LNMP环境

#centos6不兼容，调整资料
#http://nginx.org/en/linux_packages.html
#https://webtatic.com/packages/php56/
exit 1

groupadd www
useradd www  -s /sbin/nologin -g www
mkdir -p  /home/wwwroot/xingka/starspot/base.starokay.cn/branch
mkdir -p  /home/wwwlogs/
chown -R  www.www /home/wwwlogs/
chown -R  www.www /home/wwwroot/xingka/starspot

yum install -y vim  gcc gcc-c++  zlib zlib-devel openssl openssl-devel pcre pcre-devel libxml2-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

if  ! ps -ef | grep yum| grep -v "grep";then
	rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	sleep 5
	rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
	sleep 5
	yum clean all && yum  install -y  php56w php56w-opcache  && yum install -y  --skip-broken  php56w* 
fi


mkdir -p  /home/starspot/softwares && cd /home/starspot/softwares 

yum install -y  git  &&  wget http://pecl.php.net/get/yaf-2.3.3.tgz && tar -zxvf yaf-2.3.3* && cd yaf-2.3.3  && phpize

./configure --with-php-config=/usr/bin/php-config && make  &&  make install


sed -i '$ r /home/auto_lnmp_sh/yaf.txt' /etc/php.ini 


service php-fpm restart && sleep 5
 
yes | pecl install   channel://pecl.php.net/msgpack-0.5.7


sed -i '/extension_dir = "ext"/a\extension=msgpack.so'   /etc/php.ini  &&   service php-fpm restart 
yum -y install curl-devel

yes | pecl install   yar 
sed  -i '/extension=msgpack.so/a\extension=yar.so'  /etc/php.ini

mv /etc/php.d/json.ini /etc/php.d/json.ini.bak

sed -i '/extension_dir = "ext"/a\extension=json.so'  /etc/php.ini

sed -i 's/listen = 127.0.0.1:9000/listen=\/dev\/shm\/php-fpm.sock/' /etc/php-fpm.d/www.conf
sed -i 's/user = apache/user = www/' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = www/' /etc/php-fpm.d/www.conf
sed -i 's/;listen.owner = nobody/listen.owner = www/' /etc/php-fpm.d/www.conf
sed -i 's/;listen.group = nobody/listen.group = www/' /etc/php-fpm.d/www.conf
sed -i 's/pm.max_children = 50/pm.max_children = 200/' /etc/php-fpm.d/www.conf

chown -R www.www /var/lib/php/session
chmod -R 777 /var/lib/php/session

service php-fpm restart

yum install -y  http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
sleep 3

yum install -y nginx

until `which nginx`
do 
	yum install -y nginx
done

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
cp /home/nginx.conf.tmpl /etc/nginx/nginx.conf
service nginx start
echo 
echo
#sed -i '2s/nginx/www www/'   /etc/nginx/nginx.conf
cp -pr /home/conf/enable_php.conf /etc/nginx
cp -pr /home/conf/{admin.starokay.cn.conf,base.starokay.cn.conf,mfrs.starokay.cn.conf,m.starokay.cn.conf} /etc/nginx/conf.d/

#向最后一行下面添加内容
#sed -i '$a\要写入的内容' /etc/hosts

php -m
which nginx

echo -e "End。\n************************************************Thanks!**********************************************************************"
