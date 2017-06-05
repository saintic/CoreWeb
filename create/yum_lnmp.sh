#!/bin/bash
#set -x 
#yum安装LNMP环境

#centos6不兼容，调整资料
#http://nginx.org/en/linux_packages.html
#https://webtatic.com/packages/php56/

function prework() {
    groupadd www
    useradd www  -s /sbin/nologin -g www
    mkdir -p  /home/wwwlogs/ && chown -R  www.www /home/wwwlogs/
    mkdir -p  /home/wwwroot/ && chown -R  www.www /home/wwwroot/
    yum install -y git wget vim  gcc gcc-c++  zlib zlib-devel openssl openssl-devel pcre pcre-devel libxml2-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel mysql-devel mysql curl-devel
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
}

function install_php() {
    if [ "$(uname -r | grep 2.6 | wc -l)" = "1" ]; then
        rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
        rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
    else
        rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
        rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
    fi
	yum clean all && yum  install -y  php56w php56w-opcache  && yum install -y  --skip-broken  php56w* 
}

function configure_php() {
    #安装yaf
    mkdir -p  /home/starspot/softwares && cd /home/starspot/softwares 
    wget http://pecl.php.net/get/yaf-2.3.3.tgz && tar -zxvf yaf-2.3.3* && cd yaf-2.3.3  && phpize
    ./configure --with-php-config=/usr/bin/php-config && make  &&  make install
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

    #安装msgpack yar
    yes | pecl install   channel://pecl.php.net/msgpack-0.5.7
    sed -i '/extension_dir = "ext"/a\extension=msgpack.so'   /etc/php.ini

    yes | pecl install   yar 
    sed  -i '/extension=msgpack.so/a\extension=yar.so'  /etc/php.ini

    #配置php.ini 和 php-fpm
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
}


function install_nginx() {
    if [ "$(uname -r | grep 2.6 | wc -l)" = "1" ]; then
        yum install -y  http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
    else
        yum install -y  http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
    fi

    yum install -y nginx
    until `which nginx`
    do 
	    yum install -y nginx
    done

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
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

#cp -pr /home/conf/enable_php.conf /etc/nginx
#cp -pr /home/conf/{admin.starokay.cn.conf,base.starokay.cn.conf,mfrs.starokay.cn.conf,m.starokay.cn.conf} /etc/nginx/conf.d/
cat > /etc/nginx/enable_php.conf <<'EOF'
    location ~ \.php$ {
        fastcgi_pass   unix:/dev/shm/php-fpm.sock;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
EOF
}

function install_mysql() {
cat > /etc/yum.repos.d/mysql-community.repo <<'EOF'
[mysql-connectors-community]
name=MySQL Connectors Community
baseurl=http://repo.mysql.com/yum/mysql-connectors-community/el/6/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql-tools-community]
name=MySQL Tools Community
baseurl=http://repo.mysql.com/yum/mysql-tools-community/el/6/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

# Enable to use MySQL 5.5
[mysql55-community]
name=MySQL 5.5 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.5-community/el/6/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

# Enable to use MySQL 5.6
[mysql56-community]
name=MySQL 5.6 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/6/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

# Note: MySQL 5.7 is currently in development. For use at your own risk.
# Please read with sub pages: https://dev.mysql.com/doc/relnotes/mysql/5.7/en/
[mysql57-community-dmr]
name=MySQL 5.7 Community Server Development Milestone Release
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/6/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
EOF

cat > /etc/yum.repos.d/mysql-community-source.repo <<'EOF'
[mysql-connectors-community-source]
name=MySQL Connectors Community - Source
baseurl=http://repo.mysql.com/yum/mysql-connectors-community/el/6/SRPMS
enabled=0
gpgcheck=1
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql-tools-community-source]
name=MySQL Tools Community - Source
baseurl=http://repo.mysql.com/yum/mysql-tools-community/el/6/SRPMS
enabled=0
gpgcheck=1
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql55-community-source]
name=MySQL 5.5 Community Server - Source
baseurl=http://repo.mysql.com/yum/mysql-5.5-community/el/6/SRPMS
enabled=0
gpgcheck=1
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql56-community-source]
name=MySQL 5.6 Community Server - Source
baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/6/SRPMS
enabled=0
gpgcheck=1
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql57-community-dmr-source]
name=MySQL 5.7 Community Server Development Milestone Release - Source
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/6/SRPMS
enabled=0
gpgcheck=1
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
EOF

cat > /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql <<'EOF'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: PGP Universal 2.9.1 (Build 347)

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
=Eto8
-----END PGP PUBLIC KEY BLOCK-----
EOF

yum clean all && yum -y install mysql-community-server mysql-community-devel mysql-community-libs mysql-community-client mysql-community-common
sed -i '/\[mysqld\]/a character-set-server=utf8' /etc/my.cnf
sed -i '/\[mysqld\]/a collation-server=utf8_general_ci' /etc/my.cnf
cat >> /etc/my.cnf << 'EOF'
[client]
default-character-set=utf8
EOF
}

function postwork() {
    systemctl start nginx   && systemctl enable nginx
    systemctl start php-fpm && systemctl enable php-fpm
    systemctl start mysqld  && systemctl enable mysqld
}

prework
install_php
configure_php
install_nginx
install_mysql
postwork
echo -e "End.\n************************************************Thanks!**********************************************************************"
