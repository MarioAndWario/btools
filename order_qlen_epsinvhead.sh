#!/bin/bash

file0="q0len_eps0invhead.txt"
file1="q1len_eps1invhead.txt"

file_combine="qlen_epsinvhead.txt"
file_combine_sorted="qlen_epsinvhead.sorted.txt"
cat ${file0} ${file1} > ${file_combine}

# Ordering according to qlen
echo "Sorting ${file_combine}"
sort -k 1 ${file_combine} > ${file_combine_sorted}
