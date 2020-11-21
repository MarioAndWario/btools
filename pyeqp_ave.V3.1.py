#!/usr/bin/env python3
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

# Setup arguments
# initiate the parser
parser = argparse.ArgumentParser();
parser.add_argument("-V","--version", help="Program version", action="store_true");

file_output = "eqp1_ave.dat"
# add long and short argument
parser.add_argument("--file1", "-f", default="eqp1_noR.dat", help="Set first eqp file");
parser.add_argument("--file2", "-F", default="eqp1_R.dat", help="Set second eqp file");
parser.add_argument("--output", "-O", default="eqp1_ave.dat", help="Set output eqp file");

# read arguments from the command line
args = parser.parse_args();

if args.version:
    print("This is pyeqp_ave.py V3.0");

if args.file1:
    print("Input file1: %s" % args.file1);
    if not os.path.exists(args.file1):
        raise IOError("File %s doesn't exist."%(args.file1));
    file1=args.file1;

if args.file2:
    print("Input file2: %s" % args.file2);
    if not os.path.exists(args.file2):
        raise IOError("File %s doesn't exist."%(args.file2));
    file2=args.file2;

# Check which file uses skip_nvb/skip_ncb, we should copy the this file to be output file
if args.output:
    print("Output file: %s" % args.output);
    if os.path.exists(args.output):
        print("%s already exists, we will delete it."%args.output);
        A=subprocess.call("rm %s"%(args.output),shell=True);
        if (A):
            raise IOError("Failed: rm %s"%(args.output));
        file_output=args.output;

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
for ib in np.arange(nb):
    print("%10d"% b_list[ib]);

e_mf=np.zeros([nb, nk], dtype='float');
e_qp_A=np.zeros([nb, nk], dtype='float');
filename=file1;
e_mf=readeqpfile_emf(workdir, filename);
e_qp_A=readeqpfile_eqp(workdir, filename);

e_mf_=np.zeros([nb, nk], dtype='float');
e_qp_B=np.zeros([nb, nk], dtype='float');
filename=file2;
e_mf_=readeqpfile_emf(workdir, filename);
e_qp_B=readeqpfile_eqp(workdir, filename);
if (np.max(np.abs(e_mf - e_mf_)) > 1.0E-10):
    print("e_mf mismatch.");
    sys.exit(5);      

e_qp_ave=np.zeros([nb, nk], dtype='float');
e_qp_ave[:,:]=(e_qp_A[:,:]+e_qp_B[:,:])/2.0;

print("Output extrapolated bands to "+fileoutname);
with io.open(fileoutname,"w") as fileout:
    for ik in np.arange(nk):
        fileout.write("%12.9f %12.9f %12.9f" % tuple(k_list[ik,:]));
        fileout.write("%5d \n" % nb);
        for ib in np.arange(nb):
            fileout.write("  1 %10d %15.6f %15.6f \n" % tuple((b_list[ib], e_mf[ib,ik], e_qp_ave[ib,ik])));
print("Done.")
