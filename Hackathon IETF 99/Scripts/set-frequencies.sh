#!/bin/bash
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets transmit and receive frequencies of a carrier 
# termination. Performs changes for the other end as well.
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _usage () {
cat << _EOF_

usage:
  $(basename $0) carrier-termination-name new-transit-frequency duplex-distance config-rx-frequency
  
options:
- carrier-termination-name: The carrier termination name to configure
- new-transmit-frequency: The new transmit frequency to set
- duplex-distance: The distance of the transmit and receive frequencies
- config-rx-frequency: true|false 

summary:
 Sets transmit and receive frequencies of a carrier termination. Performs changes for the other end as well.

_EOF_
}


[ "$1" = "-h" ] && _usage && exit 0
[ $# -ne 4 ] && _usage && exit 0


export LOG_FILE=/home/tamasradocz/config-frequency.log

termination=$1
new_tx_frequency=$2
duplex_distance=$3
rx_frequency_config=$4


other_termination=`./query-other-termination.sh $1`
other_termination=`echo $other_termination |sed s/\"//|sed s/\"//`

echo "     between the carrier termination ($termination) and ($other_termination)"
echo "===============================================================================" 
#other_termination=`echo $other_termination |sed s/\"//|sed s/\"//`


echo "===============================================================================" 
echo "    Step 3: Disable the transmit for ($termination) and ($other_termination)"
echo "===============================================================================" 
./config-tx-enabled.sh $termination $other_termination disable


echo "===============================================================================" 
echo "    Step 4: Performing frequeny changes for both pair carrier terminations"

echo "      -  Setting transmit frequency for ($termination) as $new_tx_frequency kHz"
new_rx_frequency=`./config-frequency.sh $termination $new_tx_frequency $new_tx_frequency $rx_frequency_config $duplex_distance`
echo "      -  New receiving frequency for ($termination) is $new_rx_frequency kHz"

other_tx_frequency=$new_rx_frequency
other_rx_frequency=$new_tx_frequency

echo "      -  Setting transmit frequency for ($other_termination) as $other_tx_frequency kHz"
other_rx_frequency=`./config-frequency.sh $other_termination $other_tx_frequency $other_rx_frequency $rx_frequency_config $duplex_distance`
echo "      -  New receiving frequency for ($other_termination) is $other_rx_frequency kHz"
echo "===============================================================================" 


echo "===============================================================================" 
echo "        Step 5: Enable transmit for "$termination" and $other_termination"
echo "===============================================================================" 
./config-tx-enabled.sh $termination $other_termination enable




