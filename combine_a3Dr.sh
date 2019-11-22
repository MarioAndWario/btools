#!/bin/bash

# This script will combine two a3Dr files

File1=$1
File2=$2

Fileout="test.dat"

paste ${File1} ${File2} | sed -n '14,$p' | awk '{
if (!NF)
printf("\n");
else
printf("%10.5E  %10.5E\n",($1+$3)/2.0,($2+$4)/2.0)
}' > ${Fileout}
