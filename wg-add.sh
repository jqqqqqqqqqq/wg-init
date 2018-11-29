#!/bin/bash

if [ "$#" -lt 4 ]; then
    echo "Usage ${0} peer_name peer_pubkey ip port (allow_ips)"
    exit
fi

CONF_NAME=
PEER_NAME=$1
PEER_PUBKEY=$2
ENDPOINT_IP=$3
ENDPOINT_PORT=$4

if [ "$#" -eq 5 ]; then
    ALLOW_IPS=$5
    wg set wg-${CONF_NAME}-${PEER_NAME} peer ${PEER_PUBKEY} endpoint ${ENDPOINT_IP}:${ENDPOINT_PORT} allowed-ips ${ALLOW_IPS}
else
    wg set wg-${CONF_NAME}-${PEER_NAME} peer ${PEER_PUBKEY} endpoint ${ENDPOINT_IP}:${ENDPOINT_PORT}
fi
