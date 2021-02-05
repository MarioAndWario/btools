#!/bin/bash
#SBATCH -J EPSq0_BATCH
#SBATCH -N 20
#SBATCH -p RM
#SBATCH -t 02:00:00
#SBATCH --ntasks-per-node=128
#echo commands to stdout
#set -x
export OMP_NUM_THREADS=1
# export OMP_PROC_BIND=true
# export OMP_PLACES=threads
# export FORT_BUFFERED=TRUE

# This script will submit several jobs to generate chi0mat.h5 for each subsampling qpoint
# We need to setup template and cc_q0s.inp to proceed
MPI_RUN=${MPI_GNU_DIR}/mpirun
RUN=${MPI_RUN}

#DirWFN_shift=
FILE_WFN_shift="WFNmq.h5"
if [ $# -ne 2 ]; then
    echo "Usage sub_subsample_eps.sh [iq_start] [iq_end] "
    exit 123
else
    iq_start=$1
    iq_end=$2
fi
if [ -z $DirWFN_shift ]; then
    echo "[ERROR] Must set DirWFN_shift."
    exit 123
fi
echo "iq_start = $iq_start, iq_end = $iq_end, DirWFN_shift = $DirWFN_shift"

DirTemplate="template_eps_q0"
Qfile="cc_q0s.inp"
DirCurrent=$(pwd)
for ((iq=${iq_start};iq<=${iq_end};iq++))
do
    qvector=$(sed -n "${iq} p" ${Qfile})
    echo "iq = ${iq} : ${qvector}"
    DirName="Q${iq}"
    if [ -d ${DirName} ]; then
        echo "${DirName} exist."
    else
        cp -r ${DirTemplate} ${DirName}
    fi
    cd $DirName

    # EPS calculation
    ln -sf ${DirWFN_shift}/Q${iq}/${FILE_WFN_shift} .
    INPUT="epsilon.inp"
    OUTPUT="eps.out"
    EXENAME="epsilon.cplx.x"
    sed -i "/begin qpoints/!b;n;c ${qvector}" ${INPUT}
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
        # ${RUN} ${EXENAME} < ${INPUT} > ${OUTPUT} 2>&1
        # if [ ! -z "$(grep "TOTAL:" ${OUTPUT})" ]; then
        #     echo "Finish ${EXENAME} calculation"
        # fi
    fi

    # # CE calculation
    # OUTPUT="ce0.out"
    # EXENAME="calc_eps.cplx.x chi0mat.h5"
    # if [ -f "${OUTPUT}" ]; then
    #     if [ -z "$(grep "TOTAL:" ${OUTPUT})" ]; then
    #         echo "${OUTPUT} did not finish, restart ${EXENAME} calculation"
    #         DO_RUN="T"
    #     else
    #         echo "Finished. Skip this ${EXENAME} calculation..."
    #         DO_RUN="F"
    #     fi
    # else
    #     DO_RUN="T"
    # fi

    # if [ ${DO_RUN} == "T" ]; then
    #     echo "Start ${EXENAME} calculation"
    #     ${RUN} ${EXENAME} > ${OUTPUT} 2>&1
    #     if [ ! -z "$(grep "TOTAL:" ${OUTPUT})" ]; then
    #         echo "Finish ${EXENAME} calculation"
    #     fi
    # fi
    # echo "============================="

    cd ${DirCurrent}
done
