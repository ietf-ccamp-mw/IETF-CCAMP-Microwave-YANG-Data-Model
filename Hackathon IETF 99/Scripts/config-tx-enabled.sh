#!/bin/bash
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Remotely configures carrier termination tx-enabled state.
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _usage () {
cat << _EOF_
usage:
 $(basename $0) [carrier-termination-name] [paris-carrier-termination-name] [disable | enable]

options:
- [carrier-termination-name] : The carrier termination name to configure.
- [paris-carrier-termination-name] : The pairs carrier termination name to configure.
- [disable | enable] : Disables or enables the transmitter.

summary:
 Remotely configures carrier termination tx-enabled state.

_EOF_
}

[ "$1" = "-h" ] && _usage && exit 0

[ $# -ne 3 ] && _usage && exit 0

[ "$3" != "disable" ] && [ "$3" != "enable" ] && _usage && exit 0

export LOG_FILE=/home/tamasradocz/config-tx-enabled.log
#keep input data file name as input.json
export INPUT_DATA_FILE=/home/tamasradocz/input.json
export ODL_CONTROLLER_IP=192.168.1.101

#DO NOT modify start
export GET_URL=http://$ODL_CONTROLLER_IP:8181/restconf/operational/ietf-interfaces:interfaces/interface
export POST_URL=http://$ODL_CONTROLLER_IP:8181/restconf/operations/ietf-microwave-radio-link:config-tx-enable
export ODL_WEB_USER=admin
export ODL_WEB_PASS=admin
#disable http proxy
export http_proxy=
#DO NOT modify end

for carrier_termination in $1 $2
do
    echo `date` "===============================================================================" >> $LOG_FILE
    echo `date` "         Query carrier termination ($carrier_termination) tx-enabled state" >> $LOG_FILE
    echo `date` "===============================================================================" >> $LOG_FILE
    echo `date` "curl -sS --fail -L --user $ODL_WEB_USER:$ODL_WEB_PASS -X GET $GET_URL/$carrier_termination" >> $LOG_FILE
    query_result=`curl -sS --fail -L --user $ODL_WEB_USER:$ODL_WEB_PASS -X GET $GET_URL/$carrier_termination`
    echo `date` "$query_result" >> $LOG_FILE
    tx_enabled=`echo ${query_result/ietf-microwave-radio-link:tx-enabled/txEnabled} | jq .interface[0].txEnabled`
    echo `date` "ietf-microwave-radio-link:tx-enabled = $tx_enabled" >> $LOG_FILE

    if [ "$tx_enabled" != "true" ] && [ "$tx_enabled" != "false" ]; then
        echo `date` "Query carrier termination ($carrier_termination) tx-enabled state failed!" >> $LOG_FILE
        continue
    fi

    state=$3
    if [ "$state" = "enable" ] && [ "$tx_enabled" = "true" ]; then
        echo `date` "carrier termination ($carrier_termination) tx-enabled is already enabled!" >> $LOG_FILE
        continue
    fi

    if [ "$state" = "disable" ] && [ "$tx_enabled" = "false" ]; then
        echo `date` "carrier termination ($carrier_termination) tx-enabled is already disabled!" >> $LOG_FILE
        continue
    fi

    echo `date` "===============================================================================" >> $LOG_FILE
    echo `date` "         Modify carrier termination ($carrier_termination) tx-enabled state" >> $LOG_FILE
    echo `date` "===============================================================================" >> $LOG_FILE

    if [ "$state" = "enable" ]; then
        input_data="{\"input\":{\"name\": \"$carrier_termination\", \"tx-enabled\": true}}"
    elif [ "$state" = "disable" ]; then
        input_data="{\"input\":{\"name\": \"$carrier_termination\", \"tx-enabled\": false}}"
    fi

    echo $input_data > $INPUT_DATA_FILE
    echo `date` "curl -sS --fail -L --user $ODL_WEB_USER:$ODL_WEB_PASS -X POST -H 'Content-Type:application/json' $POST_URL -d@$INPUT_DATA_FILE" >> $LOG_FILE
    modify_result=`curl -sS --fail -L --user $ODL_WEB_USER:$ODL_WEB_PASS -X POST -H 'Content-Type:application/json' $POST_URL -d@$INPUT_DATA_FILE`
    echo `date`  $modify_result >> $LOG_FILE

    tx_enable_state=`echo ${modify_result/tx-enable-state/txEnableState} | jq .output.txEnableState`
    if [ "$tx_enable_state" = "true" ] && [ "$state" = "enable" ]; then
        echo `date` "config carrier termination ($carrier_termination) tx-enabled as $state successfully!" >> $LOG_FILE
    elif [ "$tx_enable_state" = "false" ] && [ "$state" = "disable" ]; then
        echo `date` "config carrier termination ($carrier_termination) tx-enabled as $state successfully!" >> $LOG_FILE
    else
        echo `date` "config carrier termination ($carrier_termination) tx-enabled as $state failed!" >> $LOG_FILE
    fi
    echo `date` "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> $LOG_FILE
done
