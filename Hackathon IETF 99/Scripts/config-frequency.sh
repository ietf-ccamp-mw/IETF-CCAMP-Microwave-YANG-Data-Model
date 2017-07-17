#!/bin/bash

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets transmit and receive frequencies of a single carrier 
# termination. 
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _usage () {
cat << _EOF_

usage:
  $(basename $0) carrier-termination-name new-transmit-frequency new-receive-frequency rx-frequency-config duplex-distance
  
options:
- carrier-termination-name : The carrier termination name to configure
- new-transmit-frequency: The transmit frequency to set.
- new-receive-frequency: The receive frequency to set.
- duplex-distance: The distance of the transmit and receive frequencies
- config-rx-frequency: true|false 

summary:
 Sets transmit and receive frequencies of a single carrier termination.

_EOF_
}


[ "$1" = "-h" ] && _usage && exit 0
[ $# -ne 5 ] && _usage && exit 0



export LOG_FILE=/home/tamasradocz/config-frequency.log

export INPUT_DATA_FILE=/home/tamasradocz/input.json
export ODL_CONTROLLER_IP=192.168.1.101

#DO NOT Modify start
export POST_URL=http://$ODL_CONTROLLER_IP:8181/restconf/operations/ietf-microwave-radio-link:config-frequency
export ODL_WEB_USER=admin
export ODL_WEB_PASS=admin
#disable http proxy
export http_proxy=
#DO NOT modify end

export carrier_termination=$1
new_tx_frequency=$2
new_rx_frequency=$3
rx_frequency_config=$4
new_duplex_distance=$5


   	
	echo `date` "===========================================" >> $LOG_FILE
	echo `date` "  Modify carrier termination tx-enable state" >> $LOG_FILE
	echo `date` "=============================================">> $LOG_FILE
	
        input_data="{\"input\":{\"name\": \"$carrier_termination\", \"tx-frequency\": \"$new_tx_frequency\", \"rx-frequency\": \"$new_rx_frequency\", \"rx-frequency-config\":\"$rx_frequency_config\", \"duplex-distance\":\"$new_duplex_distance\"}}"

        
	echo $input_data > $INPUT_DATA_FILE
	echo `date` "curl -sS --fail -L --user $ODL_WEB_USER:$ODL_WEB_PASS -X POST -H 'Content-Type:application/json' $POST_URL -d@$INPUT_DATA_FILE" >> $LOG_FILE
	modify_result=`curl -sS --fail -L --user $ODL_WEB_USER:$ODL_WEB_PASS -X POST -H 'Content-Type:application/json' $POST_URL -d@$INPUT_DATA_FILE`
	echo `date` $modify_result >> $LOG_FILE
	echo $modify_result|jq .output.'"rx-frequency-state"'




