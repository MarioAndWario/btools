#!/bin/bash

# This script will read out eqp1.dat from sigma_hp.log
# Version 2.0
# 201700228
# can handle two cases:
# 1) Sigma finishes with no error
# 2) Sigma not finished with time out
# 3) calculate the mean of eqp1 and eqp1p
SigLog="sigma_hp.log"

Output0Prime="eqp0_noSR.dat"
Output1Prime="eqp1_noSR.dat"
Output0="eqp0_SR.dat"
Output1="eqp1_SR.dat"

rm -rf ${Output0Prime} ${Output1Prime} ${Output0} ${Output1}

# Get number of kpoints

kstartline=$(grep -n 'k = ' ${SigLog} | head -n 1 | awk -F ":" '{print $1}')

echo "$kstartline"

k2line=$(grep -n 'k =  ' ${SigLog} | head -n 2 | tail -n 1 | awk -F ":" '{print $1}')

if [ $kstartline == $k2line ]; then
k2line=$(grep -n 'n = band index' ${SigLog} | awk -F ":" '{print $1-3}')
fi

echo "$k2line"

if [ -z "$(grep -n 'n = band index' sigma_hp.log)" ]; then
    TotalLine=$(wc -l ${SigLog} | awk '{print $1}')
else
    TotalLine=$(grep -n 'n = band index' sigma_hp.log | awk -F ":" '{print $1-4}')
fi
echo "TotalLine = ${TotalLine}"

Step=$(echo ${k2line} ${kstartline} | awk '{print $1-$2}')

NumofBands=$(echo ${kstartline} ${k2line} | awk '{print ($2-$1-4)}')

NumofKpts=$(echo ${TotalLine} ${kstartline} ${k2line} | awk '{print ($1-$2+1)/($3-$2)}')

echo "Number of kpoints : $NumofKpts"

echo "Number of bands : $NumofBands"

for ((i=1;i<=${NumofKpts};i++))
do
    kptline=$(echo "${kstartline}+($i-1)*${Step}" | bc)
    startline=$(echo "${kstartline}+($i-1)*${Step}+3" | bc)
    endline=$(echo "$startline + $Step - 5" | bc)

    # echo "startline= $startline"
    # echo "endline = $endline"

    # eqp0.dat
    echo $(sed -n "${kptline} p" ${SigLog}) ${NumofBands} | awk '{printf("%12.9f %12.9f %12.9f %6d \n",$3,$4,$5,$12)}' >> ${Output0}
    sed -n "${startline}, ${endline} p" ${SigLog} | awk '{printf("%8d  %8d  %15.6f %15.6f \n", 1, $1, $2, $9)}' >> ${Output0}

    # eqp1.dat
    echo $(sed -n "${kptline} p" ${SigLog}) ${NumofBands} | awk '{printf("%12.9f %12.9f %12.9f %6d \n",$3,$4,$5,$12)}' >> ${Output1}
    sed -n "${startline}, ${endline} p" ${SigLog} | awk '{printf("%8d  %8d  %15.6f %15.6f \n", 1, $1, $2, $10)}' >> ${Output1}   
    
    # eqp0'.dat
    echo $(sed -n "${kptline} p" ${SigLog}) ${NumofBands} | awk '{printf("%12.9f %12.9f %12.9f %6d \n",$3,$4,$5,$12)}' >> ${Output0Prime}
    sed -n "${startline}, ${endline} p" ${SigLog} | awk '{printf("%8d  %8d  %15.6f %15.6f \n", 1, $1, $2, $13)}' >> ${Output0Prime}

    # eqp1'.dat
    echo $(sed -n "${kptline} p" ${SigLog}) ${NumofBands} | awk '{printf("%12.9f %12.9f %12.9f %6d \n",$3,$4,$5,$12)}' >> ${Output1Prime}
    sed -n "${startline}, ${endline} p" ${SigLog} | awk '{printf("%8d  %8d  %15.6f %15.6f \n", 1, $1, $2, $14)}' >> ${Output1Prime}   
done

# Get number of bands
