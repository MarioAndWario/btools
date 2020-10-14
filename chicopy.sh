#!/bin/bash

#SBATCH --job-name=BGW
#SBATCH -p development
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 00:10:00
#SBATCH -A DMR20007

# This script calls epsmat_hdf5_merge.py to merge all the chimat_eh.[x].h5 files
# Number of q1 vectors
q_start=0
q_end=29
nb=2
prefix="triplet"
surfix="transfer"
FILEQ1="q1list.dat"
nq1=$(wc -l ${FILEQ1} | awk '{print $1}')
CURRENTDIR=$(pwd)
echo "In total ${nq1} q1 vectors"

for ((ib=1;ib<=${nb};ib++))
do
    CHIDIR="chilib_${surfix}_${prefix}_b${ib}"
    if [ -d ${CHIDIR} ]; then
        echo "${CHIDIR} exists."
    else
        mkdir ${CHIDIR}
    fi
    cd ${CHIDIR}
    # Loop over all the q1 vectors
    for ((iq1=${q_start};iq1<=${q_end};iq1++))
    do
        DIRNAME="${prefix}_q${iq1}"
        if [ $iq1 == 0 ]; then
            cp ../${DIRNAME}/chi0mat_eh_FF_b${ib}.h5 ./chi0mat_eh.h5
        else
            cp ../${DIRNAME}/chimat_eh_FF_b${ib}.h5 ./chimat_eh.${iq1}.h5
        fi
    done
    cd ${CURRENTDIR}
done
