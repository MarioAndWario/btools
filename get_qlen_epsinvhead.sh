#!/bin/bash

file="ce0.out"
if [ -f ${file} ]; then
    grep 'q =' $file | awk '{print $6,$7,$8}' > q0.txt    
    grep '|q|' $file | awk '{print $3}' > q0len.txt
    grep 'Eps(' $file | awk '{print $5}' > eps0head.txt
    grep 'Epsinv' $file | awk '{print $5}' > eps0invhead.txt

    paste q0len.txt eps0invhead.txt > q0len_eps0invhead.txt
    paste q0.txt eps0invhead.txt > q0_eps0invhead.txt
else
    echo "${file} does not exist."
fi

file="ce1.out"
if [ -f ${file} ]; then
    grep 'q =' $file | awk '{print $6,$7,$8}' > q1.txt
    grep '|q|' $file | awk '{print $3}' > q1len.txt
    grep 'Eps(' $file | awk '{print $5}' > eps1head.txt
    grep 'Epsinv' $file | awk '{print $5}' > eps1invhead.txt

    paste q1len.txt eps1invhead.txt > q1len_eps1invhead.txt    
    paste q1.txt eps1invhead.txt > q1_eps1invhead.txt    
else
    echo "${file} does not exist."
fi


