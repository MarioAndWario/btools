#!/bin/bash
inputfile="rk.dat"
nrk=$(wc -l ${inputfile} | awk '{print $1-2}')
echo "nrk = $nrk"

sed -n "3,$ p" $inputfile | awk '{printf ("%2.9f \t %2.9f \t %2.9f \t %1.1f \t %i \n",$1,$2,$3,1,0)}' > out.epsgrid
sed -n "3,$ p" $inputfile | awk '{printf ("%2.9f \t %2.9f \t %2.9f \t %i \n",$1,$2,$3,1)}' > out.ccgrid

#rm -rf geninterp.kpt
echo "general kpoint interpolation" > geninterp.kpt
echo "crystal" >> geninterp.kpt
echo "${nrk}" >> geninterp.kpt
sed -n "3,$ p" $inputfile | awk '{printf ("%10d \t %2.9f \t %2.9f \t %2.9f \t %i \n",NR,$1,$2,$3,1)}' >> geninterp.kpt
