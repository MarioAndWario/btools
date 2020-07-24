#!/bin/bash
# This script will calculate bandgap from eqp.dat
# We need "eqp.dat", "QE.out", "QE.in"

QEINPUT="QE.in"
QEOUTPUT="QE.out"
EIGFILE="eqp.sorted.dat"
TEMPEIGFILE="tempEig.dat"
TEMPEIGFILE_SORT="tempEig.sorted.dat"

# if [ -z $1 ]; then
#    EQPfile="eqp.dat"   
# else
#    EQPfile=$1
# fi

# if [ -z $2 ]; then
#    if [ $2 == "3" ]; then
#       Col="3"
#    else
#       Col="4"
#    fi
# else
#    Col="4"
# fi

EQPfile="eqp.dat"
Col="4"

echo "We will output Col ${Col} of ${EQPfile}"

#length unit in QE
if [ -z $3 ]; then
    alat=$(grep -a --text 'alat)' ${QEOUTPUT} | head -1 | awk '{print $5}' )
    bohrradius=0.52917721092
    # transconstant=$(echo $alat $bohrradius | awk '{print $1*$2}')
    transconstant=$(echo $alat $bohrradius | awk '{print $1*$2/2.0/3.14159265359}')
    echo "alat is $transconstant Angstrom"
else
    transconstant=$3
    echo "alat is $transconstant Angstrom"
fi

###############################################################
echo "========================================================"
echo "========================================================"
numofelec=$(grep -a --text "number of electrons" $QEOUTPUT | awk -F "=" '{print int($2)}')

############### See if non-colin ##################
FlagNSpin=$(sed -e '/\s*!.*$/d' -e '/^\s*$/d' $QEINPUT | grep -a --text 'nspin' | awk -F "=" '{print $2}' | awk '{print $1}')

echo "FlagNSpin = ${FlagNSpin}"


if [ -z $FlagNSpin ]; then
    echo "We are doing non-magnetic calculation: nspin = 1"
    VBMindex=$(echo $numofelec | awk '{print int($1/2)}')
elif [ $FlagNSpin -eq 1 ]; then
    echo "We are doing non-magnetic calculation: nspin = $FlagNSpin"
    VBMindex=$(echo $numofelec | awk '{print int($1/2)}')
elif [ $FlagNSpin -eq 2 ]; then
    echo "We are doing collinear calculation: nspin = $FlagNSpin"
    VBMindex=$(echo $numofelec | awk '{print int($1)}')
elif [ $FlagNSpin -eq 4 ]; then
    echo "We are doing non-collinear calculation: nspin = $FlagNSpin"
    VBMindex=$(echo $numofelec | awk '{print int($1)}')
else
    echo "Error about nspin"
    exit 1
fi

echo "Index of VBM = $VBMindex"

###############################################################
#######################  File clearance  ######################
if [ -f $EIGFILE ]; then
    rm -f $EIGFILE
fi

if [ -f $TEMPEIGFILE ]; then
    rm -f $TEMPEIGFILE
fi

if [ -f ${TEMPEIGFILE_SORT} ]; then
    rm -f ${TEMPEIGFILE_SORT}
fi

# Determine the number of bands in eqp.dat
numofbnds=$(sed -n "1p" ${EQPfile} | awk '{print $4}')
# Determine the number of kpoints in eqp.dat
numofkpts=$(grep -a --text 'number of k points=' $QEOUTPUT | awk -F "=" '{print $2}' | awk '{print $1}')

#####################
# Determine BandStart and BandEnd from eqp.dat
BandStart=$(sed -n "2p" ${EQPfile} | awk '{print $2}')
BandEnd=$(echo "${BandStart}+${numofbnds}-1" | bc)

NumofEQPBands=$( echo "${BandEnd}-${BandStart}+1" | bc )

echo "BandStart = ${BandStart} BandEnd = ${BandEnd} NumofEQPBands = ${NumofEQPBands}"
echo "========================================================"
echo "num of kpts = $numofkpts, num of bnds = $numofbnds num of vb = ${VBMindex}"

for ((ik=1;ik<=$numofkpts;ik++))
do
    if [ $(echo "${ik}%100" | bc) == "0" ]; then
        echo "ik = ${ik}"
    fi
    kptline=$(echo ${ik} ${numofbnds} | awk '{print ($1-1)*($2+1)+1}')
    # Read and transform eigenvalues
    eigstartline=$(echo ${ik} ${numofbnds} | awk '{print ($i-1)*($2+1)+2}')
    # echo $eigstartline
    eigendline=$(echo ${ik} ${numofbnds} | awk '{print ($i)*($2+1)}')

    # echo $eigendline
    sed -n "${eigstartline},${eigendline} p" ${EQPfile} | awk '{print $4}' | awk 'BEGIN { ORS = "  " } { print }' >> ${TEMPEIGFILE}

    echo -e "" >> ${TEMPEIGFILE}

    # Sort the eigenvalues in eqp.dat
    tail -1 $TEMPEIGFILE | awk ' {split( $0, a, " " ); asort( a ); for( i = 1; i <= length(a); i++ ) printf( "%s   ", a[i] ); printf( "\n" ); }'>> ${TEMPEIGFILE_SORT}

    sed -n "$kptline p" ${EQPfile} >> $EIGFILE

    sed -n "${ik} p" ${TEMPEIGFILE_SORT} | awk -v bandstart=${BandStart} -v bandend=${BandEnd} '{for (i=bandstart;i<=bandend;i++) printf("%8d %8d %16.9f \n",1,i,$i) }' >> $EIGFILE
done

VBMindex_with_offset=$(echo "${VBMindex}-${BandStart}+1" | bc)

echo "VBMindex_with_offset = ${VBMindex_with_offset}"

# #####
VBmax=-10000
CBmin=10000
ikc=0
ikv=0

echo "===> Get bandedge ..."

for ((ik=1;ik<=$numofkpts;ik++))
do
    if [ $(echo "${ik}%100" | bc) == "0" ]; then
        echo "ik = ${ik}"
    fi

    # echo "k # ${ik}"
    # echo "${VBMindex_with_offset}+(${ik}-1)*(${NumofEQPBands}+1)+1" | bc
    # echo "${VBMindex_with_offset}+(${ik}-1)*(${NumofEQPBands}+1)+2" | bc

    # sed -n "$( echo "${VBMindex_with_offset}+(${ik}-1)*(${NumofEQPBands}+1)+1" | bc) p" $EIGFILE | awk '{print $3}' | awk '{printf("%16.9f \n",$1)}'
    # sed -n "$( echo "${VBMindex_with_offset}+(${ik}-1)*(${NumofEQPBands}+1)+2" | bc) p" $EIGFILE | awk '{print $3}' | awk '{printf("%16.9f \n",$1)}'

    VB=$(sed -n "$( echo "${VBMindex_with_offset}+(${ik}-1)*(${NumofEQPBands}+1)+1" | bc) p" $EIGFILE | awk '{print $3}' | awk '{printf("%16.9f",$1)}' )

    CB=$(sed -n "$( echo "${VBMindex_with_offset}+(${ik}-1)*(${NumofEQPBands}+1)+2" | bc) p" $EIGFILE | awk '{print $3}' | awk '{printf("%16.9f",$1)}' )

    Vcompare=$(echo "${VB} > ${VBmax}" | bc -l )
    #echo "VB = ${VB} VBmax = ${VBmax} Vcompare = ${Vcompare}"
    if [ ${Vcompare} == "1" ]; then
        VBmax=${VB}
        ikv=${ik}
    fi

    Ccompare=$(echo "${CB} < ${CBmin}" | bc -l )
    #echo "CB = ${CB} CBmin = ${CBmin} Ccompare = ${Ccompare}"
    if [ ${Ccompare} == "1" ]; then
        CBmin=${CB}
        ikc=${ik}
    fi

done

echo "========================================================"

Eg=$(echo "${CBmin}-${VBmax}" | bc | awk '{printf("%16.9f",$1)}' )

####################
# Get indirect bandgap, direct gap at ikv, and direct gap at ikc
####################

# Direct bandgap
if [ ${ikv} == ${ikc} ]; then
    echo "< Direct bandgap >"
    echo " === VB === "
    echo "ikv = ${ikv}"
    kptline=$(echo ${ikv} ${NumofEQPBands} | awk '{print ($1-1)*($2+1)+1}')
    
    kv=$(sed -n "$kptline p" $EIGFILE | awk '{print $1,$2,$3}')

    echo "kv = ${kv}"
    echo "VBmax = ${VBmax} eV"

    echo " === CB === "
    echo "ikc = ${ikc}"
    kptline=$(echo ${ikc} ${NumofEQPBands} | awk '{print ($1-1)*($2+1)+1}')
    
    kc=$(sed -n "$kptline p" $EIGFILE | awk '{print $1,$2,$3}')

    echo "kc = ${kc}"
    echo "CBmin = ${CBmin} eV"

    echo " ========== "
    echo "Eg = ${Eg} eV"
fi

# Indirect bandgap
if [ ${ikv} != ${ikc} ]; then
    echo "< Indirect bandgap >"
    echo " === VB === "
    echo "ikv = ${ikv}"
    kptline=$(echo ${ikv} ${NumofEQPBands} | awk '{print ($1-1)*($2+1)+1}')
    kv=$(sed -n "$kptline p" $EIGFILE | awk '{print $1,$2,$3}')
   
    echo "kv = ${kv}"
    CBikv=$(sed -n "$( echo "${VBMindex_with_offset}+(${ikv}-1)*(${NumofEQPBands}+1)+2" | bc) p" $EIGFILE | awk '{print $3}' | awk '{printf("%16.9f",$1)}' )

    echo "VBmax = ${VBmax} eV"
    echo "CBikv = ${CBikv} eV"

    echo " === CB === "
    echo "ikc = ${ikc}"
    kptline=$(echo ${ikc} ${NumofEQPBands} | awk '{print ($1-1)*($2+1)+1}')
    kc=$(sed -n "$kptline p" $EIGFILE | awk '{print $1,$2,$3}')
    
    echo "kc = ${kc}"

    VBikc=$(sed -n "$( echo "${VBMindex_with_offset}+(${ikc}-1)*(${NumofEQPBands}+1)+1" | bc) p" $EIGFILE | awk '{print $3}' | awk '{printf("%16.9f",$1)}' )

    echo "CBmin = ${CBmin} eV"
    echo "VBikc = ${VBikc} eV"

    Egikv=$(echo ${CBikv} ${VBmax} | awk '{print $1-$2}')
    Egikc=$(echo ${CBmin} ${VBikc} | awk '{print $1-$2}')

    echo " ========== "
    echo "Indirect Eg = ${Eg} eV"
    echo "Eg@ikv = ${Egikv} eV"
    echo "Eg@ikc = ${Egikc} eV"
fi

echo "=======================Finished!========================"
