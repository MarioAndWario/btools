#!/bin/bash
# This script will distribute kpoints "kpoints_sub_*.dat" into each WFN_* directory
# copied from proto

ProtoDir="proto"
LIBK="libK"
JobStart=1
JobEnd=324

for ((ijob=${JobStart};ijob<=${JobEnd};ijob++))
do
    DirName="Kernel_${ijob}"
    if [ ! -d ${DirName} ]; then
        echo "========================"
        echo "${DirName} not exists"
        exit 2
    fi

    echo "Check ${DirName} ker.out"
    cd ${DirName}

    if [ -z "$(grep 'TOTAL:' ker.out)" ]; then
        echo "========================"
        echo "${DirName} not finished."
        exit 1
    fi

    cd ..
done

echo "============="
echo "All finished!"
