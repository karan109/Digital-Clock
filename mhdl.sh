#!/bin/bash
ghdl -a frequency.vhd
ghdl -e frequency

ghdl -a bcdto7segment.vhd
ghdl -e bcdto7segment

ghdl -a $1.vhd
ghdl -e $1 

ghdl -a $1_tb.vhd
ghdl -e $1_tb 

ghdl -r $1_tb --stop-time=$2 --fst=$1.fst

open $1.fst