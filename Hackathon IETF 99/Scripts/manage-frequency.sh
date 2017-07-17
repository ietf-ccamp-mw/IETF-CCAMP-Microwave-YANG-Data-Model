#!/bin/bash
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Query SNIR value for a carrier termination and initiate
# setting frequencies when needed.
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _usage () {
cat << _EOF_
usage:
 $(basename $0) carrier-termination-name

options:
- carrier-termination-name : The carrier termination name to configure.
                               If not specified, it will query all carrier termination.

summary:
 Remotely query carrier termination tx-enabled state.

_EOF_
}

[ "$1" = "-h" ] && _usage && exit 0

[ $# -ne 1 ] && _usage && exit 0


if [ $# -eq 1 ]; then

    export CARRIER_TERMINATION_NAME=$1

    threshold=30 


    echo "===============================================================================" 
    echo "                Manage the frequency of ($CARRIER_TERMINATION_NAME)" 
    echo "==============================================================================="

    echo "===============================================================================" 
    echo "    Step 1: Query the SNIR and the frequency of ($CARRIER_TERMINATION_NAME)" 

    snir=`./query-snir.sh $CARRIER_TERMINATION_NAME`
    tx_frequency=`./query-frequency.sh $CARRIER_TERMINATION_NAME` 
    echo "       - SNIR value of ($CARRIER_TERMINATION_NAME) is "$snir
    echo "       - Current transmit frequency of ($CARRIER_TERMINATION_NAME) is $tx_frequency kHz"
    echo "==============================================================================="

    if [ $threshold -gt $snir ];  then
       random=`echo $RANDOM`
       new_tx_frequency=$((10000000+$random))
       duplex_distance=64000
       rx_frequency_config=false

       echo "===============================================================================" 
       echo "   Step 2: SNIR value "$snir" is lower than the predefined threshold " 
       echo "                Setting new freuquencies for the link "
       
      ./set-frequencies.sh $CARRIER_TERMINATION_NAME $new_tx_frequency $duplex_distance $rx_frequency_config
    fi
fi

