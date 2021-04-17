#!/bin/bash
#SBATCH -J EPSQ0
#SBATCH -p development
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH -A DMR20007

# This script calls epsmat_hdf5_merge.py to merge all the chimat_eh.[x].h5 files
# Number of q1 vectors
q_start=1
q_end=41
prefix="eels_q"
dir="eels_collect"
filename="eigenvalues_vrhoc_eh.dat"
if [ -d ${dir} ]; then
    echo "${dir} exist."
else
    mkdir ${dir}
fi
cd ${dir}

for ((iq=${q_start};iq<=${q_end};iq++))
do
    DIRNAME="${prefix}${iq}"
    ln -sf ../${DIRNAME}/${filename} ./${filename}.${iq}
done
