#!/bin/bash -l

#SBATCH --job-name=BGW
#SBATCH -p development
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 00:10:00
#SBATCH -A DMR20007

module unload phdf5
module unload impi
module load hdf5

# This script calls epsmat_hdf5_merge.py to merge all the chimat_eh.[x].h5 files
# Number of q1 vectors
q_start=1
q_end=25
nb=1
prefix="eels"
surfix="_reducible"
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
        sed -n '6,$ p' ${DIRNAME}/eigenvalues_2_b1.dat > temp1
        paste temp0 temp1 > eigenvalues_allq.txt
    done
    cd ${CURRENTDIR}
done
