#!/bin/bash

# source ../Confmodelsim/config 

## clean
if [ -d ../Libs/LIB_ROBOT ] 
then /bin/rm -rf ../Libs/LIB_ROBOT 
fi

## creation of the lib
vlib ../Libs/LIB_ROBOT

## compilation
vcom -work LIB_ROBOT -cover bfs robot.vhd

