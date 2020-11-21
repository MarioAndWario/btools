#!/usr/bin/env python3
import numpy as np
import io
import os
import sys

broadening_list=np.array([0.45, 0.50, 0.55], dtype="float");
broadening_string_list=["d0.5_b0.45", "d0.5_b0.5", "d0.5_b0.55"];
nbroadening=3;
basedir="/scratch1/03355/tg826544/KBr/60Ry/6x6x6/eps_20Ry_800b/b1_to_78/"
workdir=basedir+"d0.5_b0.5/sig_b1_78/"
filename="eqp1_noR.dat"

######################################################################
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
    e_mf=np.zeros((NumofBands,NumofKpts),dtype="float");
    e_qp=np.zeros((NumofBands,NumofKpts),dtype="float");
    e_mf[:,:]=np.reshape(rawdata[mask,2],(NumofBands,NumofKpts),order="F");
    e_qp[:,:]=np.reshape(rawdata[mask,3],(NumofBands,NumofKpts),order="F");
    
    return [NumofBands, NumofKpts, ib_first, ib_last, e_mf, e_qp];

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

######################################################################
#[nb, nk, ibfirst, iblast] = readeqpfile_parameters(workdir, filename)
[nb, nk, ibfirst, iblast, k_list, b_list] = readeqpfile_k_and_b(workdir, filename)
#Print info
print("Parameters from "+filename);
print("nk = ", nk);
for ik in np.arange(nk):
    print("%12.9f %12.9f %12.9f"% tuple(k_list[ik,:]));
print("nb = ", nb);
for ib in np.arange(nb):
    print("%10d"% b_list[ib]);
print("-------------------------------------------")
e_mf=np.zeros([nb, nk], dtype='float');
e_qp=np.zeros([nb, nk, nbroadening], dtype='float');
e_mf=readeqpfile_emf(workdir, filename);
for ibroadening in np.arange(nbroadening):
    broadening_string=broadening_string_list[ibroadening]
    workdir=basedir+broadening_string+"/sig_b1_78/";
    print(broadening_string);
    print("Reading ", workdir+filename)
    [nb_, nk_, ibfirst_, iblast_, e_mf_, e_qp[:,:,ibroadening]] = readeqpfile_eqp(workdir, filename);
    if ((nb_-nb)>0):
        print("nb mismatch.");
        sys.exit(1);
    if ((nk_-nk)>0):
        print("nk mismatch.");
        sys.exit(2);
    if ((ibfirst_-ibfirst)>0):
        print("ibfirst mismatch.");
        sys.exit(3);
    if ((iblast_-iblast)>0):
        print("iblast mismatch.");
        sys.exit(4);
    if (np.max(np.abs(e_mf - e_mf_)) > 1.0E-10):
        print("e_mf mismatch.");
        sys.exit(5);      
    print("-------------------------------------------")
#Binomial fitting
e_qp_fitted=np.zeros((nb, nk),dtype="float");
fit_parameters=np.zeros((3),dtype="float");
for ib in np.arange(nb):
    for ik in np.arange(nk):
        # Use binomial fitting
        fit_parameters = np.polyfit(broadening_list, e_qp[ib,ik,:], 2);
        # intercept gives the fitted band energy in the limit of zero broadening
        e_qp_fitted[ib,ik] = fit_parameters[2];

#Output e_qp_fitted into "extrapolated_"+filename
fileoutname="extrapolated_"+filename;
print("Output extrapolated bands to "+fileoutname);
with io.open(fileoutname,"w") as fileout:
    for ik in np.arange(nk):
        fileout.write("%12.9f %12.9f %12.9f" % tuple(k_list[ik,:]));
        fileout.write("%5d \n" % nb);
        for ib in np.arange(nb):
            fileout.write("  1 %10d %15.6f %15.6f \n" % tuple((b_list[ib], e_mf[ib,ik], e_qp_fitted[ib,ik])));
print("Done.")

