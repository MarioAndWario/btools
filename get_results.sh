#!/bin/bash

NBList="$(seq 200 200 1400)"
ECList_="$(seq 5 5 30)"
#NBList="$(seq 500 500 500)"
#ECList_="$(seq 10 10 10)"

surfix="R"
OUTPUT="eqp1_${surfix}.dat"
DirCurrent=$(pwd)
FileResults="${DirCurrent}/Eg_${surfix}.dat"
echo $FileResults

rm -rf ${FileResults}
echo "Column --> NBList: ${NBList}" >> ${FileResults}
echo "Row --> ECList: ${ECList_}" >> ${FileResults}
for nb in $NBList
do
    for ec_ in $ECList_
    do
        #float number
        ec=$(echo ${ec_} | awk '{printf("%5.1f", $1)}')
        echo "+ nb = $nb, ec = $ec"
        DirName="${ec_}Ry_${nb}b"
        cd ${DirName}
        geteqpdat_FF_R.V4.0.sh
	
        # line=$(echo ${Eindex}+1 | bc)
	# #echo "$line"
	# #echo $(pwd)
	# #echo ${FileResults}
	# sed -n "${line} p" ${OUTPUT} | awk '{printf("%16.9f ",$4)}' >> ${FileResults}
        # # echo "============================="
        E1=$(sed -n "5 p" ${OUTPUT} | awk '{print $4}')
        E2=$(sed -n "6 p" ${OUTPUT} | awk '{print $4}')
        echo ${E1} ${E2} | awk '{printf("%15.6f",$2-$1)}' >> ${FileResults}
        # echo $E1 $E2
        echo "============================="

        cd ${DirCurrent}
    done
    echo " " >> ${FileResults}
done
