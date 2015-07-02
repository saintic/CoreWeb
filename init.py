#!/usr/bin/python
'''This script is written for Python to initialize CoreWeb;
Author:saintic.com;
Time:2015-06-03;
Comments:boot coreweb!'''
print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
print "Boot install or update, please continue!"
print 'More content please visit the URL "https://saintic.com/".'
print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
print "Create Services: Version will be displayed next page."
print "  1:Nginx"
print "  2:Httpd"
print "  3:MySQL"
print "  4:PHP"
print "  5:Redis"
print "  6:MongoDB"
print "  7:LNMP"
print "  8:LAMP"
print "  9:LANMP"
print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
print "Update Services: Input enter your number."
print "  0:update the service version!"
print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
print "\"q\":\"quit\""
print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

codenum=raw_input('Please select code number:')
service_list={1:'Nginx',2:'Httpd',3:'MySQL',4:'PHP',5:'Redis',6:'MongoDB',7:'LNMP',8:'LAMP',9:'LANMP',0:'update'}
if codenum == 'q':
    exit()
else:
    codenum=int(codenum)
    if codenum in service_list:
        print 'Your select:',service_list[codenum]
    else:
        print "Error, there is no value."








	