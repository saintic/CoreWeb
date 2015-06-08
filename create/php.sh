#!/bin/bash
if [ $# -gt 2 ] || [ $# -eq 0 ]; then
cat<<EOF
$0 args:
  No.1:httpd or nginx
  No.2:If the first parameter is nginx, please enter a php-fpm user.
EOF
fi
if [ "$1" == "httpd" ]; then
  :
elif [ "$1" == "nginx" ]; then
  grep "$2" /etc/passwd &>/dev/null || useradd -M -s /sbin/nologin $2
fi
. ./functions
CREATE_PHP
