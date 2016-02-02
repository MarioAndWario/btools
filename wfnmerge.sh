#!/bin/bash
#source ~/.bashrc.ext
#This script submit jobs 
queue="serial"
numofnode=1
cpupernode=16
numofcpu=$(echo "$numofnode*$cpupernode" | bc)
walltime="05:00:00"
numofkpts=$(sed -n '1 p' kptlib/kgrid.log | awk '{print $7}')
echo "Number of Kpoints = $numofkpts"
workdir=merge_all
#Read in in.kgrid
echo "WFN or WFNq or Subsample? ..."
read WFNorWFNqorSubsample
if [ $WFNorWFNqorSubsample == "Subsample" ];then
   kgridinput="../../wfn/kgrid/in.kgrid"
   WFNout="WFNq"
else
   if [ $WFNorWFNqorSubsample == "WFN" ];then
      kgridinput="./kgrid/in.kgrid"
      WFNout="WFN"
   else
      if [ $WFNorWFNqorSubsample == "WFNq" ];then
         kgridinput="./kgrid/in.kgrid"
	 WFNout="WFNq"
      else
          echo "Error input, please specify WFN or WFNq?"
          exit 0
      fi
   fi
fi
FinalKGrid=$(sed -n "1 p" $kgridinput | awk '{print $1, $2, $3}')

if [ $WFNorWFNqorSubsample == "WFN" ] || [ $WFNorWFNqorSubsample == "WFNq" ];then
   FinalKShift=$(sed -n "2 p" $kgridinput | awk '{print $1, $2, $3}')

else
   FinalKShift="0.0 0.0 0.0"
fi
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

rm -rf ./vxc.dat
touch vxc.dat

for ((i=$StartIndex;i<=$EndIndex;i++))
do
  ln -s ../P_$i/WFN_P$i $workdir/WFN_P$i
  echo "./WFN_P$i" >> ./$workdir/wfnmerge.inp
  cat P_$i/vxc_P${i}.dat >> vxc.dat
done
for ((i=$StartIndex;i<=$EndIndex;i++))
do
  echo "1.0" >> ./$workdir/wfnmerge.inp
done
cat > ./$workdir/subwfnmerge.sh <<!
#!/bin/bash
#SBATCH -J WFNmerge
#SBATCH -o JOB.%j
#SBATCH -N 1 -n 1
#SBATCH -p ${queue}
#SBATCH -t ${walltime}
#SBATCH -A TG-MCA94P030

ibrun wfnmerge.x > wfnmerge.out
!

###############################
cd ./$workdir
  if [ $SUBFLAG -eq 1 ];then
    # wfnmerge.x | tee merge.out
    sbatch subwfnmerge.sh
    #~/softwares/BGW/BGW_hopper_gnu_libsci_hdf5/bin/wfnmerge.x | tee merge.out
  else
     echo "You must submit the job by yourself!"
  fi
cd ..
ln -s -f $workdir/${WFNout} .
ln -s -f P_1/RHO .
