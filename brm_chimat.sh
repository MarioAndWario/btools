#!/bin/bash
#This script will recursively delete every prefix.wfc*, prefix.igk* and prefix.save/K* in current directory.

find . -type f -name "chi0mat.h5" -exec rm -f {} \;
find . -type f -name "chimat.h5" -exec rm -f {} \;
