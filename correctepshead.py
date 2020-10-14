#!/user/bin/env python3

# This script will copy epsmat.h5 into epsmat.correcthead.h5
# and correct the head epsinv_{00}(q=0;all omega) with the value in eps0mat.h5
import h5py
import numpy as np
import os
import argparse
import subprocess

# check metadata in the two files
def diff_dataset(f_1,f_2,file1, file2, dataset):
    #subprocess.check_output("h5diff %s %s %s"%(file1,file2,dataset),shell=True);
    A=subprocess.call("h5diff %s %s %s"%(file1,file2,dataset),shell=True);
    if (A):
        print("f_1[%s] = %s"%(dataset,f_1[dataset][()]));
        print("f_2[%s] = %s"%(dataset,f_2[dataset][()]));
        raise IOError("Failed: h5diff %s %s %s"%(file1,file2,dataset));

# Setup arguments
# initiate the parser
parser = argparse.ArgumentParser();
parser.add_argument("-V","--version", help="Program version", action="store_true");

file_output = "epsmat.correcthead.h5"
# add long and short argument
parser.add_argument("--file1", "-f", default="epsmat.h5", help="Set first chimat file");
parser.add_argument("--file2", "-F", default="eps0mat.h5", help="Set second chimat file");
parser.add_argument("--output", "-O", default="epsmat.correcthead.h5", help="Set output chimat file");

# read arguments from the command line
args = parser.parse_args();

if args.version:
    print("This is correctepshead.py V0.1");

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

f_1 = h5py.File(file1,'r');
f_2 = h5py.File(file2,'r');

#Check headers of two input files
diff_dataset(f_1,f_2,file1,file2,"/eps_header/flavor");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/freqs");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/ecuts");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/nvb");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/ncb");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/skip_nvb");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/skip_ncb");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/efermi");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/has_advanced");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/icutv");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/intraband_flag");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/intraband_overlap_min");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/matrix_flavor");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/matrix_type");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/nmatrix");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/subsample");
diff_dataset(f_1,f_2,file1,file2,"/eps_header/params/subspace");
diff_dataset(f_1,f_2,file1,file2,"/mf_header");

print("cp %s %s"%(file1,file_output))
A=subprocess.call("cp %s %s"%(file1,file_output),shell=True);
if (A):
    raise IOError("Failed: cp %s %s"%(file1,file_output));

nmtx_max0 = f_2['/eps_header/gspace/nmtx_max'][()]
print("eps0mat.h5 nmtx_max = ", nmtx_max0)
#iq, ifreq, ig2=ig1, icomplex
eps0diag=f_2['/mats/matrix-diagonal'][0,:,0,:]
# Close files
f_1.close();
f_2.close();

# Modify matrix & matrix-diagonal dataset in f_output
with h5py.File(file_output,'r+') as f_output:
    nmtx_max = f_output['/eps_header/gspace/nmtx_max'][()]
    print("epsmat.h5 nmtx_max = ", nmtx_max)
    for imat in np.arange(nmtx_max):
        #iq, imatrix, ifreq, ig2, ig1, icomplex
        f_output['/mats/matrix'][0,0,:,0,0,:] = eps0diag[:,:]
        #iq, ifreq, ig2=ig1, icomplex
        f_output['/mats/matrix-diagonal'][0,:,0,:] = eps0diag[:,:]

    # Add a flag
    if ("/eps_header/params/correcthead" in f_output):
        f_output['/eps_header/params/correcthead'][()] = True
    else:
        correcthead = f_output.create_dataset('/eps_header/params/correcthead', (1,), dtype='int32',data=1)

print("========================");
print("========= Done =========");
