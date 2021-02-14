#!/bin/bash
#This script will recursively delete every prefix.wfc*, prefix.igk* and prefix.save/K* in current directory.

find . -type f -name "eps0mat.h5" -exec rm -f {} \;
find . -type f -name "epsmat.h5" -exec rm -f {} \;
find . -type f -name "eps0mat.2.h5" -exec rm -f {} \;
find . -type f -name "epsmat.2.h5" -exec rm -f {} \;
find . -type f -name "chi0mat.h5" -exec rm -f {} \;
find . -type f -name "chimat.h5" -exec rm -f {} \;
find . -type f -name "chi0mat_*.h5" -exec rm -f {} \;
find . -type f -name "chimat_*.h5" -exec rm -f {} \;
find . -type f -name "chi0mat.2.h5" -exec rm -f {} \;
find . -type f -name "chimat.2.h5" -exec rm -f {} \;
find . -type f -name "mdat.h5" -exec rm -f {} \;
find . -type f -name "WFN" -exec rm -f {} \;
find . -type f -name "WFNq" -exec rm -f {} \;
find . -type f -name "WFNmq" -exec rm -f {} \;
find . -type f -name "WFN.h5" -exec rm -f {} \;
find . -type f -name "WFNq.h5" -exec rm -f {} \;
find . -type f -name "WFNmq.h5" -exec rm -f {} \;
find . -type f -name "bsemat.h5" -exec rm -f {} \;
