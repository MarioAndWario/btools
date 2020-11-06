#!/bin/bash -l
# This script use two broadening's and their corresponding eqp.dat file to extrapolate eqp.dat at zero-broadening!

file="eqp1_R.dat"
broadening1=0.3
broadening2=0.4
dir1="../d0.4_b0.3/sig/KP_tot"
dir2="../d0.4_b0.4/sig/KP_tot"

EQPoutputFile="eqp1_R.zero_Broadening.dat"
rm -rf $EQPoutputFile

file1="${dir1}/${file}"
file2="${dir2}/${file}"

echo "file1 = $file1"
echo "file2 = $file2"

echo "================ For file1  ===================="
NumofBands_1=$(sed -n '1p' $file1 | awk '{print $4}')
NumofLines_1=$(wc -l $file1 | awk '{print $1}')
#echo "Number of Lines : ${NumofLines}"
NumofKpts_1=$(echo ${NumofLines_1} ${NumofBands_1} | awk '{print $1/($2+1)}')
echo "Number of bands for each kpoint : ${NumofBands_1}"
echo "Number of kpoints : ${NumofKpts_1}"
echo "================ For file2  ===================="
NumofBands_2=$(sed -n '1p' $file2 | awk '{print $4}')
NumofLines_2=$(wc -l $file2 | awk '{print $1}')
#echo "Number of Lines : ${NumofLines}"
NumofKpts_2=$(echo ${NumofLines_2} ${NumofBands_2} | awk '{print $1/($2+1)}')
echo "Number of bands for each kpoint : ${NumofBands_2}"
echo "Number of kpoints : ${NumofKpts_2}"
echo "================================================="
if [ ${NumofKpts_2} != ${NumofKpts_1} ]; then
   echo "NumofKpts mismatch!"
   exit 1
fi
if [ ${NumofBands_2} != ${NumofBands_1} ]; then
   echo "NumofBands mismatch!"
   exit 1
fi

paste $file1 $file2 > temp.eqp.dat

for ((ik=1;ik<=${NumofKpts_1};ik++))
do
    echo "ik = ${ik}"
    kptline=$(echo $ik $NumofBands_1 | awk '{print ($1-1)*($2+1)+1}')
    eqpline_start=$(echo $kptline | awk '{print $1+1}')
    eqpline_end=$(echo $kptline $NumofBands_1 | awk '{print $1+$2}')
    #echo ${eqpline_start}
    #echo ${eqpline_end}

    sed -n "${kptline} p" $file1 | awk '{printf("%17.9f %17.9f %17.9f  %8d \n",$1,$2,$3,$4)}' >> ${EQPoutputFile}
    
    sed -n "${eqpline_start}, ${eqpline_end} p" temp.eqp.dat | awk -v b1="${broadening1}" -v b2="${broadening2}" '{printf("%8d %8d %15.6f %15.6f \n",$1,$2,$3,$4-b1*($4-$8)/(b1-b2))}' >> ${EQPoutputFile}
done
