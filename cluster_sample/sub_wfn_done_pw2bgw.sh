#!/bin/bash
# This script will distribute kpoints "kpoints_sub_*.dat" into each WFN_* directory
# copied from proto

ProtoDir="proto"
LIBK="libK"
JobStart=1
JobEnd=324

for ((ijob=${JobStart};ijob<=${JobEnd};ijob++))
do
    DirName="WFN_${ijob}"
    if [ ! -d ${DirName} ]; then
        echo "========================"
        echo "${DirName} not exists"
        exit 2
    fi

    echo "Check ${DirName} pw2bgw.out"
    cd ${DirName}

    if [ -z "$(grep 'JOB DONE' pw2bgw.out)" ]; then
        echo "========================"
        echo "${DirName} not finished."
        exit 1
    fi

    cd ..
done

echo "============="
echo "All finished!"
