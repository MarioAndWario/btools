#!/bin/bash
# This script will combine eqp1.dat from split Kpoints directories

EqpFile="eqp1.dat"
JobStart=1
JobEnd=15
rm -rf "eqp1_combo.dat"
touch "eqp1_combo.dat"
Seq="1 2 3 4 5 6 7 8 9 10 11a 11b 11c 12 13 14 15"
#for ((ijob=${JobStart};ijob<=${JobEnd};ijob++))
for ijob in ${Seq}
do
    DirName="K_${ijob}"
    cat "${DirName}/eqp1.dat" >> eqp1_combo.dat
done