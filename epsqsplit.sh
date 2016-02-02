#!/bin/bash
INPUT_subsample="epsilon_q0s.inp"
INPUT_WFN="out.epsgrid"
Q0file="q0pt.dat"
Qfile="qpt.dat"
ComboQfile="Qpt.dat"
LOGFILE="qgrid.log"
OUTPUTPREFIX="QP"
############################################
rm -rf $OUTPUTPREFIX*
############################################
#Combine the two files
sed -n '1,${1,/begin/{d};/end/,${d};p}' ${INPUT_subsample} | awk '{printf(" %1.15E  %1.15E  %1.15E  %d  %d\n",$1,$2,$3,$4,$5)}' > ${Q0file}
cat ${INPUT_WFN} | awk '{printf(" %1.15E  %1.15E  %1.15E  %d  %d\n",$1,$2,$3,1,0)}' > ${Qfile}
cat ${Q0file} ${Qfile} > ${ComboQfile}

numofq0pts=$(wc -l $Q0file | awk '{print $1}')
numofqpts=$(wc -l $Qfile | awk '{print $1}')
numofQpts=$(wc -l $ComboQfile | awk '{print $1}')
echo "Number of q0points = $numofq0pts "
echo "Number of wfn qpoints = $numofqpts"
echo "Total number of qpoints = $numofQpts"

if [ ! -z $1  ]; then
   numofqpt1=$1
else
   echo "Please input the required number of kpts per file: "
   read numofqpt1
fi
numoffiles=$( echo $numofQpts $numofqpt1 | awk '{print int($1/$2)}' )
numofqpt2=$( echo $numofQpts $numoffiles $numofqpt1 | awk '{print $1-$2*$3}' )

if [ $numofqpt2 == 0 ]
then
   DevFlag=1
   echo "The number of total qpts ( $numofQpts ) are dividable by the number of files ($numoffiles) : $numofQpts = $numoffiles * $numofqpt1  "
   echo "The number of total qpts ( $numofQpts ) are dividable by the number of files ($numoffiles) : $numofQpts = $numoffiles * $numofqpt1  " > $LOGFILE
else
   DevFlag=0
   echo "The number of total kpts ( $numofQpts ) are NOT dividable by the number of files ($numoffiles) : $numofQpts = $numoffiles * $numofqpt1 + $numofqpt2"
   echo "The number of total kpts ( $numofQpts ) are NOT dividable by the number of files ($numoffiles) : $numofQpts = $numoffiles * $numofqpt1 + $numofqpt2" > $LOGFILE
   numoffiles=$(echo "$numoffiles+1" | bc)
fi

echo "Number of files : $numoffiles "
for ((i=1;i<$numoffiles;i++))
do
   startline=$(echo $i $numofqpt1 | awk '{print ($1-1)*$2+1}')
   endline=$(echo $i $numofqpt1 | awk '{print $1*$2}')
  #echo $startline $endline
  #echo $numofqpt1 > ${OUTPUTPREFIX}$i
   sed -n "$startline, $endline p" $ComboQfile >> ${OUTPUTPREFIX}$i
done

if [ $numoffiles -gt 1 ];then
##Special treatment of the last file
   startline=$(echo $numoffiles $numofqpt1 | awk '{print ($1-1)*$2+1}')
  # if [ $DevFlag -eq 1 ]; then
  #    echo $numofqpt1 > ${OUTPUTPREFIX}$i
  # else
  #    echo $numofqpt2 > ${OUTPUTPREFIX}$i
  # fi
   sed -n "$startline, \$ p" $ComboQfile >> ${OUTPUTPREFIX}${numoffiles}
else
if [ $numoffiles -eq 1 ]; then
#Only one file
   startline=$(echo $numoffiles $numofqpt1 | awk '{print ($1-1)*$2+1}')
   #echo $numofqpt1 > ${OUTPUTPREFIX}1
   #echo $numofqpt1
   sed -n "$startline, \$ p" $ComboQfile >> ${OUTPUTPREFIX}1
fi
fi
#Write log
echo "Number of files = $numoffiles" >> $LOGFILE
