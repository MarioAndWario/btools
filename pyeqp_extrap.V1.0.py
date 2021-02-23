#!/usr/bin/env python
import numpy as np
import io
import os
import sys
import argparse
import subprocess

def readeqpfile_parameters(workdir, filename):
    eqpfile=io.open(workdir+filename,"rb");
    rawdata=np.genfromtxt(eqpfile,comments='#');
    eqpfile.close()
    size=len(rawdata)
    NumofBands=int(rawdata[0,3]);
    NumofKpts=int(len(rawdata)/(NumofBands+1));
    #print("nb = ",NumofBands, " nk = ", NumofKpts)
    ib_offset=int(rawdata[1,1]);
    ib_first=int(rawdata[1,1]);
    ib_last=int(rawdata[NumofBands,1]);
    #print("ib_first = ", ib_first, " ib_last = ", ib_last);    
    return [NumofBands, NumofKpts, ib_first, ib_last];

def readeqpfile_eqp(workdir, filename):
    eqpfile=io.open(workdir+filename,"rb");
    rawdata=np.genfromtxt(eqpfile,comments='#');
    eqpfile.close()
    size=len(rawdata)
    NumofBands=int(rawdata[0,3]);
    NumofKpts=int(len(rawdata)/(NumofBands+1));
    #print("nb = ",NumofBands, " nk = ", NumofKpts)
    ib_offset=int(rawdata[1,1]);
    ib_first=int(rawdata[1,1]);
    ib_last=int(rawdata[NumofBands,1]);
    #print("ib_first = ", ib_first, " ib_last = ", ib_last);

    mask=np.zeros(size,dtype=np.bool);
    mask[:]=False
    for ik in np.arange(NumofKpts):
        mask[ik*(NumofBands+1)+1:(ik+1)*(NumofBands+1)]=True
    #e_mf=np.zeros((NumofBands,NumofKpts),dtype="float");
    e_qp=np.zeros((NumofBands,NumofKpts),dtype="float");
    #e_mf[:,:]=np.reshape(rawdata[mask,2],(NumofBands,NumofKpts),order="F");
    e_qp[:,:]=np.reshape(rawdata[mask,3],(NumofBands,NumofKpts),order="F");
    
    return e_qp;

def readeqpfile_emf(workdir, filename):
    eqpfile=io.open(workdir+filename,"rb");
    rawdata=np.genfromtxt(eqpfile,comments='#');
    eqpfile.close()
    size=len(rawdata)
    NumofBands=int(rawdata[0,3]);
    NumofKpts=int(len(rawdata)/(NumofBands+1));
    #print("nb = ",NumofBands, " nk = ", NumofKpts)
    ib_offset=int(rawdata[1,1]);
    ib_first=int(rawdata[1,1]);
    ib_last=int(rawdata[NumofBands,1]);
    #print("ib_first = ", ib_first, " ib_last = ", ib_last);

    mask=np.zeros(size,dtype=np.bool);
    mask[:]=False
    for ik in np.arange(NumofKpts):
        mask[ik*(NumofBands+1)+1:(ik+1)*(NumofBands+1)]=True
    e_mf=np.zeros((NumofBands,NumofKpts),dtype="float");
    e_mf[:,:]=np.reshape(rawdata[mask,2],(NumofBands,NumofKpts),order="F");
    
    return e_mf;

def readeqpfile_k_and_b(workdir, filename):
    eqpfile=io.open(workdir+filename,"rb");
    rawdata=np.genfromtxt(eqpfile,comments='#');
    eqpfile.close()
    size=len(rawdata)
    NumofBands=int(rawdata[0,3]);
    NumofKpts=int(len(rawdata)/(NumofBands+1));
    #print("nb = ",NumofBands, " nk = ", NumofKpts)
    ib_offset=int(rawdata[1,1]);
    ib_first=int(rawdata[1,1]);
    ib_last=int(rawdata[NumofBands,1]);
    #print("ib_first = ", ib_first, " ib_last = ", ib_last);

    mask=np.zeros(size,dtype=np.bool);
    mask[:]=True
    for ik in np.arange(NumofKpts):
        mask[ik*(NumofBands+1)+1:(ik+1)*(NumofBands+1)]=False
    k_list=np.zeros((NumofKpts,3),dtype="float");
    b_list=np.zeros(NumofBands,dtype="int");
    k_list[:,:]=np.reshape(rawdata[mask,0:3],(NumofKpts,3),order="C");
    b_list[:]=np.rint(rawdata[1:NumofBands+1,1]);
    
    return [NumofBands, NumofKpts, ib_first, ib_last, k_list, b_list];

##############################################

file_output = "eqp1_noR.zero_broadening.dat"
broadening_list=np.array([2.0,2.5,3.0]);
eqpfilename="eqp1_noR.dat"
file1="../d2.5_b2.0/sig/"+eqpfilename
file2="../d2.5_b2.5/sig/"+eqpfilename
file3="../d2.5_b3.0/sig/"+eqpfilename

basedir="./"
workdir=basedir
filename=file1
fileoutname=file_output;
[nb, nk, ibfirst, iblast, k_list, b_list] = readeqpfile_k_and_b(workdir, filename)
#Print info
print("Parameters from "+filename);
print("nk = ", nk);
for ik in np.arange(nk):
    print("%12.9f %12.9f %12.9f"% tuple(k_list[ik,:]));
print("nb = ", nb);
print(b_list[:]);

############################################
e_mf=np.zeros([nb, nk], dtype='float');
e_qp_A=np.zeros([nb, nk], dtype='float');
filename=file1;
print("Reading "+filename);
e_mf=readeqpfile_emf(workdir, filename);
e_qp_A=readeqpfile_eqp(workdir, filename);

e_mf_=np.zeros([nb, nk], dtype='float');
e_qp_B=np.zeros([nb, nk], dtype='float');
filename=file2;
print("Reading "+filename);
e_mf_=readeqpfile_emf(workdir, filename);
e_qp_B=readeqpfile_eqp(workdir, filename);
if (np.max(np.abs(e_mf - e_mf_)) > 1.0E-10):
    print("e_mf mismatch 2.");
    sys.exit(5);      

e_mf_=np.zeros([nb, nk], dtype='float');
e_qp_C=np.zeros([nb, nk], dtype='float');
filename=file3;
print("Reading "+filename);
e_mf_=readeqpfile_emf(workdir, filename);
e_qp_C=readeqpfile_eqp(workdir, filename);
if (np.max(np.abs(e_mf - e_mf_)) > 1.0E-10):
    print("e_mf mismatch 3.");
    sys.exit(5);
    
e_qp_zerobroadening=np.zeros([nb, nk], dtype='float');

#Do extrapolation using polyfit
eqp_list=np.zeros((3),dtype="float");
p=np.zeros((3),dtype="float");
for ik in np.arange(nk):
    for ib in np.arange(nb):
        eqp_list[0]=e_qp_A[ib,ik];
        eqp_list[1]=e_qp_B[ib,ik];
        eqp_list[2]=e_qp_C[ib,ik];
        # Quadratic fitting
        p = np.polyfit(broadening_list, eqp_list, 2);
        e_qp_zerobroadening[ib,ik]=p[2];

#Output extrapolated bands
print("Output extrapolated bands to "+fileoutname);
with io.open(fileoutname,"w") as fileout:
    for ik in np.arange(nk):
        fileout.write("%12.9f %12.9f %12.9f" % tuple(k_list[ik,:]));
        fileout.write("%5d \n" % nb);
        for ib in np.arange(nb):            
            fileout.write("  1 %10d %15.6f %15.6f \n" % tuple((b_list[ib], e_mf[ib,ik], e_qp_zerobroadening[ib,ik])));
print("Done.")
