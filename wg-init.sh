#!/bin/bash


function init()
{
    if [ "$#" -ne 5 ]; then
        echo "Usage ${0} init config_name hostname port internal_ip"
        exit
    fi

    SAVE_NAME=$2
    WG_PRIVKEY=$(wg genkey)
    WG_PUBKEY=$(echo ${WG_PRIVKEY} | wg pubkey)

    IP_INTERNAL=$5
    PORT=$4
    HOSTNAME=$3

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
    echo "${SAVE_NAME} ${WG_PUBKEY} ${HOSTNAME} ${PORT}" | tee "${SAVE_NAME}".add

    sed -i'' -e "s/^HOSTNAME=.*$/HOSTNAME=${config_name}/" wg-add.sh
}

function deinit()
{
    if [ "$#" -ne 2 ]; then
        echo "Usage ${0} deinit config_name "
        exit
    fi

    SAVE_NAME=$2
    systemctl stop wg-quick@${SAVE_NAME}
    systemctl disable wg-quick@${SAVE_NAME}
    rm ${SAVE_NAME}.conf ${SAVE_NAME}.pub ${SAVE_NAME}.add 2>/dev/null
}

case "$1" in 
    init) 
    init;;
    deinit)
    deinit;;
    reload)
    systemctl reload wg-quick;;
    *) echo "usage: $0 init|deinit|reload" >&2
       exit 1
       ;;
esac