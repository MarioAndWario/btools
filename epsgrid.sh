#!/bin/bash
inputfile="out.kgrid"
sed -n "4,$ p" $inputfile | awk '{printf ("%2.9f \t %2.9f \t %2.9f \t %1.1f \t %i \n",$1,$2,$3,1,0)}' > out.epsgrid
