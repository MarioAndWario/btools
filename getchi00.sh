#!/bin/bash
if [ $# -gt 0 ]; then
    file=$1
else
    file="kdf.out"
fi

fileout="chi00.txt"

grep '(  G =     0    0    0, Gp =     0    0    0 )' ${file} | awk '{print $14,$15}' > ${fileout}
