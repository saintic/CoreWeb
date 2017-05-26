#!/bin/bash
#set -x 
#yum安装LNMP环境

#centos6不兼容，调整资料
#http://nginx.org/en/linux_packages.html
#https://webtatic.com/packages/php56/

groupadd www
useradd www  -s /sbin/nologin -g www
#mkdir -p  /home/wwwroot/xingka/starspot/base.starokay.cn/branch
mkdir -p  /home/wwwlogs/
mkdir -p  /home/wwwroot/
chown -R  www.www /home/wwwlogs/
chown -R  www.www /home/wwwroot/

yum install -y vim  gcc gcc-c++  zlib zlib-devel openssl openssl-devel pcre pcre-devel libxml2-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel mysql-devel mysql curl-devel

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


#sed -i '$ r /home/auto_lnmp_sh/yaf.txt' /etc/php.ini 
cat >> /etc/php.ini <<EOF

[yaf]
yaf.environ = product
yaf.library = NULL
yaf.cache_config = 0
yaf.name_suffix = 1
yaf.name_separator = ""
yaf.forward_limit = 5
yaf.use_namespace = 1
yaf.use_spl_autoload = 0
extension=yaf.so
EOF

#systemctl restart php-fpm && sleep 5
 
yes | pecl install   channel://pecl.php.net/msgpack-0.5.7
sed -i '/extension_dir = "ext"/a\extension=msgpack.so'   /etc/php.ini

yes | pecl install   yar 
sed  -i '/extension=msgpack.so/a\extension=yar.so'  /etc/php.ini

mv /etc/php.d/json.ini /etc/php.d/json.ini.bak
sed -i '/extension_dir = "ext"/a\extension=json.so'  /etc/php.ini
sed -i 's/^upload_max_filesize.*/upload_max_filesize = 10M/' /etc/php.ini

sed -i 's/listen = 127.0.0.1:9000/listen=\/dev\/shm\/php-fpm.sock/' /etc/php-fpm.d/www.conf
sed -i 's/user = apache/user = www/' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = www/' /etc/php-fpm.d/www.conf
sed -i 's/;listen.owner = nobody/listen.owner = www/' /etc/php-fpm.d/www.conf
sed -i 's/;listen.group = nobody/listen.group = www/' /etc/php-fpm.d/www.conf
sed -i 's/pm.max_children = 50/pm.max_children = 300/' /etc/php-fpm.d/www.conf
sed -i 's#;pm.status_path.*#pm.status_path = /xingka_status#' /etc/php-fpm.d/www.conf

chown -R www.www /var/lib/php/session
chmod -R 777 /var/lib/php/session

#service php-fpm restart

yum install -y  http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
sleep 1

yum install -y nginx

until `which nginx`
do 
	yum install -y nginx
done

#mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
#cp /home/nginx.conf.tmpl /etc/nginx/nginx.conf
cat >> /etc/nginx/nginx.conf <<'EOF'
user  www www;
worker_processes  4;

error_log   /var/log/nginx/error.log warn;
pid         /var/run/nginx.pid;

#Specifies the value for maximum file descriptors that can be opened by this process.
worker_rlimit_nofile 65535;

events
{
  use epoll;
  worker_connections 65535;
}

http {

        include       /etc/nginx/mime.types;
        default_type  application/octet-stream;

        #charset  gb2312;

        server_names_hash_bucket_size 128;
        client_header_buffer_size 32k;
        large_client_header_buffers 4 32k;
        client_max_body_size 8m;

        sendfile on;
        tcp_nopush     on;

        keepalive_timeout 60;

        tcp_nodelay on;

        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        fastcgi_buffer_size 64k;
        fastcgi_buffers 4 64k;
        fastcgi_busy_buffers_size 128k;
        fastcgi_temp_file_write_size 128k;

        gzip on;
        gzip_min_length  1k;
        gzip_buffers     4 16k;
        gzip_http_version 1.0;
        gzip_comp_level 2;
        gzip_types       text/plain application/x-javascript text/css application/xml;
        gzip_vary on;
        #limit_zone  crawler  $binary_remote_addr  10m;
                                                                                                         

       log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                         '$status $body_bytes_sent "$http_referer" '
                         '"$http_user_agent" "$http_x_forwarded_for"';
       access_log  /var/log/nginx/access.log  main;

       include /etc/nginx/conf.d/*.conf;
}
EOF
#service nginx start
echo 
echo
#sed -i '2s/nginx/www www/'   /etc/nginx/nginx.conf
#cp -pr /home/conf/enable_php.conf /etc/nginx
#cp -pr /home/conf/{admin.starokay.cn.conf,base.starokay.cn.conf,mfrs.starokay.cn.conf,m.starokay.cn.conf} /etc/nginx/conf.d/
cat >> /etc/nginx/enable_php.conf <<'EOF'
    location ~ \.php$ {
        fastcgi_pass   unix:/dev/shm/php-fpm.sock;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
EOF
#向最后一行下面添加内容
#sed -i '$a\要写入的内容' /etc/hosts

#php -m
#which nginx
systemctl start nginx   && systemctl enable nginx
systemctl start php-fpm && systemctl enable php-fpm

echo -e "End.\n************************************************Thanks!**********************************************************************"
