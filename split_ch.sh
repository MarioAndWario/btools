#!/bin/bash
chfile="ch_converge.dat"
sigmainput="sigma.inp"
NumofBands=$(grep "number_bands" $sigmainput | awk '{print $2}')
NumofKpoints=$(sed -n "/begin kpoints/,/end/ p" $sigmainput | wc -l | awk '{print $1-2}')
Step=$(echo "$NumofBands+3" | bc )
for ((i=0;i<$NumofKpoints;i++))
do
  startline=$(echo "$i*$Step+1"| bc )
  endline=$(echo "$startline+$Step-1"| bc )
  #echo "startline = $startline"
  #echo "endline = $endline"
  sed -n "$startline,$endline p" $chfile  > K${i}_ch_converge.dat
done
