#!/bin/bash
# 填写变量值时请用半角单引号''进行包裹
export HY2PORT=''
export TUIC5PORT=''
export TRPORT=''
export SERV00PASSWORD=''
# 如果使用默认UUID，请删除下一行
export UUID=''

USERNAME=$(whoami)
WORKDIR="/home/${USERNAME}/sing-box"
mkdir -p ${WORKDIR}
cd ${WORKDIR} && \
[ ! -e ${WORKDIR}/entrypoint.sh ] && wget https://raw.githubusercontent.com/k0baya/sb-for-serv00/main/entrypoint.sh -O ${WORKDIR}/entrypoint.sh && chmod +x ${WORKDIR}/entrypoint.sh && \
[ ! -e ${WORKDIR}/app.js ] && wget https://raw.githubusercontent.com/k0baya/sb-for-serv00/main/app.js -O ${WORKDIR}/app.js && \
[ ! -e ${WORKDIR}/sing-box ] && wget https://raw.githubusercontent.com/k0baya/sb-for-serv00/main/sing-box -O ${WORKDIR}/sing-box
sleep 5 && nohup node ${WORKDIR}/app.js >/dev/null 2>&1 &
echo 'SB-for-Serv00 is trying to start up, please waiting...'
sleep 7 && cat ${WORKDIR}/list
