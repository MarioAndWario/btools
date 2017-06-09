#!/bin/bash
# This script will distribute kpoints "kpoints_sub_*.dat" into each WFN_* directory 
# copied from proto

ProtoDir="proto"
LIBK="libK"
JobStart=2
JobEnd=10

for ((ijob=${JobStart};ijob<=${JobEnd};ijob++))
do
    DirName="WFN_${ijob}"
    if [ -d ${DirName} ]; then
       echo "${DirName} exists! q: quit, d: delete ?"
       read DELflag
       if [ ${DELflag} == "d" ]; then
          echo "Remove ${DirName}"
          rm -rf ${DirName}
       else
          echo "Exit ..."
          exit 2
       fi
    fi
    cp -r ${ProtoDir} ${DirName}
    cd ${DirName}   
    cp ../../${LIBK}/kpoints_sub_${ijob}.dat ./KP.q
    #sbatch subqe.sh
    cd ..
done
