#!/usr/bin/python
#-*- coding:utf-8 -*-
__author__ = 'saintic.com'
__doc__ = 'This script is written for Python to initialize CoreWeb'
__version = '3.0.0'
__data__ = '2015-06-03'

import sys
import os
os.system('clear')
ROOT=sys.path[0]
os.environ['ROOT']=str(ROOT)

print '\033[0;32;40m'
print '^' * 81
print "脚本作用：引导安装或升级。请根据提示输入数字继续。"
print '更多内容请访问："https://saintic.com/"'
print '^' * 81
print "安装服务类型，格式为数字代码:服务类型"
print "  1:Nginx"
print "  2:Httpd"
print "  3:MySQL"
print "  4:PHP"
print "  5:Redis"
print "  6:MongoDB"
print "  7:LNMP"
print "  8:LAMP"
print "  9:LANMP"
print "  10:tomcat"
print "  11:memcache"
print '^' * 81
print "升级服务版本"
print "  0:update the service version!"
print '^' * 81
print "退出请输入\"q\"或\"Q\"."
print '^' * 81
print '\033[0m'

__codenum=raw_input('请选择数字代码安装或升级:')
__service_list={0:'Update Service', 1:'Nginx', 2:'Httpd', 3:'MySQL', 4:'PHP', 5:'Redis', 6:'MongoDB', 7:'LNMP', 8:'LAMP', 9:'LANMP', 10:'tomcat', 11:'memcache', 12:'memcached'}

if __codenum == "q":
    exit()
elif __codenum == "Q":
    exit()
else:
    __select=int(__codenum)
    if __select in __service_list:
        print '你的选择：',__service_list[__select]
        if __select == 0:
            os.system("sh $ROOT/update/boot.sh")
        elif __select == 1:
            os.system("sh $ROOT/create/nginx.sh")
        elif __select == 2:
            os.system("sh $ROOT/create/apache.sh")
        elif __select == 3:
            os.system("sh $ROOT/create/mysql.sh")
        elif __select == 4:
            os.system("sh $ROOT/create/php.sh")
        elif __select == 5:
            os.system("sh $ROOT/create/redis.sh")
        elif __select == 6:
            os.system("sh $ROOT/create/mongodb.sh")
        elif __select == 7:
            os.system("sh $ROOT/create/lnmp.sh")
        elif __select == 8:
            os.system("sh $ROOT/create/lamp.sh")
        elif __select == 9:
            os.system("sh $ROOT/create/lanmp.sh")
        elif __select == 10:
            os.system("sh $ROOT/create/tomcat.sh")
        elif __select == 11:
            os.system("sh $ROOT/create/memcache.sh")
        else:
            print "未支持的服务"
    else:
        print "未支持的选择"

