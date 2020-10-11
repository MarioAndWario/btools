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
VBM_to=1

VBM_diff=$(echo "${VBM_from} - ${VBM_to}" | bc)

echo "================= relabeleqp.sh ================="
echo "VBM_from = ${VBM_from}, VBM_to = ${VBM_to}"
echo "VBM_diff = ${VBM_diff}"

EQPFile="vxc.dat"

EQPmfFile="vhub.dat"

EQPShiftFile="vxc+vhub.dat"

EQPcomboFile="eqp.combo.dat"

paste ${EQPFile} ${EQPmfFile} > ${EQPcomboFile}

rm -rf $EQPShiftFile

# Number of kpoints
# Number of bands for each kpoint

NumofBands=$(sed -n '1p' $EQPFile | awk '{print $4}')

echo "================================================="

echo "Number of bands for each kpoint : ${NumofBands}"

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
    eqpline_start=$(echo $kptline | awk '{print $1+1}')
    eqpline_end=$(echo $kptline $NumofBands | awk '{print $1+$2}')

    sed -n "$kptline p" $EQPFile >> ${EQPShiftFile}
    sed -n "$eqpline_start, $eqpline_end p" $EQPcomboFile | awk -v vbm_diff="$VBM_diff" '{printf("%8d %8d %17.9f %17.9f \n", $1, $2, $3+$7, $4+$8)}' >> ${EQPShiftFile}
done

echo "================================================="
