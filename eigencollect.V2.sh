#!/bin/bash -l
# This script calls epsmat_hdf5_merge.py to merge all the chimat_eh.[x].h5 files
# Number of q1 vectors
q_start=1
q_end=41
nb=1
prefix="eels"
FILEQ1="q1list.dat"
nq1=$(wc -l ${FILEQ1} | awk '{print $1}')
CURRENTDIR=$(pwd)
echo "In total ${nq1} q1 vectors"

for ((ib=1;ib<=${nb};ib++))
do
    rm -rf eigenvalues_allq.txt
    touch eigenvalues_allq.txt
    # Loop over all the q1 vectors
    for ((iq1=${q_start};iq1<=${q_end};iq1++))
    do
        DIRNAME="${prefix}_q${iq1}"
        cp eigenvalues_allq.txt temp0
        sed -n '7,$ p' ${DIRNAME}/eigenvalues_vrhoc_eh.dat | awk '{print $1}' > temp1
        paste temp0 temp1 > eigenvalues_allq.txt
    done
    cd ${CURRENTDIR}
done
