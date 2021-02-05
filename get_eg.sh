#!/bin/bash
# line=$(echo ${Eindex}+1 | bc)
OUTPUT="eqp1_noR.dat"
echo "$OUTPUT"
E1=$(sed -n "2 p" ${OUTPUT} | awk '{print $4}')
E2=$(sed -n "3 p" ${OUTPUT} | awk '{print $4}')
echo "E1 =       $E1"
echo "E2 =       $E2"
echo "Eg = $(echo ${E1} ${E2} | awk '{printf("%15.6f",$2-$1)}')"
echo "============================="

OUTPUT="eqp1_R.dat"
echo "$OUTPUT"
E1=$(sed -n "2 p" ${OUTPUT} | awk '{print $4}')
E2=$(sed -n "3 p" ${OUTPUT} | awk '{print $4}')
echo "E1 =       $E1"
echo "E2 =       $E2"
echo "Eg = $(echo ${E1} ${E2} | awk '{printf("%15.6f",$2-$1)}')"
echo "============================="


OUTPUT="eqp1_ave.dat"
echo "$OUTPUT"
E1=$(sed -n "2 p" ${OUTPUT} | awk '{print $4}')
E2=$(sed -n "3 p" ${OUTPUT} | awk '{print $4}')
echo "E1 =       $E1"
echo "E2 =       $E2"
echo "Eg = $(echo ${E1} ${E2} | awk '{printf("%15.6f",$2-$1)}')"
echo "============================="
