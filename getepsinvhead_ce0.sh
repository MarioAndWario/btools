#!/bin/bash
file="ce0.out"

nrealfreq=$(grep 'Real-axis frequencies' ${file} | awk '{print $5}')
nimagfreq=$(grep 'Imaginary-axis frequencies' ${file} | awk '{print $5}')

freqstartline=$(grep -n 'Inverting epsilon matrix' ${file} | head -n 1 | awk -F ":" '{print $1+1}')
#echo "$freqstartline"

if [ -z $nrealfreq ]; then
    echo "No real-axis frequencies."
    nrealfreq=0
else
    realfreqendline=$(echo "$freqstartline+$nrealfreq-1" | bc)
    #echo "$realfreqendline"
    echo "Outputing $nrealfreq epsinv at real-axis frequencies to epsinvhead2_real.txt"
    sed -n "${freqstartline}, ${realfreqendline} p" ${file} | awk '{printf("   %22.15e   %22.15e\n", $7,$8)}' > epsinvhead2_real.txt    
fi

if [ -z $nimagfreq ]; then
    echo "No imaginary-axis frequencies."
    nimagfreq=0
else
    imagfreqstartline=$(echo "$freqstartline+$nrealfreq" | bc)
    #echo "$imagfreqstartline"
    imagfreqendline=$(echo "$imagfreqstartline+$nimagfreq-1" | bc)
    #echo "$imagfreqendline"

    echo "Outputing $nimagfreq epsinv at imaginary-axis frequencies to epsinvhead2_imag.txt"    
    sed -n "${imagfreqstartline}, ${imagfreqendline} p" ${file} | awk '{printf("   %22.15e   %22.15e\n", $7,$8)}' > epsinvhead2_imag.txt    
fi

