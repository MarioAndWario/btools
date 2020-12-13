#!/bin/bash -l

#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --time=00:30:00
#SBATCH --job-name=MW
#SBATCH -C haswell

#export OMP_NUM_THREADS=1

# This script calls epsmat_hdf5_merge.py to merge all the chimat_eh.[x].h5 files

# Number of q1 vectors
nq1_start=1
nq1_end=29
filestring=$(seq -s " " -f "chimat_eh.%g.h5" ${nq1_start} ${nq1_end})

echo ${filestring}

python ~/bin/btools/epsmat_hdf5_merge_V2.py -o chimat_eh.h5 ${filestring}
