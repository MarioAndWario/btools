#!/bin/bash
# This script will transform eqp.dat into eigenvalue format.
# We need "eqp.dat", "QE.out", "QE.in"
# beig_mag.sh

InteqpInput="inteqp.inp"
EQPfile="eqp.dat"
QEINPUT="QE.in"
QEOUTPUT="QE.out"
KPTFILE="Klength.dat"

EIGFILE_up="Eig.up.dat"
EIGSHIFTFILE_up="Eig.shift.up.dat"

EIGFILE_down="Eig.down.dat"
EIGSHIFTFILE_down="Eig.shift.down.dat"

TEMPEIGFILE_up="tempEig.up.dat"
TEMPEIGFILE_down="tempEig.down.dat"

#BANDSFILE="eigenvalue"
#BANDSSHIFTFILE="eigenvalue.shift"

BANDSFILE_up="eigenvalue.up"
BANDSSHIFTFILE_up="eigenvalue.shift.up"

BANDSFILE_down="eigenvalue.down"
BANDSSHIFTFILE_down="eigenvalue.shift.down"

Helper1="helper1.dat"
Helper2="helper2.dat"

sortflag=0

#length unit in QE
if [ -z $1 ]; then
    alat=$(grep -a --text 'alat)' ${QEOUTPUT} | head -1 | awk '{print $5}' )
    bohrradius=0.52917721092
    # transconstant=$(echo $alat $bohrradius | awk '{print $1*$2}')
    transconstant=$(echo $alat $bohrradius | awk '{print $1*$2/2.0/3.14159265359}')
    echo "alat is $transconstant Angstrom"
else
    transconstant=$1
    echo "alat is $transconstant Angstrom"
fi

###############################################################
#######################  File clearance  ######################
if [ -f $EIGFILE_up ]; then
    rm -f $EIGFILE_up
fi

if [ -f $EIGFILE_down ]; then
    rm -f $EIGFILE_down
fi

if [ -f $KPTFILE ]; then
    rm -f $KPTFILE
fi

if [ -f ${TEMPEIGFILE_up} ]; then
    rm -f ${TEMPEIGFILE_up}
fi

if [ -f ${BANDSFILE_up} ]; then
    rm -f ${BANDSFILE_up}
fi

if [ -f ${TEMPEIGFILE_down} ]; then
    rm -f ${TEMPEIGFILE_down}
fi

if [ -f ${BANDSFILE_down} ]; then
    rm -f ${BANDSFILE_down}
fi

if [ -f $Helper1 ]; then
    rm -f $Helper1
fi

if [ -f $Helper2 ]; then
    rm -f $Helper2
fi

# Determine the number of bands in eqp.dat
numofbnds=$(sed -n "1p" ${EQPfile} | awk '{print $4}')
# Determine the number of kpoints in eqp.dat
numofkpts=$(grep -c -E "\b${numofbnds}\b\$" ${EQPfile})

VBMindex=$(grep -a --text "number_val_bands_fine" ${InteqpInput} | awk '{print $2}')

#Find "reciprocal axes in cartesian coordinates" module and read the starti\ng point for each segment
#cat $QEOUTPUT | tr -d '\000'
b1x=$(grep -a --text "b(1)" $QEOUTPUT | awk '{print $4}')
b1y=$(grep -a --text "b(1)" $QEOUTPUT | awk '{print $5}')
b1z=$(grep -a --text "b(1)" $QEOUTPUT | awk '{print $6}')
b2x=$(grep -a --text "b(2)" $QEOUTPUT | awk '{print $4}')
b2y=$(grep -a --text "b(2)" $QEOUTPUT | awk '{print $5}')
b2z=$(grep -a --text "b(2)" $QEOUTPUT | awk '{print $6}')
b3x=$(grep -a --text "b(3)" $QEOUTPUT | awk '{print $4}')
b3y=$(grep -a --text "b(3)" $QEOUTPUT | awk '{print $5}')
b3z=$(grep -a --text "b(3)" $QEOUTPUT | awk '{print $6}')

###############################################################
#Find high-symmetry points from $QEINPUT and convert it into cartesian coordinates
NumHiSymP=$(grep -a --text -A 1 "K_POINTS" $QEINPUT | tail -1 | awk '{print $1}')
#it is actually the first High Symmetry Point
HiSymCounter=2
FlagChangeStartingPoint=1
BaseLength=0.0
KLength=0

echo "========================================================"
echo "num of kpts = $numofkpts, num of bnds = $numofbnds num of vb = ${VBMindex}"
for ((i=1;i<=$numofkpts;i++))
#for ((i=1;i<=5;i++))
do
    kptline=$(echo $i ${numofbnds} | awk '{print ($1-1)*($2+1)+1}')
    #echo ${kptline}
    if [ $FlagChangeStartingPoint -eq 1 ]; then
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if [ $HiSymCounter -eq 2 ]; then
            kpttargetline=$(echo $i ${numofbnds} | awk '{print $1*($2+1)+1}')
        else
            kpttargetline=$kptline
        fi
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#Read in the high symmetry points in crystal fractional coordinate
        Gx0=$(grep -a --text -A $HiSymCounter "K_POINTS" $QEINPUT | tail -1 | awk '{print $1}')
        Gy0=$(grep -a --text -A $HiSymCounter "K_POINTS" $QEINPUT | tail -1 | awk '{print $2}')
        Gz0=$(grep -a --text -A $HiSymCounter "K_POINTS" $QEINPUT | tail -1 | awk '{print $3}')
        
        echo "========================================================"
        echo "High symmetry points in crystal fractional coordinate:"
        echo "G0 = ($Gx0, $Gy0, $Gz0)"
        segmentlength=$(grep -a --text -A $HiSymCounter "K_POINTS" $QEINPUT | tail -1 | awk '{print $4}')
        echo "segmentlength = " $segmentlength

        echo $segmentlength >> $Helper1
###########counter for the number of segments
        segmentcounter=0
###########Switch off the flag for changing the starting point
        FlagChangeStartingPoint=0
###########Update High symmetry pointer counter
        HiSymCounter=$(echo $HiSymCounter | awk '{print $1+1}')

       #Read in the next point in crystal fractional coordinates
        Gx=$(sed -n "$kpttargetline p" ${EQPfile} | awk '{print $1}')
        Gy=$(sed -n "$kpttargetline p" ${EQPfile} | awk '{print $2}')
        Gz=$(sed -n "$kpttargetline p" ${EQPfile} | awk '{print $3}')

        # Convert G0 into cartesian coordinates
        Kx0=$(echo $Gx0 $Gy0 $Gz0 $b1x $b2x $b3x | awk '{printf("%3.8f\n",$1*$4+$2*$5+$3*$6)}')
        Ky0=$(echo $Gx0 $Gy0 $Gz0 $b1y $b2y $b3y | awk '{printf("%3.8f\n",$1*$4+$2*$5+$3*$6)}')
        Kz0=$(echo $Gx0 $Gy0 $Gz0 $b1z $b2z $b3z | awk '{printf("%3.8f\n",$1*$4+$2*$5+$3*$6)}')   

        # Convert G into cartesian coordinates
        Kx=$(echo $Gx $Gy $Gz $b1x $b2x $b3x | awk '{printf("%3.8f\n",$1*$4+$2*$5+$3*$6)}')
        Ky=$(echo $Gx $Gy $Gz $b1y $b2y $b3y | awk '{printf("%3.8f\n",$1*$4+$2*$5+$3*$6)}')
        Kz=$(echo $Gx $Gy $Gz $b1z $b2z $b3z | awk '{printf("%3.8f\n",$1*$4+$2*$5+$3*$6)}')   

        echo "High symmetry kpoint in cartesian coordinate:"
        echo "K = ($Kx, $Ky, $Kz)"
        # echo "segmentlength = $segmentlength"

        #Delta G in cartesian coordinates
        DGx=$(echo $Kx $Kx0 | awk '{print $1-$2}')
        DGy=$(echo $Ky $Ky0 | awk '{print $1-$2}')
        DGz=$(echo $Kz $Kz0 | awk '{print $1-$2}')

        DLength=$(echo $DGx $DGy $DGz | awk '{printf("%3.8f\n",sqrt($1*$1+$2*$2+$3*$3))}')
    fi 
    
    if [ $i -eq 1 -o $segmentlength -eq 1 ];then
        KLength=$(echo $KLength| awk '{print $1}' )
    else
        KLength=$(echo $KLength $DLength | awk '{print $1+$2}' )
    fi
    # echo "KLength = " ${KLength}

    #transform into VASP unit
    KLengthout=$(echo $KLength $transconstant | awk '{printf("%15.10f",$1/$2)}')
    echo -e "$KLengthout " >> $KPTFILE

    #####################################
    # Read and transform eigenvalues    
    eigstartline_up=$(echo $i ${numofbnds} | awk '{print ($i-1)*($2+1)+2}')
    # echo $eigstartline
    eigendline_up=$(echo ${eigstartline_up} ${numofbnds} | awk '{print $1+$2/2-1 }')

    # echo $eigendline
    sed -n "${eigstartline_up},${eigendline_up} p" ${EQPfile} | awk '{print $4}' | awk 'BEGIN { ORS = "  " } { print }' >> ${TEMPEIGFILE_up}

    echo -e "" >> ${TEMPEIGFILE_up}

    # Read and transform eigenvalues    
    eigstartline_down=$(echo ${eigendline_up} ${numofbnds} | awk '{print $1+1 }')

    # echo $eigstartline
    eigendline_down=$(echo ${eigstartline_down} ${numofbnds} | awk '{print $1+$2/2-1}')

    # echo $eigendline
    sed -n "${eigstartline_down},${eigendline_down} p" ${EQPfile} | awk '{print $4}' | awk 'BEGIN { ORS = "  " } { print }' >> ${TEMPEIGFILE_down}

    echo -e "" >> ${TEMPEIGFILE_down}

    if [ $sortflag -eq 1 ]; then
        tail -1 ${TEMPEIGFILE_up} | awk ' {split( $0, a, " " ); asort( a ); for( i = 1; i <= length(a); i++ ) printf( "%s   ", a[i] ); printf( "\n" ); }'>>  ${EIGFILE_up}
    fi

    if [ $sortflag -eq 1 ]; then
        tail -1 ${TEMPEIGFILE_down} | awk ' {split( $0, a, " " ); asort( a ); for( i = 1; i <= length(a); i++ ) printf( "%s   ", a[i] ); printf( "\n" ); }'>>  ${EIGFILE_down}
    fi

    #Judge if we need to turn on the $FlagChangeStartingPoint
    segmentcounter=$(echo $segmentcounter | awk '{print $1+1}')
    if [ $HiSymCounter -eq 3 ];then
        if [ $segmentcounter -gt $segmentlength ]; then
            FlagChangeStartingPoint=1
        fi
    else
        if [ $segmentcounter -eq $segmentlength ]; then
            FlagChangeStartingPoint=1
        fi
    fi    

done

if [ ! $sortflag -eq 1 ]; then
    cat ${TEMPEIGFILE_up} >> ${EIGFILE_up}
fi

if [ ! $sortflag -eq 1 ]; then
    cat ${TEMPEIGFILE_down} >> ${EIGFILE_down}
fi

################################################################
############## Paste the klength and eigs together #############
echo $VBMindex $numofkpts $(echo "$numofbnds/2" | bc) $(tail -1 $KPTFILE) > $Helper2
paste -d" " $KPTFILE ${EIGFILE_up} > ${BANDSFILE_up}
paste -d" " $KPTFILE ${EIGFILE_down} > ${BANDSFILE_down}

echo "=======================Finished!========================"
