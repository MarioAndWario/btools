#!/bin/bash
#This script submit jobs 
queue="development"
numofnode=16
numofthread=4
cpupernode=16
walltime="02:00:00"
JOBNAME="Epsilon"
PTLIB="qptlib"
PTLOG="qgrid.log"
PREFIX="QP"
SUBSCRIPT="subepsilon.sh"
BINARY="epsilon.cplx.x"
JOBTYPE="epsilon"
DirIndex=$(basename $(pwd))
#################################################################
#Default: 1 to end
if [ $# -gt 3 ]; then
   echo "USAGE: wfnbatch.sh [SUBFLAG:1=true,i=interactive,d=delete,else=false]  [StartIndex] [EndIndex] "
   exit 0
fi

echo "Number of files: $(sed -n '2 p' ${PTLIB}/${PTLOG} | awk '{print $5}') "

if [ $# -eq 0 ];then
   echo "You are using the default setting:"
   SUBFLAG=1
   StartIndex=1
   EndIndex=$(sed -n '2 p' ${PTLIB}/${PTLOG} | awk '{print $5}')
   echo "We are submitting jobs from $StartIndex to $EndIndex"
else
   if [ $# -eq 1 ];then
   echo "You set SUBFLAG = $1"
   SUBFLAG=$1
   StartIndex=1
   EndIndex=$(sed -n '2 p' ${PTLIB}/${PTLOG} | awk '{print $5}')
   echo "We are submitting jobs from $StartIndex to $EndIndex"
   else
      if [ $# -eq 2 ]; then
	 SUBFLAG=$1
         StartIndex=$2
         EndIndex=$(sed -n '2 p' ${PTLIB}/${PTLOG} | awk '{print $5}')
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

#If we have input command
if [ $SUBFLAG == "d" ]; then
   for ((i=$StartIndex;i<=$EndIndex;i++))
   do
     if [ -d P_${i} ];then
	echo "Deleting directory P_${i} ..."
	rm -rf P_${i}
     fi
   done
   exit 0
fi
#Interacvite setting
if [ $SUBFLAG == "i" ];then
   echo "Interactive setting..."
   echo -n "Queue : "
   read queue
   echo -n "Number of nodes : "
   read numofnode
   echo -n "Number of threads : "
   read numofthread
   echo -n "Walltime : "
   read walltime
   echo -n "Jobname : "
   read JOBNAME
   echo -n "Submit jobs automatically? (1=true,else=false) : "
   read SUBFLAG
fi

numoftask=$(echo "$numofnode*$cpupernode/$numofthread" | bc)

############################################################
#Summary
echo "Setting summary ..."
echo "You are calculating epsilon for index : $DirIndex"
echo "Queue = $queue"
echo "Number of nodes (-N) : $numofnode"
echo "Number of threads (OMP_NUM_THREAD) : $numofthread"
echo "Number of task (-n) : $numoftask"
echo "Walltime = $walltime"
echo "SUBFLAG = $SUBFLAG"
echo "StartIndex = $StartIndex"
echo "EndIndex = $EndIndex"
############################################################
cd proto
ln -s -f ../../../wfnq/${DirIndex}/WFNq .
ln -s -f ../../../wfn/WFN .
cd ..
############################################################
for ((i=$StartIndex;i<=$EndIndex;i++))
do
  if [ -d P_${i} ];then
     echo "Deleting directory P_${i} ..."
     rm -rf P_${i}
  fi
  cp -r proto P_${i}
  cd P_${i}
  sed -i "/begin/ r ../${PTLIB}/${PREFIX}${i}" epsilon.inp
###########################################################
  cat > ${SUBSCRIPT} << !
#!/bin/bash
#SBATCH -J ${JOBNAME}
#SBATCH -o JOB.%j
#SBATCH -n ${numoftask} -N ${numofnode}
#SBATCH -p ${queue}
#SBATCH -t ${walltime}
#SBATCH --mail-user=wu1meng2@berkeley.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=fail
#SBATCH -A TG-MCA94P030

export OMP_NUM_THREADS=${numofthread}

ibrun ${BINARY} > ${JOBTYPE}.out
!
  if [ $SUBFLAG -eq 1 ];then
     sbatch ${SUBSCRIPT}
     echo "========================================="
     echo "P_${i}" has been submiited
  else
     echo "You must submit the jobs by yourself!"
  fi
  cd ..
done
