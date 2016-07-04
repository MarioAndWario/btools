#!/bin/bash
#This script submit jobs 
queue="serial"
numofcpu=16
walltime="03:00:00"
lattice="2H"
prefix=$(ls -A | sed -n '/save/ p' | awk -F"." '{print $1}')
echo "prefix : $prefix "
echo "Do you need vxc.dat? [y/n]"
read yorn

if [ $yorn == "y" ];then
   vxcflag="true"
else
   vxcflag="false"
fi

if [ $lattice == "1T" ];then
   REALorCPLX=1
   min=10
   max=30
else
   REALorCPLX=2
   min=19
   max=50
fi
############################################################
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
############################################################
for ((i=$StartIndex;i<=$EndIndex;i++))
do
  touch ./P_${i}/pw2.in
  cat > ./P_${i}/pw2.in << !
&input_pw2bgw
prefix = '${prefix}' ! same as in espresso
real_or_complex = $REALorCPLX ! 1 for real or 2 for complex
wfng_flag = .true. ! write wavefunction in G-space
wfng_file = 'WFN_P$i' ! wavefunction file name
wfng_kgrid = .false. ! overwrite k-grid in wavefunction file
wfng_nk1 = 0 ! ( if espresso input file contains the
wfng_nk2 = 0 ! manual list of k-points, the k-grid
wfng_nk3 = 0 ! parameters in espresso are set to zero;
wfng_dk1 = 0.0 ! since Sigma and absorption both need to know
wfng_dk2 = 0.0 ! the k-grid dimensions, we patch these
wfng_dk3 = 0.0 ! parameters into the wave-function file )
wfng_occupation = .false. ! overwrite occupations in wavefunction file
wfng_nvmin = 0 ! ( set min/max valence band indices; identical to
wfng_nvmax = 0 ! scissors operator for LDA-metal/GW-insulator )
rhog_flag = .true. ! write charge density in G-space
rhog_file = 'RHO' ! charge density file name
vxcg_flag = .true. ! write exchange-correlation potential in G-space
vxcg_file = 'VXC_P$i' ! exchange-correlation potential file name
vxc0_flag = .true. ! write Vxc(G=0)
vxc0_file = 'vxc0_P$i.dat' ! Vxc(G=0) file name
vxc_flag = .${vxcflag}. ! write matrix elements of Vxc
vxc_file = 'vxc_P$i.dat' ! Vxc matrix elements file name
vxc_diag_nmin = $min ! min band index for diagonal Vxc matrix elements
vxc_diag_nmax = $max ! max band index for diagonal Vxc matrix elements
/
!
  touch ./P_${i}/subpw2bgw.sh
  cat > ./P_${i}/subpw2bgw.sh << !
#!/bin/bash
#SBATCH -J QE_pw2bgw
#SBATCH -o JOB.%j
#SBATCH -N 1 -n ${numofcpu}
#SBATCH -p ${queue}
#SBATCH -t ${walltime}
#SBATCH -A TG-MCA94P030

ibrun pw2bgw.x < pw2.in > pw2.out
!
  cd P_${i}
  
  if [ $SUBFLAG -eq 1 ];then
     sbatch subpw2bgw.sh
     echo "JOB P_${i} has been submitted!"
  else
     echo "You must submit the jobs by yourself!"
  fi
  
  cd ..
done
