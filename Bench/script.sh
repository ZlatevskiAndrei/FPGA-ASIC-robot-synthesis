#!/bin/bash

## clean
if [ -d ../Libs/LIB_ROBOT_BENCH ] 
then /bin/rm -rf ../Libs/LIB_ROBOT_BENCH
fi

## creation of the lib
vlib ../Libs/LIB_ROBOT_BENCH

## compilation
vcom -work LIB_ROBOT_BENCH test_robot.vhd

