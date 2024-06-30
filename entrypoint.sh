#!/bin/bash
HY2PORT=${HY2PORT:-'20000'}
TUIC5PORT=${TUIC5PORT:-'20001'}
SERV00PASSWORD=${SERV00PASSWORD:-'password'}

USERNAME=$(whoami)
UUID=${UUID:-'de04add9-5c68-8bab-950c-08cd5320df18'}
WORKDIR="/home/${USERNAME}/sing-box"


generate_config() {
  rm -rf ${WORKDIR}/config.json
  cat > ${WORKDIR}/config.json << EOF
{
  "log": {
    "disabled": false,
    "level": "info",
    "timestamp": true
  },
  "inbounds": [{
      "type": "hysteria2",
      "sniff": true,
      "sniff_override_destination": true,
      "tag": "hy2-sb",
      "listen": "::",
      "listen_port": ${HY2PORT},
      "up_mbps": 900,
      "down_mbps": 360,
      "users": [{
        "password": "${UUID}"
      }],
      "ignore_client_bandwidth": false,
      "tls": {
        "enabled": true,
        "alpn": [
          "h3"
        ],
        "certificate_path": "${WORKDIR}/cert.crt",
        "key_path": "${WORKDIR}/private.key"
      }
    },
    {
      "type": "tuic",
      "sniff": true,
      "sniff_override_destination": true,
      "tag": "tuic5-sb",
      "listen": "::",
      "listen_port": ${TUIC5PORT},
      "users": [{
        "uuid": "${UUID}",
        "password": "${UUID}"
      }],
      "congestion_control": "bbr",
      "tls": {
        "enabled": true,
        "alpn": [
          "h3"
        ],
        "certificate_path": "${WORKDIR}/cert.crt",
        "key_path": "${WORKDIR}/private.key"
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct",
      "domain_strategy": "ipv4_only"
    },
    {
      "type": "wireguard",
      "tag": "wireguard-out",
      "server": "162.159.193.10",
      "server_port": 1701,
      "local_address": [
        "172.16.0.2/32",
        "2606:4700:110:8b82:7e66:1cc9:db92:fbf6/128"
      ],
      "private_key": "kAKpn/A4Rrhi1RvdKuFKurxWh2vYbZPHZQ/HlFFuwGE=",
      "peer_public_key": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
      "reserved": [110, 229, 36]
    },
    {
      "type": "block",
      "tag": "block"
    }
  ],
  "route": {
    "rules": [
      {
        "outbound": "wireguard-out",
        "domain_keyword": [
          "chatgpt",
          "openai",
          "netflix"
        ]
      },
      {
        "outbound": "direct",
        "network": "udp,tcp"
      }
    ]
  }
}
EOF
}

get_certificate() {
    local IP_ADDRESS=$(devil ssl www list | awk '/SNI SSL certificates for WWW/{flag=1; next} flag && NF && $6 != "address" {print $6}' | head -n 1)
    local DOMAIN=$(devil ssl www list | awk '/SNI SSL certificates for WWW/{flag=1; next} flag && NF && $6 != "address" {print $8}' | head -n 1)
    local HOST=$(devil vhost list | awk 'NR>2 {print $2}' | grep '^s')
    local CERT_OUTPUT=$(env SERV00PASSWORD="$SERV00PASSWORD" expect << EOF
spawn devil ssl www get "${IP_ADDRESS}" "${DOMAIN}"
expect "Password:"
send "\$env(SERV00PASSWORD)\r"
expect eof
catch wait result
puts "\nResult: \$result\n"
EOF
)
    local CERTIFICATE=$(echo "$CERT_OUTPUT" | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' ORS='\n')
    local PRIVATE_KEY=$(echo "$CERT_OUTPUT" | awk '/-----BEGIN PRIVATE KEY-----/,/-----END PRIVATE KEY-----/' ORS='\n')
    if [ -z "${CERTIFICATE}" ] || [ -z "${PRIVATE_KEY}" ]; then
        echo "证书获取失败，请检查是否在面板中成功获取到Let's Encrypt证书"
        exit 1
    fi
    echo "$CERTIFICATE" > ${WORKDIR}/cert.crt
    echo "$PRIVATE_KEY" > ${WORKDIR}/private.key

    export_list() {
        rm -rf ${WORKDIR}/list
        cat > ${WORKDIR}/list << EOF
*******************************************
        
hy2配置：
        
hysteria2://${UUID}@${HOST}:${HY2PORT}/?sni=${DOMAIN}#🇵🇱PL-hy2-k0baya-serv00
        
----------------------------
        
tuic5配置：
        
tuic://${UUID}:${UUID}@${HOST}:${TUIC5PORT}//?congestion_control=bbr&udp_relay_mode=native&sni=${DOMAIN}&alpn=h3#🇵🇱PL-tuic5-k0baya-serv00
        
*******************************************
EOF
  }
    export_list
}

get_singbox(){
  wget https://raw.githubusercontent.com/k0baya/sb-for-serv00/main/sing-box -O ${WORKDIR}/sing-box && chmod +x ${WORKDIR}/sing-box
}

mkdir -p ${WORKDIR}
[ ! -e ${WORKDIR}/sing-box ] && get_singbox
[ ! -e ${WORKDIR}/config.json ] && generate_config
[ ! -e ${WORKDIR}/cert.crt ] || [ ! -e ${WORKDIR}/private.key ] || [ ! -e ${WORKDIR}/list ] && get_certificate
chmod +x ${WORKDIR}/sing-box
exec ${WORKDIR}/sing-box run -c ${WORKDIR}/config.json