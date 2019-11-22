#!/bin/bash

# This script calls epsmat_hdf5_merge.py to merge all the chimat_eh.[x].h5 files

# Number of q1 vectors
nq1_start=1
nq1_end=28
filestring=$(seq -s " " -f "chimat_eh.%g.h5" ${nq1_start} ${nq1_end})

python epsmat_hdf5_merge.py -o chimat_eh.h5 ${filestring}
