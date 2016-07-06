#!/bin/bash
INPUT_WFN="out.siggrid"
Qfile="Kpt.dat"
LOGFILE="kgrid.log"
OUTPUTPREFIX="KP"
############################################
rm -rf $OUTPUTPREFIX*
############################################
#Combine the two files
cat ${INPUT_WFN} | awk '{printf(" %10.9f  %10.9f  %10.9f  %2.1f \n",$1,$2,$3,1.0)}' > ${Qfile}

numofkpts=$(wc -l $Qfile | awk '{print $1}')
echo "Number of wfn qpoints = $numofkpts"

if [ ! -z $1  ]; then
    numofkpt1=$1
else
    echo "Please input the required number of kpts per file: "
    read numofkpt1
fi
numoffiles=$( echo $numofkpts $numofkpt1 | awk '{print int($1/$2)}' )
numofkpt2=$( echo $numofkpts $numoffiles $numofkpt1 | awk '{print $1-$2*$3}' )

if [ $numofkpt2 == 0 ]
then
    DevFlag=1
    echo "The number of total qpts ( $numofkpts ) are dividable by the number of files ($numoffiles) : $numofkpts = $numoffiles * $numofkpt1  "
    echo "The number of total qpts ( $numofkpts ) are dividable by the number of files ($numoffiles) : $numofkpts = $numoffiles * $numofkpt1  " > $LOGFILE
else
    DevFlag=0
    echo "The number of total kpts ( $numofkpts ) are NOT dividable by the number of files ($numoffiles) : $numofkpts = $numoffiles * $numofkpt1 + $numofkpt2"
    echo "The number of total kpts ( $numofkpts ) are NOT dividable by the number of files ($numoffiles) : $numofkpts = $numoffiles * $numofkpt1 + $numofkpt2" > $LOGFILE
    numoffiles=$(echo "$numoffiles+1" | bc)
fi

echo "Number of files : $numoffiles "
for ((i=1;i<$numoffiles;i++))
do
    startline=$(echo $i $numofkpt1 | awk '{print ($1-1)*$2+1}')
    endline=$(echo $i $numofkpt1 | awk '{print $1*$2}')
  #echo $startline $endline
  #echo $numofkpt1 > ${OUTPUTPREFIX}$i
    sed -n "$startline, $endline p" $Qfile >> ${OUTPUTPREFIX}$i
done

if [ $numoffiles -gt 1 ];then
##Special treatment of the last file
    startline=$(echo $numoffiles $numofkpt1 | awk '{print ($1-1)*$2+1}')
  # if [ $DevFlag -eq 1 ]; then
  #    echo $numofkpt1 > ${OUTPUTPREFIX}$i
  # else
  #    echo $numofkpt2 > ${OUTPUTPREFIX}$i
  # fi
    sed -n "$startline, \$ p" $Qfile >> ${OUTPUTPREFIX}${numoffiles}
else
    if [ $numoffiles -eq 1 ]; then
#Only one file
        startline=$(echo $numoffiles $numofkpt1 | awk '{print ($1-1)*$2+1}')
   #echo $numofkpt1 > ${OUTPUTPREFIX}1
   #echo $numofkpt1
        sed -n "$startline, \$ p" $Qfile >> ${OUTPUTPREFIX}1
    fi
fi
#Write log
echo "Number of files = $numoffiles" >> $LOGFILE
