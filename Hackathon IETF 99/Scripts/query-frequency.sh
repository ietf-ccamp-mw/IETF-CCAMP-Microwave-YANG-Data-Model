#!/bin/bash
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Remotely query transmit frequency of a carrier termination.
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _usage () {
cat << _EOF_
usage:
 $(basename $0) [carrier-termination-name]

options:
- [carrier-termination-name] : The carrier termination name to configure.
                               If not specified, it will query all carrier termination.

summary:
 # Remotely query transmit frequency of a carrier termination.

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


if [ $# -eq 0 ]; then
    query_result=`curl -sS --fail -L --user $ODL_WEB_USER:$ODL_WEB_PASS -X GET $GET_URL`
    echo "==============================================================================="
    echo "      Query all carrier termination tx_enabled state as below"
    echo "==============================================================================="
    echo "            carrier termination" "  |  tx-frequency"
    echo "==============================================================================="
    for i in 0 1 2 3 4 5
    do
        interface_name=`echo ${query_result} | jq .interfaces.interface[$i].name`
	type=`echo ${query_result} | jq .interfaces.interface[$i].type`
        if [ $type = "\"ietf-microwave-radio-link:carrier-termination\"" ]; then
            interface=`echo ${query_result} | jq .interfaces.interface[$i]`
	    tx_frequency=`echo ${interface/ietf-microwave-radio-link:tx-frequency/txfrequency} | jq .txfrequency`
            echo "              " $interface_name "        |  $tx_frequency"
            echo "==============================================================================="
        fi
    done
elif [ $# -eq 1 ]; then
    query_result=`curl -sS --fail -L --user $ODL_WEB_USER:$ODL_WEB_PASS -X GET $GET_URL`
    for i in 0 1 2 3 4 5
    do
        interface_name=`echo ${query_result} | jq .interfaces.interface[$i].name`

        if [ "\""$1"\"" = $interface_name ]; then
            interface=`echo ${query_result} | jq .interfaces.interface[$i]`
	    tx_frequency=`echo ${interface/ietf-microwave-radio-link:tx-frequency/txfrequency} | jq .txfrequency`
            echo $tx_frequency
        fi
    done
fi
