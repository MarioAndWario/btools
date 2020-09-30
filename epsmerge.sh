#!/bin/bash
#SBATCH --job-name=MERGE
#SBATCH --partition=skx-dev
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --time=02:00:00
#SBATCH -A TG-MCA94P030

#module unload phdf5
#module unload impi
#module load hdf5

# This script calls epsmat_hdf5_merge.py to merge all the chimat_eh.[x].h5 files
# Number of q1 vectors
q_start=1
q_end=6
for ((iq=${q_start};iq<=${q_end};iq++))
do
    DIRNAME="Q${iq}"
    ln -sf ../${DIRNAME}/eps0mat.h5 ./eps0mat.${iq}.h5
done

filestring=$(seq -s " " -f "eps0mat.%g.h5" ${q_start} ${q_end})
echo ${filestring}
~/bin/btools/epsmat_hdf5_merge_V2.py -o eps0mat.h5 ${filestring} > log
