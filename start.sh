#!/bin/bash
# 填写变量值时请用半角单引号''进行包裹
export HY2PORT=''
export TUIC5PORT=''
export SERV00PASSWORD=''
# 如果使用默认UUID，请删除下一行
export UUID=''

USERNAME=$(whoami)
WORKDIR="/home/${USERNAME}/sing-box"
[ ! -e ${WORKDIR}/entrypoint.sh ] && wget https://raw.githubusercontent.com/k0baya/sb-for-serv00/main/entrypoint.sh -O entrypoint.sh && chmod +x entrypoint.sh
nohup node app.js 2>/dev/null 2>&1 &
sleep 5 && cat ${WORKDIR}/list