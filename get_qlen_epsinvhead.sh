#!/bin/bash
file="ce0.out"
grep '|q|' $file | awk '{print $3}' > qlen.txt
grep 'Eps(' $file | awk '{print $5}' > epshead.txt
grep 'Epsinv' $file | awk '{print $5}' > epsinvhead.txt

file="ce1.out"
grep '|q|' $file | awk '{print $3}' >> qlen.txt
grep 'Eps(' $file | awk '{print $5}' >> epshead.txt
grep 'Epsinv' $file | awk '{print $5}' >> epsinvhead.txt
