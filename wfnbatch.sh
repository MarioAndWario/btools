#!/bin/bash
#This script submit jobs 
queue="normal"
numofnode=15
nodeperkpts=1
cpupernode=16
walltime="12:00:00"
KPOINTSPREFIX="KP"
JOBNAME="QE"
PTLIB="kptlib"
PTLOG="kgrid.log"
#################################################################
#Default: 1 to end
if [ $# -gt 3 ]; then
   echo "USAGE: wfnbatch.sh [SUBFLAG:1=true,f=force,i=interactive,d=delete,else=false] [StartIndex] [EndIndex] "
   exit 0
fi

echo "Number of kpoints file: $(sed -n '2 p' ${PTLIB}/${PTLOG} | awk '{print $5}') "

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
###########################################################
#Interacvite setting
if [ $SUBFLAG == "i" ];then
   echo "Interactive setting..."
   echo -n "Queue : "
   read queue
   echo -n "Number of nodes : "
   read numofnode
   echo -n "Walltime : "
   read walltime
   echo -n "Jobname : "
   read JOBNAME
   echo -n "Submit jobs automatically? (1=true,else=false) : "
   read SUBFLAG
fi

numoftask=$(echo "$numofnode*$cpupernode" | bc)

############################################################
#Summary
echo "Setting summary ..."
echo "Queue = $queue"
echo "Number of nodes (-N) : $numofnode"
echo "Number of task (-n) : $numoftask"
echo "Walltime = $walltime"
echo "SUBFLAG = $SUBFLAG"
echo "StartIndex = $StartIndex"
echo "EndIndex = $EndIndex"

###########################################################
for ((i=$StartIndex;i<=$EndIndex;i++))
do
  if [ -d P_${i} ];then
     echo "Deleting directory P_${i} ..."
     rm -rf P_${i}
  fi
  cp -r proto P_${i}
  cp -r ./*.save ./P_${i}
  cd P_${i}
  numofkpts=$(wc --lines ../${PTLIB}/${KPOINTSPREFIX}${i} | awk '{print $1-1}')
  if [ $numofkpts -gt $numofnode -o $SUBFLAG == "f"  ];then
     numoftask=$( echo "$numofnode * $cpupernode" | bc )
     nk=$numofnode
  else
     numoftask=$( echo $numofkpts $nodeperkpts $cpupernode | awk '{print $1*$2*$3}')
     nk=$numofkpts
  fi
  echo "# of kpts : $numofkpts"
# echo $numofkpts >> ./QE.in
  cat ../${PTLIB}/${KPOINTSPREFIX}${i} >> ./QE.in
  cat > subqe.sh << !
#!/bin/bash
#SBATCH -J ${JOBNAME}
#SBATCH -o JOB.%j
#SBATCH -n ${numoftask}
#SBATCH -p ${queue}
#SBATCH -t ${walltime}
#SBATCH -A TG-MCA94P030

ibrun pw.x -nk ${nk} -nb 1 -nd 1 < QE.in > QE.out
!
  
  if [ $SUBFLAG == "1" ];then
     sbatch subqe.sh
     echo "===================================="
     echo "Job P_${i} has been submitted!"
  else
     echo "You must submit the jobs by yourself!"
  fi

  cd ..
done
