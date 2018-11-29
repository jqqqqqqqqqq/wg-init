#!/bin/bash


function init()
{
    if [ "$#" -ne 4 ]; then
        echo "Usage ${0} init config_name hostname port"
        exit
    fi

    SAVE_NAME=$2
    WG_PRIVKEY=$(wg genkey)
    WG_PUBKEY=$(echo ${WG_PRIVKEY} | wg pubkey)

    IP_INTERNAL=$5
    PORT=$4
    HOST_NAME=$3

    echo "Port: ${PORT}"
    echo "Private Key: ${WG_PRIVKEY}"
    echo "Public Key: ${WG_PUBKEY}"
    echo ""

    echo "[Interface]
    PrivateKey = ${WG_PRIVKEY}
    ListenPort = ${PORT}" > "${SAVE_NAME}".conf

    echo $WG_PUBKEY > "${SAVE_NAME}".pub

    echo "Public Key saved to ${SAVE_NAME}.pub"
    echo "Config saved to ${SAVE_NAME}.conf"
    echo ""

    echo "To Add this node, copy and paste the line below on other nodes"
    echo ""
    echo "${SAVE_NAME} ${WG_PUBKEY} ${HOST_NAME} ${PORT}" | tee "${SAVE_NAME}".add

    sed -e "s/^CONF_NAME=.*$/CONF_NAME=${SAVE_NAME}/" wg-add.sh > wg-add-${SAVE_NAME}.sh
    chmod +x wg-add-${SAVE_NAME}.sh
}

function deinit()
{
    if [ "$#" -ne 2 ]; then
        echo "Usage ${0} deinit config_name "
        exit
    fi

    SAVE_NAME=$2
    rm ${SAVE_NAME}.conf ${SAVE_NAME}.pub ${SAVE_NAME}.add 2>/dev/null
}

case "$1" in 
    init) 
    init $@;;
    deinit)
    deinit $@;;
    *) echo "usage: $0 init|deinit" >&2
       exit 1
       ;;
esac
