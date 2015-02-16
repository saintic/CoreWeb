#!/bin/bash
#Author:SaintIC
#Notes:转载请注明出处！
#My Home Page:http://www.saintic.com
#This script code num is 3.
clear
. ../functions
. ../index.sh

DOWNLOAD_MYSQL
yum remove mysql-server ; yum -y install gcc gcc-c++ cmake ncurses-devel
useradd -M -s /sbin/nologin -u 27 mysql
cd $PACKAGE_PATH ; tar zxf mysql-5.5.20.tar.gz
cd ${PACKAGE_PATH}/mysql-5.5.20
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=all  -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_DATADIR=/usr/local/mysql/data/ -DMYSQL_USER=mysql -DMYSQL_UNIX_ADDR=/tmp/mysqld.sock -DMYSQL_TCP_PORT=3306 
make && make install
cp -f support-files/my-medium.cnf /etc/my.cnf 
chown -R mysql:mysql /usr/local/mysql
/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld ; chkconfig mysqld on
/etc/init.d/mysqld start
