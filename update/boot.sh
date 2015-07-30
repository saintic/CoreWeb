#!/bin/bash
#update service,version
ERROR() {
  echo "Error:script will quit"
  exit 1
}

[ -z $ROOT ] && ERROR

echo "脚本作用为升级软件版本，支持软件为Nginx"
echo "升级项目   代码号   请输入代码号(数字)，以进行相应升级!"
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo "退出       Q/q"
echo "Nginx        1"
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
read -p "请输入对应代码号升级服务：" CODE_NUM
case $CODE_NUM in
    q|Q)
        echo "Quit Script."
        exit
		;;
    1)
	    echo "Update Nginx"
	    sh ${ROOT}/update/update_nginx.sh
	    ;;
	*)
	    echo "不匹配代码号,脚本不执行"
	    exit 1
	    ;;
esac
