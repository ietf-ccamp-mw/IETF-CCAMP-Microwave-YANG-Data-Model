#!/bin/bash
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Remotely query the SNIR value for carrier terminations.
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _usage () {
cat << _EOF_
usage:
 $(basename $0) [carrier-termination-name]

options:
- [carrier-termination-name] : The carrier termination name to query.
                               If not specified, it will query all carrier termination.

summary:
 Remotely query the SNIR value for carrier terminations.

_EOF_
}

[ "$1" = "-h" ] && _usage && exit 0

[ $# -gt 1 ] && _usage && exit 0

export ODL_CONTROLLER_IP=192.168.1.101

#DO NOT modify start
export CARRIER_TERMINATION_NAME=$1
export GET_URL=http://$ODL_CONTROLLER_IP:8181/restconf/operational/ietf-interfaces:interfaces-state
export ODL_WEB_USER=admin
export ODL_WEB_PASS=admin
#disable http proxy
export http_proxy=
#DO NOT modify end


if [ $# -eq 0 ]; then
    query_result=`curl -sS --fail -L --user $ODL_WEB_USER:$ODL_WEB_PASS -X GET $GET_URL`
    echo "==============================================================================="
    echo "      Query all carrier termination SNIR values"
    echo "==============================================================================="
    echo "            carrier termination" "  |  actual-snir"
    echo "==============================================================================="
    for i in 0 1 2 3 4 5
    do
        interface_name=`echo ${query_result} | jq .'"interfaces-state"'.interface[$i].name`

	type=`echo ${query_result} | jq .'"interfaces-state"'.interface[$i].type`
        if [ $type = "\"ietf-microwave-radio-link:carrier-termination\"" ]; then
            interface=`echo ${query_result} | jq .'"interfaces-state"'.interface[$i]`
	    actual_snir=`echo ${interface/ietf-microwave-radio-link:actual-snir/actualsnir} | jq .actualsnir`
            echo "              " $interface_name "        |  $actual_snir"
            echo "==============================================================================="
        fi
    done
elif [ $# -eq 1 ]; then
    query_result=`curl -sS --fail -L --user $ODL_WEB_USER:$ODL_WEB_PASS -X GET $GET_URL`
    for i in 0 1 2 3 4 5
    do
        interface_name=`echo ${query_result} | jq .'"interfaces-state"'.interface[$i].name`

        if [ "\""$1"\"" = $interface_name ]; then
            interface=`echo ${query_result} | jq .'"interfaces-state"'.interface[$i]`
	    actual_snir=`echo ${interface/ietf-microwave-radio-link:actual-snir/actualsnir} | jq .actualsnir`
            echo $actual_snir
        fi
    done
fi
