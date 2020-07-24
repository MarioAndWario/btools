#!/bin/bash
#This script will recursively delete every prefix.wfc*, prefix.igk* and prefix.save/K* in current directory.

find . -type f -name "eps0mat.h5" -exec rm -f {} \;
find . -type f -name "epsmat.h5" -exec rm -f {} \;
find . -type f -name "WFN" -exec rm -f {} \;
find . -type f -name "WNFq" -exec rm -f {} \;
find . -type f -name "bsemat.h5" -exec rm -f {} \;
