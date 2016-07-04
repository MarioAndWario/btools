#!/bin/bash
#This script submit jobs 
queue=development
numofnode=1
numofcpu=$(echo "$numofnode*24" | bc)
walltime="02:00:00"
numofkpts=$(sed -n '1 p' kptlib/kgrid.log | awk '{print $7}')
echo "Number of Kpoints = $numofkpts"
workdir=merge_all
#Read in in.kgrid
echo "WFN or WFNq? ..."
read WFNorWFNq
if [ $WFNorWFNq == "WFNq" ];then
   kgridinput="../../wfn/kgrid/in.kgrid"
   WFNout="WFNq"
else
   if [ $WFNorWFNq == "WFN" ];then
      kgridinput="./kgrid/in.kgrid"
      WFNout="WFN"
   else
      echo "Error input, please specify WFN or WFNq?"
      exit 0
   fi
fi
FinalKGrid=$(sed -n "1 p" $kgridinput | awk '{print $1, $2, $3}')

FinalKShift="0.0 0.0 0.0"
###############################################################
#Default: 1 to end
if [ $# -gt 3 ]; then
   echo "USAGE: pw2batch.sh [SUBFLAG:1=true,else=false] [StartIndex] [EndIndex] "
   exit 0
fi

echo "Number of kpoints file: $(sed -n '2 p' kptlib/kgrid.log | awk '{print $5}') "

if [ $# -eq 0 ];then
   echo "You are using the default setting:"
   SUBFLAG=1
   StartIndex=1
   EndIndex=$(sed -n '2 p' kptlib/kgrid.log | awk '{print $5}')
   echo "We are submitting jobs from $StartIndex to $EndIndex"
else
   if [ $# -eq 1 ];then
   SUBFLAG=$1
   StartIndex=1
   EndIndex=$(sed -n '2 p' kptlib/kgrid.log | awk '{print $5}')
   echo "We are submitting jobs from $StartIndex to $EndIndex"
   else
      if [ $# -eq 2 ]; then
	 SUBFLAG=$1
         StartIndex=$2
         EndIndex=$(sed -n '2 p' kptlib/kgrid.log | awk '{print $5}')
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
################################################################
if [ -d $workdir  ]; then
    echo "$workdir exists! We will remove it first..."
    rm -r $workdir
    mkdir $workdir
else
    mkdir $workdir
fi

cat > ./$workdir/wfnmerge.inp << !
${WFNout}
${FinalKGrid}     ! final k-grid
${FinalKShift} ! final k-shift
$numoffiles           ! total number of input WFN files
$numofkpts          ! total number of k-points in all input WFN files
!
for ((i=$StartIndex;i<=$EndIndex;i++))
do
  ln -s ../P_$i/WFN_P$i $workdir/WFN_P$i
  echo "./WFN_P$i" >> ./$workdir/wfnmerge.inp
done
for ((i=$StartIndex;i<=$EndIndex;i++))
do
  echo "1.0" >> ./$workdir/wfnmerge.inp
done
cat > ./$workdir/subwfnmerge.sh <<!
#!/bin/bash
#SBATCH -J QE_160_scf
#SBATCH -o JOB.%j
#SBATCH -n 96
#SBATCH -p development
#SBATCH -t 02:00:00
ibrun wfnmerge.x  >wfnmerge.out
!

###############################
cd ./$workdir
  if [ $SUBFLAG -eq 1 ];then
     wfnmerge.x | tee merge.out
     cp ${WFNout} .. &
  else
     echo "You must submit the job by yourself!"
  fi
cd ..
