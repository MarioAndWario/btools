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

python3 ~/bin/btools/correctepshead.py
