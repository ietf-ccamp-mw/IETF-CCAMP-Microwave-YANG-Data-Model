#!/bin/bash
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Remotely query carrier termination tx-enabled state.
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _usage () {
cat << _EOF_
usage:
 $(basename $0) [carrier-termination-name]

options:
- [carrier-termination-name] : The carrier termination name to configure.
                               If not specified, it will query all carrier termination.

summary:
 Remotely query carrier termination tx-enabled state.

_EOF_
}

[ "$1" = "-h" ] && _usage && exit 0

[ $# -gt 1 ] && _usage && exit 0

export ODL_CONTROLLER_IP=192.168.1.101

#DO NOT modify start
export CARRIER_TERMINATION_NAME=$1
export GET_URL=http://$ODL_CONTROLLER_IP:8181/restconf/operational/ietf-interfaces:interfaces
export ODL_WEB_USER=admin
export ODL_WEB_PASS=admin
#disable http proxy
export http_proxy=
#DO NOT modify end

if [ $# -eq 1 ]; then
    #echo `date` "curl -sS --fail -L --user $ODL_WEB_USER:$ODL_WEB_PASS -X GET $GET_UR/interface/$CARRIER_TERMINATION_NAME"
    query_result=`curl -sS --fail -L --user $ODL_WEB_USER:$ODL_WEB_PASS -X GET $GET_URL/interface/$CARRIER_TERMINATION_NAME`
    #echo `date` "$query_result"
    tx_enabled=`echo ${query_result/ietf-microwave-radio-link:tx-enabled/txEnabled} | jq .interface[0].txEnabled`
    echo "==============================================================================="
    if [ "$tx_enabled" != "true" ] && [ "$tx_enabled" != "false" ]; then
        echo "  Query carrier termination ($CARRIER_TERMINATION_NAME) tx-enabled state failed!"
        echo "==============================================================================="
        exit 0
    fi
    echo "      Query carrier termination tx_enabled state as below"
    echo "==============================================================================="
    echo "            carrier termination" "  |  tx_enabled"
    echo "==============================================================================="
    echo "              " $CARRIER_TERMINATION_NAME  "        |  $tx_enabled"
    echo "==============================================================================="
    exit 0
fi

if [ $# -eq 0 ]; then
    query_result=`curl -sS --fail -L --user $ODL_WEB_USER:$ODL_WEB_PASS -X GET $GET_URL`
    echo "==============================================================================="
    echo "      Query all carrier termination tx_enabled state as below"
    echo "==============================================================================="
    echo "            carrier termination" "  |  tx_enabled"
    echo "==============================================================================="
    for i in 0 1 2 3 4 5
    do
        interface_name=`echo ${query_result} | jq .interfaces.interface[$i].name`
        type=`echo ${query_result} | jq .interfaces.interface[$i].type`
        if [ $type = "\"ietf-microwave-radio-link:carrier-termination\"" ]; then
            interface=`echo ${query_result} | jq .interfaces.interface[$i]`
            tx_enabled=`echo ${interface/ietf-microwave-radio-link:tx-enabled/txEnabled} | jq .txEnabled`
            echo "              " $interface_name "        |  $tx_enabled"
            echo "==============================================================================="
        fi
    done
fi
