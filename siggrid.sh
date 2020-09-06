#!/bin/bash
#inputfile="out.kgrid"
inputfile="rk.dat"
sed -n "3,$ p" $inputfile | awk '{printf ("%2.9f \t %2.9f \t %2.9f \t %1.1f \n",$1,$2,$3,1)}' > out.siggrid
