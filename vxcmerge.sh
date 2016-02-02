#!/bin/bash
NumofFiles=4
if [ -f "vxc.dat" ]; then
   rm -f vxc.dat
fi

for ((i=1;i<=$NumofFiles;i++))
do
  cat P_${i}/vxc_P${i}.dat >> ./vxc.dat
done
