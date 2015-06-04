#!/bin/bash
v=1.8.0
nginx=/usr/local/nginx
pid=${nginx}/logs/nginx.pid
pidbin=${nginx}/logs/nginx.pid.oldbin
exec=`which nginx`
[ "$?" = "0" ] || exit 1
$exec -V &> /tmp/nginx_V
args=$(awk -F "configure arguments:" '{print $2}' /tmp/nginx_V | grep -v "^$")
echo 'If your nginx has third party modules, that is, use the "--add-module" parameter, move the module directory to the same location as the current nginx build!'
read -p "Continue yes?(y/n)" NEXT
[ "$NEXT" = "n" ] && exit 1 || echo Continue Yes!
wget -c http://nginx.org/download/nginx-$v.tar.gz
[ -f nginx-$v.tar.gz ] || exit 1 && echo "No version."
tar zxf nginx-$v.tar.gz
cd nginx-$v
./configure $args
make
mv $exec /tmp
cp objs/nginx $exec

kill  -USR2 `cat $pid`
kill  -WINCH `cat $pidbin`
kill  -HUP `cat $pidbin`
kill  -QUIT `cat $pidbin`

s() {
  echo "Update Successed." && $exec -v
  [ -x /tmp/nginx ] && rm -f /tmp/nginx
}
f() {
  echo "Update failed."
  mv /tmp/nginx $exec && echo "Has rolled back."
}

$exec -v &> /dev/null && s || f
