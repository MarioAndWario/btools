#!/bin/bash

############################################################
# This script will relabel the band indices in eqp1.dat file
# Author: Meng Wu
# Date: 20170115
############################################################
# [Usage]:
# Set VBM_from for eqp1.dat
# Set VBM_to for eqp1.shift.dat
# This script will subtract the band indices with (VBM_from - VBM_to)
############################################################

VBM_from=1
VBM_to=29

#######################
# This is relative order
# For example, in eqp.dat we have
#  kx ky kz 3
#  1 11 0.1
#  1 12 0.2
#  1 13 0.3
# Then NumofBands_out_start = 1
#      NumofBands_out_end = 3
#######################
NumofBands_out_start=1
NumofBands_out_end=56

NumofBands_out=$(echo "${NumofBands_out_end} - ${NumofBands_out_start} + 1" | bc)

VBM_diff=$(echo "${VBM_from} - ${VBM_to}" | bc)

echo "================= relabeleqp.sh ================="
echo "VBM_from = ${VBM_from}, VBM_to = ${VBM_to}, NumofBands_out = ${NumofBands_out}"
echo "VBM_diff = ${VBM_diff}"

if [ $# == "1" ]; then
    EQPFile=$1
else
    EQPFile="eqp.wan.dat"
fi

EQPShiftFile="eqp.GW.inteqp.shift.dat"

echo "EQPFile = ${EQPFile} EQPShiftFile = ${EQPShiftFile}"

rm -rf $EQPShiftFile

# Number of kpoints
# Number of bands for each kpoint
NumofColumns=$(sed -n '2p' $EQPFile | awk '{print NF}')

echo "NumofColumns = ${NumofColumns}"

NumofBands=$(sed -n '1p' $EQPFile | awk '{print $4}')

echo "================================================="

echo "Number of bands for each kpoint : ${NumofBands}"

if [ ${NumofBands_out} -gt ${NumofBands} ]; then
    echo "Num of output bands wrong: Reqested bands = ${NumofBands_out} Available bands = ${NumofBands}"
    exit 1
fi

# Decide the number of columns in eqp.dat file
# we support both 3 or 4 columns


NumofLines=$(wc -l $EQPFile | awk '{print $1}')

echo "Number of Lines : ${NumofLines}"

NumofKpts=$(echo ${NumofLines} ${NumofBands} | awk '{print $1/($2+1)}')

echo "Number of kpoints : ${NumofKpts}"

for ((ik=1;ik<=${NumofKpts};ik++))
do
    if [ $(echo "${ik}%100" | bc) == "0" ]; then
       Progress=$(echo ${ik} ${NumofKpts} | awk '{print $1/$2*100}')
       echo "ik = ${ik}, Progress = ${Progress} %"
    fi
    kptline=$(echo $ik $NumofBands | awk '{print ($1-1)*($2+1)+1}')
    eqpline_start=$(echo $kptline $NumofBands_out_start | awk '{print $1+$2}')
    eqpline_end=$(echo $kptline $NumofBands_out_end | awk '{print $1+$2}')

    sed -n "$kptline p" $EQPFile | awk '{printf("%14.9f %14.9f %14.9f",$1,$2,$3)}' >> ${EQPShiftFile}
    echo "      ${NumofBands_out}" >> ${EQPShiftFile}
    if [ ${NumofColumns} -eq 3 ]; then
        sed -n "$eqpline_start, $eqpline_end p" $EQPFile | awk -v vbm_diff="$VBM_diff" '{printf("%8d %8d %17.9f \n", $1, $2-vbm_diff, $3)}' >> ${EQPShiftFile}
    else
        sed -n "$eqpline_start, $eqpline_end p" $EQPFile | awk -v vbm_diff="$VBM_diff" '{printf("%8d %8d %17.9f %17.9f \n", $1, $2-vbm_diff, $3, $4)}' >> ${EQPShiftFile}
    fi
done

echo "================================================="
