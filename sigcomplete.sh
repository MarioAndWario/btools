#!/bin/bash
# This script will distribute kpoints list into sigma.inp and prepare the directories

ProtoDir="proto"
InputFile="sigma.inp"
JobStart=1
JobEnd=32
for ((ijob=${JobStart};ijob<=${JobEnd};ijob++))
do
    DirName="K_${ijob}"
    if [ -d ${DirName} ]; then
        cd ${DirName}
        if [ -f "sig.out" ]; then
            flag_complete=$(grep -i "TOTAL:" sig.out)
            if [ -z "$flag_complete" ]; then
                echo "[Failed] ${DirName}"
            else
                echo "[Complete] ${DirName}"
            fi

        else
            echo "[TODO] ${DirName}"
        fi
        cd ..
    else
        echo "[TODO] ${DirName}"
    fi
done