#!/bin/bash
# This script will distribute kpoints list into sigma.inp and prepare the directories

ProtoDir="K_proto"
InputFile="sigma.inp"
JobStart=2
JobEnd=8
for ((ijob=${JobStart};ijob<=${JobEnd};ijob++))
do
    DirName="K_${ijob}"
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
    # startline=$(grep -n 'begin kpoints' sigma.inp  | awk -F":" '{print $1+1}')
    sed -i "/begin kpoints/r ../klib/KP${ijob}" ${InputFile}
    sbatch subsig.sh
    cd ..
done