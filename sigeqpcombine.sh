#!/bin/bash
# This script will combine eqp1.dat from split Kpoints directories

EqpFile="eqp1.dat"
JobStart=1
JobEnd=15
rm -rf "eqp1_combo.dat"
touch "eqp1_combo.dat"
Seq="1 2 3 4 5 6 7 8 9 10 11a 11b 12 13 14 15 16 17 18 19 20 21 22 23a 23b 24a 24b 25a 25b 26a 26b 27a 27b 28a 28b 29a 29b 30a 30b 31a 31b 32 33a 33b 34a 34b 35a 35b 36a 36b"
#for ((ijob=${JobStart};ijob<=${JobEnd};ijob++))
for ijob in ${Seq}
do
    DirName="K_${ijob}"
    numofqpts=$(wc -l ${DirName}/eqp1.dat | awk '{print $1/25}')
    echo "K_${ijob} = ${numofqpts}"
    cat "${DirName}/eqp1.dat" >> eqp1_combo.dat
done