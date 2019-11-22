#!/bin/bash

OriSubFile="subsample.inp"
OutSubFile="subsample.out.inp"

cp ${OriSubFile} ${OutSubFile}

NumofFiles=324
# Add bsemat.h5 files path

WFNPathPrefix="../../WFN_sub/wfn_lib"

KERPathPrefix="../../ker_sub/ker_lib"

for ((ifile=1;ifile<=${NumofFiles};ifile++))
do
    echo "${KERPathPrefix}/bsemat.${ifile}.h5" >> ${OutSubFile}
done

# Add WFN files path

for ((ifile=1;ifile<=${NumofFiles};ifile++))
do
    echo "${WFNPathPrefix}/WFN.${ifile}" >> ${OutSubFile}
done
