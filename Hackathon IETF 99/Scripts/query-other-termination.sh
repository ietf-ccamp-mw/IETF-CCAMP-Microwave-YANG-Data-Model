#!/bin/bash
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Identify the other end of the carrier termination
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _usage () {
cat << _EOF_
usage:
 $(basename $0) carrier-termination-name

options:
- carrier-termination-name : The carrier termination name. Mandatory.                            

summary:
 Remotely identify the other end of the carrier termination.

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
    query_result=`curl -sS --fail -L --user $ODL_WEB_USER:$ODL_WEB_PASS -X GET $GET_URL`
    for i in 0 1 2 3 4 5
    do
        interface_name=`echo ${query_result} | jq .interfaces.interface[$i].name`
	type=`echo ${query_result} | jq .interfaces.interface[$i].type`


        if [ "\""$1"\"" = $interface_name ]; then
            pair_carrier_termination=`echo ${query_result} | jq .interfaces.interface[$i].'"ietf-microwave-radio-link:pairs-carrier-termination"'.ct`
	    echo $pair_carrier_termination
        fi
    done
fi
