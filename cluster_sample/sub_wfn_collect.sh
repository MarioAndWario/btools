#!/bin/bash
# This script will distribute kpoints list into sigma.inp and prepare the directories

ProtoDir="proto"
LIBK="libK"
KERmergeDir="wfn_lib"
JobStart=1
JobEnd=324

if [ ! -d ${KERmergeDir} ]; then
   mkdir ${KERmergeDir}
fi

for ((ijob=${JobStart};ijob<=${JobEnd};ijob++))
do
    DirName="WFN_${ijob}"
    if [ ! -d ${DirName} ]; then
       echo "${DirName} does not exist!"
       exit
    else
    ln -sf ../${DirName}/WFN ./${KERmergeDir}/WFN.${ijob}
    fi
done
