#!/bin/bash
#This script merge eps0mat.h5 and epsmat.h5 files
###############################################################
#Default: 1 to end
if [ $# -gt 3 ]; then
   echo "USAGE: pw2batch.sh [SUBFLAG:1=true,else=false] [StartIndex] [EndIndex] "
   exit 0
fi

echo "Number of kpoints file: $(sed -n '2 p' qptlib/qgrid.log | awk '{print $5}') "

if [ $# -eq 0 ];then
   echo "You are using the default setting:"
   SUBFLAG=1
   StartIndex=1
   EndIndex=$(sed -n '2 p' qptlib/qgrid.log | awk '{print $5}')
   echo "We are submitting jobs from $StartIndex to $EndIndex"
else
   if [ $# -eq 1 ];then
   SUBFLAG=$1
   StartIndex=1
   EndIndex=$(sed -n '2 p' qptlib/qgrid.log | awk '{print $5}')
   echo "We are submitting jobs from $StartIndex to $EndIndex"
   else
      if [ $# -eq 2 ]; then
	 SUBFLAG=$1
         StartIndex=$2
         EndIndex=$(sed -n '2 p' qptlib/qgrid.log | awk '{print $5}')
         echo "We are submitting jobs from $StartIndex to $EndIndex" 
      else
	 if [ $# -eq 3 ]; then
	    SUBFLAG=$1
            StartIndex=$2
            EndIndex=$3
            echo "We are submitting jobs from $StartIndex to $EndIndex" 
	 fi
      fi
   fi
fi
numoffiles=$(echo "$EndIndex-$StartIndex+1" | bc )

rm -rf merge_q0_all
rm -rf merge_q_all
mkdir merge_q0_all
mkdir merge_q_all
q0counter=1
qcounter=1
for ((i=$StartIndex;i<=$EndIndex;i++))
do
  cd P_${i}
  if [ -f eps0mat.h5 ];then
     echo "Found eps0mat in P_${i}. Linking it to directory merge_q0_all ..."
     ln -s ../P_${i}/eps0mat.h5 ../merge_q0_all/eps0mat.${q0counter}.h5
     q0counter=$(echo "$q0counter+1" | bc ) 
  fi
  
  if [ -f epsmat.h5 ];then
     echo "Found epsmat in P_${i}. Linking it to directory merge_q_all ..."
     ln -s ../P_${i}/epsmat.h5 ../merge_q_all/epsmat.${qcounter}.h5
     qcounter=$(echo "$qcounter+1" | bc )
  fi
  cd ..
done
###################################################
#Merge eps0mat
cd merge_q0_all
q0flag=" -o eps0mat.h5"
for ((i=1;i<$q0counter;i++))
do
    q0flag="${q0flag} eps0mat.$i.h5"
done
echo "q0Flag: $q0flag"
epsmat_hdf5_merge.py $q0flag
cd ..
ln -s -f merge_q0_all/eps0mat.h5 .
###################################################
#Merge epsmat
cd merge_q_all
qflag=" -o epsmat.h5"
for ((i=1;i<$qcounter;i++))
do
    qflag="${qflag} epsmat.$i.h5"
done
echo "qFlag: $qflag"
epsmat_hdf5_merge.py $qflag
cd ..
ln -s -f merge_q_all/epsmat.h5 .
