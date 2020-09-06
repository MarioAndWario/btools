#!/usr/bin/env python
import numpy as np
import io
import os
import sys

omega_threshold=4.09;
file=io.open("./epsinvhead2.txt","rb");
rawdata=np.genfromtxt(file,comments='#');
file.close()

epsinv=np.zeros((len(rawdata)),dtype='complex');
epsinv[:]=rawdata[:,0]+1j*rawdata[:,1]

epsM=np.zeros_like(epsinv,dtype='complex');
epsM[:] = 1.0/epsinv[:]

epsM_out=np.zeros((len(rawdata),2),dtype='float');

epsM_out[:,0] = np.real(epsM[:]);
epsM_out[:,1] = np.imag(epsM[:]);

np.savetxt("epsM.txt",epsM_out,fmt='%.9f  %.9f',delimiter=' ');
