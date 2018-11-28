#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage ${0} config_name hostname port internal_ip"
    exit
fi

SAVE_NAME=$1
WG_PRIVKEY=$(wg genkey)
WG_PUBKEY=$(echo ${WG_PRIVKEY} | wg pubkey)

IP_INTERNAL=$4
PORT=$3
HOSTNAME=$2

echo "IP Address: ${IP_INTERNAL}"
echo "Port: ${PORT}"
echo "Private Key: ${WG_PRIVKEY}"
echo "Public Key: ${WG_PUBKEY}"
echo ""

echo "[Interface]
PrivateKey = ${WG_PUBKEY}
ListenPort = ${PORT}
SaveConfig = true
Address = ${IP_INTERNAL}" > "${SAVE_NAME}".conf

echo $WG_PUBKEY > "${SAVE_NAME}".pub

echo "Public Key saved to ${SAVE_NAME}.pub"
echo "Config saved to ${SAVE_NAME}.conf"
echo ""

echo "running systemctl start wg-quick@${SAVE_NAME}"
systemctl enable wg-quick@${SAVE_NAME}
systemctl start wg-quick@${SAVE_NAME}

echo "To Add this node, copy and paste the line below on other nodes"
echo ""
echo "  ${SAVE_NAME} ${WG_PUBKEY} ${HOSTNAME} ${PORT}"

sed -i'' -e "s/^HOSTNAME=.*$/HOSTNAME=${HOSTNAME}/" wg-add.sh
