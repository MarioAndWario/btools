#!/bin/bash

############################################################
# This script will combine two eqp.dat file with splited bands
# For example, the eqp.B1_3.dat file contains all the kpoints and bands [1,3]
# and eqp.B4_6.dat file contains all the kpoints and bands [4,6]
# We will combines these two files and get a new eqp.B1_6.dat

# Author: Meng Wu
# Date: 20170228
############################################################
# [Usage]:
# Set VBM_from for eqp1.dat
# Set VBM_to for eqp1.shift.dat
# This script will subtract the band indices with (VBM_from - VBM_to)
############################################################

VBM_from=13
VBM_to=9

VBM_diff=$(echo "${VBM_from} - ${VBM_to}" | bc)

echo "================= relabeleqp.sh ================="
echo "VBM_from = ${VBM_from}, VBM_to = ${VBM_to}"
echo "VBM_diff = ${VBM_diff}"

EQPFile_1="eqp1.B13_18.dat"
EQPFile_2="eqp1.B19_34.dat"

EQPoutputFile="eqp1.B13_34.dat"

rm -rf $EQPoutputFile

# Number of kpoints
# Number of bands for each kpoint

echo "================ For ${EQPFile_1}  ===================="
NumofBands_1=$(sed -n '1p' $EQPFile_1 | awk '{print $4}')

NumofLines_1=$(wc -l $EQPFile_1 | awk '{print $1}')

#echo "Number of Lines : ${NumofLines}"

NumofKpts_1=$(echo ${NumofLines_1} ${NumofBands_1} | awk '{print $1/($2+1)}')

echo "Number of bands for each kpoint : ${NumofBands_1}"
echo "Number of kpoints : ${NumofKpts_1}"

echo "================ For ${EQPFile_2}  ===================="
NumofBands_2=$(sed -n '1p' $EQPFile_2 | awk '{print $4}')

NumofLines_2=$(wc -l $EQPFile_2 | awk '{print $1}')

#echo "Number of Lines : ${NumofLines}"

NumofKpts_2=$(echo ${NumofLines_2} ${NumofBands_2} | awk '{print $1/($2+1)}')

echo "Number of bands for each kpoint : ${NumofBands_2}"
echo "Number of kpoints : ${NumofKpts_2}"

echo "================================================="

NumofTotalBands=$(echo "${NumofBands_1} + ${NumofBands_2}" | bc)

echo "Total number of bands : ${NumofTotalBands}"

if [ ${NumofKpts_2} != ${NumofKpts_1} ]; then
   echo "NumofKpts mismatch!"
   exit 1
fi

#for ((ik=1;ik<=2;ik++))
for ((ik=1;ik<=${NumofKpts_1};ik++))
do
    echo "ik = ${ik}"
    kptline_1=$(echo $ik $NumofBands_1 | awk '{print ($1-1)*($2+1)+1}')
    eqpline_start_1=$(echo $kptline_1 | awk '{print $1+1}')
    eqpline_end_1=$(echo $kptline_1 $NumofBands_1 | awk '{print $1+$2}')

    kptline_2=$(echo $ik $NumofBands_2 | awk '{print ($1-1)*($2+1)+1}')
    eqpline_start_2=$(echo $kptline_2 | awk '{print $1+1}')
    eqpline_end_2=$(echo $kptline_2 $NumofBands_2 | awk '{print $1+$2}')

    sed -n "${kptline_1} p" $EQPFile_1
    sed -n "${kptline_2} p" $EQPFile_2

    sed -n "${kptline_1} p" $EQPFile_1 | awk -v TotBnd="${NumofTotalBands}" '{printf("%17.9f %17.9f %17.9f  %8d \n",$1,$2,$3,TotBnd)}' >> ${EQPoutputFile}
    sed -n "${eqpline_start_1}, ${eqpline_end_1} p" $EQPFile_1 >> ${EQPoutputFile}
    sed -n "${eqpline_start_2}, ${eqpline_end_2} p" $EQPFile_2 >> ${EQPoutputFile}

done

echo "================================================="
