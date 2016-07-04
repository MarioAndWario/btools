#!/bin/bash
EpsilonInputFile="epsilon.inp"
EpsilonOutputFile="chi_converge.dat"
NumofConductionBands=$(grep "band_occupation" $EpsilonInputFile | awk '{print $3}' | awk -F"*" '{print $1}' )
echo "number of conduction bands = $NumofConductionBands"
Numofqpoints=$(sed -n "/begin qpoints/,/end/ p" $EpsilonInputFile | wc -l | awk '{print $1-2}')
echo "number of qpoints = $Numofqpoints"

step=$(echo $NumofConductionBands | awk '{print $1+3}' )
for ((i=0;i<$Numofqpoints;i++))
do
    startline=$(echo $i $step | awk '{print $1*$2+1}')
    endline=$(echo $startline $step | awk '{print $1+$2-2}')
    sed -n "$startline, $endline p" $EpsilonOutputFile > Q${i}_chi_converge.dat
    echo -n "="
done
echo ""
echo "===============Finished=============="
