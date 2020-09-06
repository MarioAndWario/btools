#!/usr/bin/env python
import numpy as np
import io
import os
import sys

workdir="."
savedir=workdir;

file=io.open("./freqs.txt","rb");
rawdata=np.genfromtxt(file,comments='#');
file.close()

nfreq_real=len(rawdata) - np.count_nonzero(rawdata[:,0] <= 0.0) + 1
print("nfreq_real = ", nfreq_real)

omega=np.zeros((nfreq_real),dtype='float');
jdos_bench=np.zeros((nfreq_real),dtype='float');
omega[:]=rawdata[0:nfreq_real,0]

file=io.open("./epsinvhead2.txt","rb");
rawdata=np.genfromtxt(file,comments='#');
file.close()

epsinv_real=np.zeros((nfreq_real),dtype='float');
epsinv_imag=np.zeros((nfreq_real),dtype='float');
epsinv_real[:]=rawdata[0:nfreq_real,0]
epsinv_imag[:]=rawdata[0:nfreq_real,1]

# Check sum rule Eqn. (1054b) in TMISC
area=np.trapz(omega[:]*epsinv_imag[:],omega[:]);
#print("area = ", area);
Ne_target=8.0;
echarge=1.60217662E-19;
mass=9.10938356E-31;
eps0=8.854187817E-12;
a=2.715*2.0*1.0E-10;
hbar=1.0545718E-34;
##############
Omega=a**3/4;
##############
#A=pi * hbar*2 / (2 m eps_0 Omeag)
A=np.pi*hbar**2/(2*mass*eps0)/Omega;
Ne=-area/A
print("Sum_rule_1 = ", Ne/Ne_target)

# Check sum rule Eqn. (J.2.17) in Fundamentals V3
epsinv_imag_over_omega=np.zeros_like(epsinv_imag,dtype='float');
epsinv_imag_over_omega[0]=0
epsinv_imag_over_omega[1:]=epsinv_imag[1:]/omega[1:]
area=np.trapz(epsinv_imag_over_omega[:],omega[:]);
Sum_rule_3=area/(1.0-epsinv_real[0])/(np.pi/2.0)
print("Sum_rule_2 = ", Sum_rule_3);

# file=io.open("./freqs.txt","rb");
# rawdata=np.genfromtxt(file,comments='#');
# file.close()

# omega=np.zeros((nfreq_real),dtype='float');
# jdos_bench=np.zeros((nfreq_real),dtype='float');
# omega[:]=rawdata[0:nfreq_real,0]

file=io.open("./epsM.txt","rb");
rawdata=np.genfromtxt(file,comments='#');
file.close()

epsM_real=np.zeros((nfreq_real),dtype='float');
epsM_imag=np.zeros((nfreq_real),dtype='float');
epsM_real[:]=rawdata[0:nfreq_real,0]
epsM_imag[:]=rawdata[0:nfreq_real,1]

# Check sum rule Eqn. (1054a) in TMISC
area=np.trapz(omega[:]*epsM_imag[:],omega[:]);
#print("area = ", area);
Ne_target=8.0;
echarge=1.60217662E-19;
mass=9.10938356E-31;
eps0=8.854187817E-12;
a=2.715*2.0*1.0E-10;
hbar=1.0545718E-34;
##############
Omega=a**3/4;
##############
#A=pi * hbar*2 / (2 m eps_0 Omeag)
A=np.pi*hbar**2/(2*mass*eps0)/Omega;
Ne=area/A
print("Sum_rule_3 = ", Ne/Ne_target)
