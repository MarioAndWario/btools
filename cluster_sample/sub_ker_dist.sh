#!/bin/bash
# This script will distribute kpoints "kpoints_sub_*.dat" into each WFN_* directory 
# copied from proto

ProtoDir="proto"
LIBK="libK"
JobStart=271
JobEnd=324

#eps0Dir="../../../../2x2x1/eps/Total"

for ((ijob=${JobStart};ijob<=${JobEnd};ijob++))
do
    DirName="Kernel_${ijob}"
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
    ln -s ../../WFN_sub/WFN_${ijob}/WFN ./WFN_co
    # ln -s ../../eps_sub/eps0mat_sub.h5 ./epsmat.h5
    # ln -s ${eps0Dir}/eps0mat.h5 ./eps0mat.h5
    cd ..
done
