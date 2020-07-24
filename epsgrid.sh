#!/bin/bash
inputfile="rk.dat"
sed -n "3,$ p" $inputfile | awk '{printf ("%2.9f \t %2.9f \t %2.9f \t %1.1f \t %i \n",$1,$2,$3,1,0)}' > out.epsgrid
sed -n "3,$ p" $inputfile | awk '{printf ("%2.9f \t %2.9f \t %2.9f \t %i \n",$1,$2,$3,1)}' > out.ccgrid
