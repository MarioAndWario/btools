#!/bin/bash

FILENAME="eigenvalues_vrhoc_noeh.dat"
FILENAME_SORT="eigenvalues_vrhoc_noeh.sorted.dat"
TEMP1="header"
TEMP2="sorted"

sed -n '1,6 p' ${FILENAME} > ${TEMP1}

sed -n '7,$ p' ${FILENAME} | sort -g > ${TEMP2}

cat ${TEMP1} ${TEMP2} > ${FILENAME_SORT}

rm -rf ${TEMP1} ${TEMP2}
