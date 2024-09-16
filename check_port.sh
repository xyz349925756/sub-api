#!/bin/bash

PORTS=(443 2053 2083 2087 2096 8443)
PORT_LENGTH=${#PORTS[@]}

red() {
    echo -e "\e[31m $1 \033[0m" $2
}
yellow() {
    echo -e "\e[33m $1 \033[0m" $2
}

green() {
    echo -e "\e[32m $1 \033[0m" $2
}


get_cdn () {
    if [ -f "CDNym.txt" ];then
        yellow "提取cdn文件"
        sed -e '/IPV6/d' -e '/^$/d' -e 's#\r##g' CDNym.txt | awk 'BEGIN{FS="："} {print $2}' > cdn.txt
    else
        red "请先优选域名!"
    fi
}


get_random_port(){
    RANDOM_INDEX=$((RANDOM % (0 - $PORT_LENGTH)))
    RANDOM_PORT=${PORTS[$RANDOM_INDEX]}
}

main () {
    rm newcdnip.txt 2> /dev/null
    get_cdn
    for i in $(cat cdn.txt);
    do
        green "$i 开始"
        timeout 1 curl -s https://$i/cdn-cgi/trace 2>&1 > /dev/null
        if [ $? -eq 0 ];then
            yellow "命令执行成功，正在查询归属国！"
            COLO=$(curl -s https://$i/cdn-cgi/trace  |awk 'BEGIN{FS="="} /colo/ {print $2}')
            get_random_port
            echo "$i:$RANDOM_PORT#$COLO" >> newcdnip.txt
            green "$i 保存成功"
        else
            red "$i 域名不可用"
        fi
    done    
    
     
}

main