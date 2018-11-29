#!/bin/bash

CONF_NAME=

function init()
{
    if [ "$#" -ne 8 ]; then
        echo "Usage ${0} init peer_name peer_pubkey endpoint local_port peer_port local_addr peer_addr"
        exit
    fi

    
    PEER_NAME=$2
    PEER_PUBKEY=$3
    ENDPOINT_IP=$4
    LOCAL_PORT=$5
    ENDPOINT_PORT=$6
    LOCAL_ADDR=$7
    PEER_ADDR=$8

    cat ${CONF_NAME}.conf > ${CONF_NAME}-${PEER_NAME}.conf

    echo "    ListenPort = ${LOCAL_PORT}

[Peer]
    Endpoint = ${ENDPOINT_IP}:${ENDPOINT_PORT}
    PublicKey = ${PEER_PUBKEY}
    AllowedIPs = 0.0.0.0/0, ::/0" >> ${CONF_NAME}-${PEER_NAME}.conf

    echo "# created by wg-add.sh
auto wg-${CONF_NAME}-${PEER_NAME}
iface wg-${CONF_NAME}-${PEER_NAME} inet static
        address ${LOCAL_ADDR}
        pointopoint ${PEER_ADDR}
        pre-up ip link add wg-${CONF_NAME}-${PEER_NAME} type wireguard
        pre-up wg setconf wg-${CONF_NAME}-${PEER_NAME} /etc/wireguard/${CONF_NAME}-${PEER_NAME}.conf
        post-up ip -6 addr add bbbb::${LOCAL_ADDR} peer bbbb::${PEER_ADDR} dev wg-home-us-hi
        post-down ip link del wg-${CONF_NAME}-${PEER_NAME}
" > /etc/network/interfaces.d/${CONF_NAME}-${PEER_NAME}.conf
    if ! grep "source /etc/network/interfaces.d/*" /etc/network/interfaces>/dev/null; then
        echo "source /etc/network/interfaces.d/*" >> /etc/network/interfaces
    fi

    start $@
}

function start() {
    if [ "$#" -lt 2 ]; then
        echo "Usage ${0} start peer_name"
        exit
    fi
    PEER_NAME=$2
    ifup wg-${CONF_NAME}-${PEER_NAME}
}

function stop() {
    if [ "$#" -lt 2 ]; then
        echo "Usage ${0} stop peer_name"
        exit
    fi
    PEER_NAME=$2
    ifdown wg-${CONF_NAME}-${PEER_NAME}
}

function deinit() {
    if [ "$#" -ne 2 ]; then
        echo "Usage ${0} deinit peer_name"
        exit
    fi
    PEER_NAME=$2
    stop $@ 2>/dev/null
    rm /etc/network/interfaces.d/${CONF_NAME}-${PEER_NAME}.conf 2>/dev/null
}

case "$1" in 
    start) 
    start $@;;
    stop)
    stop $@;;
    init)
    init $@;;
    deinit)
    deinit $@;;
    *) echo "usage: $0 start|stop|init|deinit" >&2
       exit 1
       ;;
esac