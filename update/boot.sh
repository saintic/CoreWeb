#!/bin/bash
#update service,version
ERROR() {
  echo "Error:script will quit"
  exit 1
}

[ -z $ROOT ] && ERROR

echo -e  "\033[32m脚本作用为升级软件版本，支持软件为Nginx\033[0m"
echo -e  "\033[32m升级项目   代码号   请输入代码号(数字)，以进行相应升级!\033[0m"
echo -e  "\033[32m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\033[0m"
echo -e  "\033[32m退出       Q/q\033[0m"
echo -e  "\033[32mNginx        1\033[0m"
echo -e  "\033[32m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\033[0m"
read -p  "请输入对应代码号升级服务：" CODE_NUM
case $CODE_NUM in
    q|Q)
        echo -e "\033[32mQuit Script.\033[0m"
        exit
		;;
    1)
	    echo -e "\033[32mUpdate Nginx\033[0m"
	    sh ${ROOT}/update/update_nginx.sh
	    ;;
	*)
	    echo -e "\033[32m不匹配代码号,脚本不执行\033[0m"
	    exit 1
	    ;;
esac
