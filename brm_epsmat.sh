#!/bin/bash
#This script will recursively delete every prefix.wfc*, prefix.igk* and prefix.save/K* in current directory.

find . -type f -name "eps0mat.h5" -exec rm -f {} \;
find . -type f -name "epsmat.h5" -exec rm -f {} \;
