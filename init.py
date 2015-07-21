#!/usr/bin/python
#-*- coding:utf-8 -*-
__author__ = 'saintic.com'
'''This script is written for Python to initialize CoreWeb;
Time:2015-06-03;
Comments:boot coreweb!'''

import sys
import os
import commands
os.system('clear')
ROOT=sys.path[0]

print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
print "脚本作用：引导安装或升级。请根据提示输入数字继续。"
print '更多内容请访问："https://saintic.com/"'
print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
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
print "  12:memcached"
print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
print "升级服务版本"
print "  0:update the service version!"
print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
print "退出请输入\"q\"或\"Q\"."
print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

__codenum=raw_input('请选择数字代码安装或升级:')

def str2int(s):
    def char2num(s):
        return {'0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9}[s]
    return reduce(lambda x,y: x*10+y, map(char2num, s))

__service_list={0:'Update Service',1:'Nginx',2:'Httpd',3:'MySQL',4:'PHP',5:'Redis',6:'MongoDB',7:'LNMP',8:'LAMP',9:'LANMP',0:'update',10:'tomcat',11:'memcache',12:'memcached'}

if __codenum == "q":
    exit()
elif __codenum == "Q":
    exit()
else:
    __select=str2int(__codenum)
    if __select in __service_list:
        print '你的选择：',__service_list[__select]
        if __select == 0:
            commands.getstatusoutput("sh ROOT/update/init.sh")
        elif __select == 1:
            commands.getstatusoutput("sh ROOT/create/nginx.sh")
        elif __select == 2:
            commands.getstatusoutput("sh ROOT/create/apache.sh")
        elif __select == 3:
            commands.getstatusoutput("sh ROOT/create/mysql.sh")
        elif __select == 4:
            commands.getstatusoutput("sh ROOT/create/php.sh")
        elif __select == 5:
            commands.getstatusoutput("sh ROOT/create/redis.sh")
        elif __select == 6:
            commands.getstatusoutput("sh ROOT/create/mongodb.sh")
        elif __select == 7:
            commands.getstatusoutput("sh ROOT/create/lnmp.sh")
        elif __select == 8:
            commands.getstatusoutput("sh ROOT/create/lamp.sh")
        elif __select == 9:
            commands.getstatusoutput("sh ROOT/create/lanmp.sh")
        elif __select == 10:
            commands.getstatusoutput("sh ROOT/create/tomcat.sh")
        elif __select == 11:
            commands.getstatusoutput("sh ROOT/create/memcache.sh")
        elif __select == 12:
            commands.getstatusoutput("sh ROOT/create/memcached.sh")
        else:
            print "未支持的服务"
    else:
        print "未支持的选择"




	




	