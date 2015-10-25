#!/bin/bash
#Author:www.saintic.com
#Notes:转载请注明出处！

ROOT_INSTALL=$(cd `dirname $0`; pwd)
. ${ROOT_INSTALL}/../functions
clear

setpasswd() {
	read -s -p "请输入密码：" ROOT_PASSWD_1
	echo
	read -s -p "请再次输入：" ROOT_PASSWD_2
	echo
}

dispasswd() {
	read -p "请输入密码：" ROOT_PASSWD_1
	read -p "请再次输入：" ROOT_PASSWD_2
}

changePASSWD() {
setpasswd
if [ "$ROOT_PASSWD_1" != "$ROOT_PASSWD_2" ]; then
    echo -e "\033[31m密码不匹配，请重试！\033[0m"
	dispasswd
fi
ROOT_PASSWD=${ROOT_PASSWD_1}
}

CMAKE() {
	if [ "$INNODB_YN" = "" ]; then
		cmake -DCMAKE_INSTALL_PREFIX=$MYSQL_HOME -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=all  -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_DATADIR=${MYSQL_HOME}/data/ -DMYSQL_USER=mysql -DMYSQL_TCP_PORT=3306
		make && make install
	else
		cmake -DCMAKE_INSTALL_PREFIX=$MYSQL_HOME -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=all  -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_DATADIR=${MYSQL_HOME}/data/ -DMYSQL_USER=mysql -DMYSQL_TCP_PORT=3306
		make && make install
	fi
}

CONFIGURE() {
	cp -f support-files/my-medium.cnf /etc/my.cnf 
	chown -R mysql:mysql $MYSQL_HOME ; chown -R mysql.mysql ${MYSQL_HOME}/data
	${MYSQL_HOME}/scripts/mysql_install_db --basedir=$MYSQL_HOME --datadir=${MYSQL_HOME}/data --user=mysql
	cp ${MYSQL_HOME}/support-files/mysql.server /etc/init.d/mysqld
	chkconfig --add mysqld ; chkconfig mysqld on
	sed -i '26a bind-address=127.0.0.1' /etc/my.cnf
	/etc/init.d/mysqld start && exit 0 || exit 1
}

echo -e "\033[31m默认选项请回车！\033[0m"
read -p "请输入数据库安装根目录，默认是/usr/local/mysql:" MYSQL_HOME
read -p "若需要InnoDB请输入y/Y，默认关闭:" INNODB_YN
read -p "是否要更改MySQL管理员root密码，默认为空！(y/n)" CH_PASS_YN
if [ "$CH_PASS_YN" = "y" ] || [ "$CH_PASS_YN" = "Y" ]; then
	changePASSWD
fi

if [ "$MYSQL_HOME" = "" ]; then
	MYSQL_HOME=/usr/local/mysql
else
	MYSQL_HOME=$MYSQL_HOME
fi

HEAD && DOWNLOAD_MYSQL || exit 1
yum -y remove mysql-server
yum -y install gcc gcc-c++ cmake ncurses-devel gzip bzip2 mysql tar
grep "mysql" /etc/passwd && echo "已存在mysql用户,脚本将退出,请删除此用户,参考命令:userdel mysql" || useradd -M -s /sbin/nologin -u 27 mysql
cd $PACKAGE_PATH ; tar zxf mysql-5.5.20.tar.gz ; cd mysql-5.5.20
CMAKE && CONFIGURE

cat >> /etc/profile <<EOF
export PATH=\$PATH:${MYSQL_HOME}/bin
EOF
source /etc/profile

if [ "$CH_PASS_YN" = "y" ] || [ "$CH_PASS_YN" = "Y" ]; then
    mysqladmin -u root password ${ROOT_PASSWD}
fi


