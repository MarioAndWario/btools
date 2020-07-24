#!/bin/bash
# This script will combine eqp1.dat from split Kpoints directories
EqpFile="eqp1_noSR.dat"
EqpFileCombo="eqp1_combo.dat"
JobStart=1
JobEnd=10
rm -rf ${EqpFileCombo}
touch ${EqpFileCombo}
#for ijob in ${Seq}
for ((ijob=${JobStart};ijob<=${JobEnd};ijob++))
do
    DirName="../KP${ijob}"    
    FileName="${DirName}/${EqpFile}"
    NumofBands=$(sed -n '1p' $FileName | awk '{print $4}')
    NumofLines=$(wc -l $FileName | awk '{print $1}')
    #echo "Number of Lines : ${NumofLines}"
    NumofKpts=$(echo ${NumofLines} ${NumofBands} | awk '{print $1/($2+1)}')
    echo "KP${ijob} = ${NumofKpts}"
    cat ${FileName} >> eqp1_combo.dat
done
