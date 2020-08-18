#!/bin/bash
#SBATCH --job-name=BGW
#SBATCH --time=00:30:00
#SBATCH -q condo_omega
#SBATCH -p lr6
#SBATCH -A lr_omega
#SBATCH --ntasks=32
export OMP_NUM_THREADS=1

RUN="mpirun"

#This script will check parameters used in SWAPGW calculations
# broadening
# delta_frequency
# number_imaginary_freqs
# delta_freq_imag

BroadeningList="0.01" # $(seq 0.05 0.05 0.3)"
DeltaFreqList="0.2"
DirTemplate="dXX_bYY"
DirCurrent=$(pwd)
for Broadening in $BroadeningList
do
    for DeltaFreq in $DeltaFreqList
    do
        echo "+ Broadening = $Broadening, DeltaFreq = $DeltaFreq"
        DirName="b${Broadening}_d${DeltaFreq}"
        if [ -d ${DirName} ]; then
            echo "${DirName} exist."
        else
            cp -r ${DirTemplate} ${DirName}
        fi
        cd $DirName

        # calc_chi calculation
        cd cc
        sed -i "/^broadening/c\broadening ${Broadening}" calc_chi.inp
        sed -i "/^delta_frequency/c\delta_frequency ${DeltaFreq}" calc_chi.inp

        INPUT="calc_chi.inp"
        OUTPUT="cc.out"
        EXENAME="calc_chi.cplx.x"
        if [ -f "${OUTPUT}" ]; then
            if [ -z "$(grep "TOTAL:" ${OUTPUT})" ]; then
                echo "${OUTPUT} did not finish, restart ${EXENAME} calculation"
                DO_RUN="T"
            else
                echo "Finished. Skip this ${EXENAME} calculation..."
                DO_RUN="F"
            fi
        else
            DO_RUN="T"
        fi

        if [ ${DO_RUN} == "T" ]; then
            echo "Start ${EXENAME} calculation"
            ${RUN} ${EXENAME} < ${INPUT} > ${OUTPUT} 2>&1
            if [ ! -z "$(grep "TOTAL:" ${OUTPUT})" ]; then
                echo "Finish ${EXENAME} calculation"
            fi
        fi
        echo "-----------------------------"

        # epsilon calculation
        cd ../eps_from_cc
        sed -i "/^broadening/c\broadening ${Broadening}" epsilon.inp
        sed -i "/^delta_frequency/c\delta_frequency ${DeltaFreq}" epsilon.inp

        INPUT="epsilon.inp"
        OUTPUT="eps.out"
        EXENAME="epsilon.cplx.x"
        if [ -f "${OUTPUT}" ]; then
            if [ -z "$(grep "TOTAL:" ${OUTPUT})" ]; then
                echo "${OUTPUT} did not finish, restart ${EXENAME} calculation"
                DO_RUN="T"
            else
                echo "Finished. Skip this ${EXENAME} calculation..."
                DO_RUN="F"
            fi
        else
            DO_RUN="T"
        fi

        if [ ${DO_RUN} == "T" ]; then
            echo "Start ${EXENAME} calculation"
            ${RUN} ${EXENAME} < ${INPUT} > ${OUTPUT} 2>&1
            if [ ! -z "$(grep "TOTAL:" ${OUTPUT})" ]; then
                echo "Finish ${EXENAME} calculation"
            fi
        fi
        echo "-----------------------------"

        # sigma calculation
        cd ../sig/Gamma

        INPUT="sigma.inp"
        OUTPUT="sig.out"
        EXENAME="sigma.cplx.x"
        if [ -f "${OUTPUT}" ]; then
            if [ -z "$(grep "TOTAL:" ${OUTPUT})" ]; then
                echo "${OUTPUT} did not finish, restart ${EXENAME} calculation"
                DO_RUN="T"
            else
                echo "Finished. Skip this ${EXENAME} calculation..."
                DO_RUN="F"
            fi
        else
            DO_RUN="T"
        fi

        if [ ${DO_RUN} == "T" ]; then
            echo "Start ${EXENAME} calculation"
            ${RUN} ${EXENAME} < ${INPUT} > ${OUTPUT} 2>&1
            if [ ! -z "$(grep "TOTAL:" ${OUTPUT})" ]; then
                echo "Finish ${EXENAME} calculation"
            fi
        fi
        echo "============================="

        cd ${DirCurrent}

    done
done
