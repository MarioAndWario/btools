#!/bin/bash
# This script will combine eqp1.dat from split Kpoints directories
EqpFile="eqp1_noSR.dat"
EqpFileCombo="eqp1_noSR.dat"
CurrentDir=$(pwd)
JobStart=1
JobEnd=10
rm -rf ${EqpFileCombo}
touch ${EqpFileCombo}
#for ijob in ${Seq}
for ((ijob=${JobStart};ijob<=${JobEnd};ijob++))
do
    DirName="../KP${ijob}"
    cd ${DirName}
    echo "Within Directory: $(pwd)"
    geteqpdat_FF_noSR.V4.0.sh
    cd ${CurrentDir}
    FileName="${DirName}/${EqpFile}"
    NumofBands=$(sed -n '1p' $FileName | awk '{print $4}')
    NumofLines=$(wc -l $FileName | awk '{print $1}')
    Nk_KP=$(wc -l "../klib/KP${ijob}" | awk '{print $1}')
    #echo "Number of Lines : ${NumofLines}"
    NumofKpts=$(echo ${NumofLines} ${NumofBands} | awk '{print $1/($2+1)}')
    echo "--------------------------------"
    echo "KP${ijob} : Nk found in eqp.dat = ${NumofKpts} ; Expected Nk = ${Nk_KP}"
    if [ ${NumofKpts} -ne ${Nk_KP} ]; then
        echo "Nk mismatch. Exit..."
        exit 1
    fi
    cat ${FileName} >> ${EqpFileCombo}
    echo "================================"
done
