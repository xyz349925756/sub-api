#!/bin/bash

SPEED="https://speed.cloudflare.com/__down?bytes=100000000"
PORTS=(443 2053 2083 2087 2096 8443)
COLO="HKG"
MESSAGE="请勿测速"

# TPE 台湾  SIN 新加坡  HKG 香港 NRT 日本  MIA 美国
# ps -aux |grep [C]loudflareST  查看程序执行进程

red () {
    echo -e "\e[31m $1 \033[0m" $2;
}

green () {
    echo -e "\e[32m $1 \033[0m" $2;
}

yellow () {
    echo -e "\e[33m $1 \033[0m" $2;
}

error () {
    echo -e "\e[41;37m $1 \033[0m" $2;
}

cloudflareST () {
    green "正在扫描...$1" "请稍后片刻，完成之后会生成 $1.txt"
    CloudflareST -dn 20 -n 1000 -tp $1 -url $SPEED -tl 450 -tll 40 -cfcolo $COLO  -p 30 -sl 5 -o $1.txt
}

merger_file () {
    yellow "合并文件"
    for i in ${PORTS[@]}
    do
        for ip in `sed -e '/IP/d' $i.txt|awk 'BEGIN{FS=","} {print $1}'`
        do 
            echo "$ip:$i#$ip$MESSAGE" >> newcdnip.txt
        done
    done
    green "去重准备api接口"
    awk 'BEGIN{FS=","} {print$1}' newcdnip.txt |sort|uniq > ../newcdnip
}

main () {
    green "程序启动"
    for i in ${PORTS[@]}
    do
        cloudflareST $i 
    done
    wait
    green "操作执行完成。"

    merger_file

    cd ..

    . git_push
    
}

main 