#!/bin/bash
#SBATCH -J PW
#SBATCH -N 1
#SBATCH -p RM
#SBATCH -t 02:00:00
#SBATCH --ntasks-per-node=1
#echo commands to stdout
#set -x
export OMP_NUM_THREADS=1
# export OMP_PROC_BIND=true
# export OMP_PLACES=threads
#export FORT_BUFFERED=TRUE

# module unload phdf5
# module unload impi
# module load hdf5

# This script calls epsmat_hdf5_merge.py to merge all the chimat_eh.[x].h5 files
# Number of q1 vectors
if [ $# -ne 2 ]; then
    echo "Usage sub_epsmerge.sh [iq_start] [iq_end] "
    exit 123
else
    iq_start=$1
    iq_end=$2
    echo "dir_header = ${dir_header}"
    echo "script = ${script}"
fi
echo "iq_start = $iq_start, iq_end = $iq_end"

for ((iq=${iq_start};iq<=${iq_end};iq++))
do
    DIRNAME="Q${iq}"
    ln -sf ../${DIRNAME}/eps0mat.h5 ./eps0mat.${iq}.h5
done

filestring=$(seq -s " " -f "eps0mat.%g.h5" ${iq_start} ${iq_end})
echo ${filestring}
~/bin/btools/epsmat_hdf5_merge_V2.py -o eps0mat.h5 ${filestring} > log
