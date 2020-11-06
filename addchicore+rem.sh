#!/bin/bash
#SBATCH -J EPSQ0
#SBATCH -p development
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH -A DMR20007

module unload phdf5
module unload impi
module load hdf5

# This script calls epsmat_hdf5_merge.py to merge all the chimat_eh.[x].h5 files
# Number of q1 vectors
FILE="chi0mat"
python3 ~/software/BGW/BGW_spinor/Epsilon3/addskipchimat.py -f ${FILE}_core.h5 -F ${FILE}_rem.h5 -O ${FILE}.h5
FILE="chimat"
python3 ~/software/BGW/BGW_spinor/Epsilon3/addskipchimat.py -f ${FILE}_core.h5 -F ${FILE}_rem.h5 -O ${FILE}.h5
