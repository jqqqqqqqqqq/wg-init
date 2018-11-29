#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage ${0} peer_name peer_pubkey ip port"
    exit
fi

CONF_NAME=
PEER_NAME=$1
PEER_PUBKEY=$2
ENDPOINT_IP=$3
ENDPOINT_PORT=$4

cat ${CONF_NAME}.conf > ${CONF_NAME}-${PEER_NAME}.conf

echo "
[Peer]
Endpoint = ${ENDPOINT_IP}:${ENDPOINT_PORT}
PublicKey = ${PEER_PUBKEY}
AllowedIPs = 0.0.0.0/0, ::/0" >> ${CONF_NAME}-${PEER_NAME}.conf

systemctl enable wg-quick@${CONF_NAME}-${PEER_NAME}
systemctl start wg-quick@${CONF_NAME}-${PEER_NAME}