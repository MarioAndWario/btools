#!/usr/bin/env python

# This script merges an arbitrary number of epsmat.h5 files (in HDF5 format).
# The default output is epsmat_merged.h5, and it can be configured.
# The script requires h5py and numpy to work. On hopper, you should type:
# module load python h5py

# Felipe H. da Jornada <jornada@berkeley.edu> (2013)

import h5py
import sys
import os
from optparse import OptionParser
import numpy as np

usage = '%prog: [options] epsmat_1 [epsmat_2] [...]'
parser = OptionParser(usage=usage)
parser.add_option('--take-kgrid-from', metavar='F_NUM', type='int',
                  help="don't check for consistency of the k-grids."
                       "Instead, use the kgrid from the argument number F_NUM.")
parser.add_option('-o', '--output', default='epsmat_merged.h5', type='str',
                  help="output file. Defaults to 'epsmat_merged.h5'.")
parser.add_option('-f', '--force', default=False, action='store_true',
                  help="don't ask any questions, and overwrite output file if"
                       "it exists.")
(options, args) = parser.parse_args()
if len(args)<2:
    parser.error("wrong number of arguments")

print('Output file:\n> %s\n'%(options.output))
print('Input files:')
for fname in args:
    print('< %s'%(fname))
    if not os.path.exists(fname):
        raise IOError("File %s doesn't exist."%(fname))

fs_in = [h5py.File(fname, 'r') for fname in args]
if options.take_kgrid_from is None:
    ind = 0
else:
    assert options.take_kgrid_from >=1 and options.take_kgrid_from <= len(args), \
        'invalid value (%d) for option --take-kgrid-from.\n'%(options.take_kgrid_from) + \
        'Expecting and integer between %d and %d'%(1,len(args))
    ind = options.take_kgrid_from-1
f1 = fs_in[ind]

if (not options.force) and os.path.exists(options.output):
    # Fix Python 2.x.
    try: input = raw_input
    except NameError: pass
    ans = input('\nOutput file %s already exists. Would you '
                    'like to overwrite it? (y,N) '%(options.output))
    if len(ans)==0 or ans[0].lower()!='y':
        exit(0)
    print("Overwriting output file %s"%(options.output))

###############################################################################
print("\nAnalyzing files and checking consistency against %s\n"%(args[ind]))
###############################################################################

#This is really not hdf5-vy, i.e., to create an array to hold different parameters.
intinfo = f1['intinfo'][...]
#This is stupid. Why not make intinfo[0] == 1 for real and 2 for complex?
scalar_size = intinfo[0] + 1
ng = intinfo[4]
freq_dep = intinfo[2]

#Checking consistency among files wrt f1
for f2 in fs_in:
    if f2==f1: continue
    print('  Checking %s'%(f2.filename))
    assert f1['versionnumber'][...] == f2['versionnumber'][...], 'incompatible file versions'
    assert np.all(f1['gvecs'][...] == f2['gvecs'][...]), 'incompatible G-spaces'
    if options.take_kgrid_from is None:
        ind = [0,2,3,4,6,7,8] # Check k-grid
    else:
        ind = [0,2,3,4] # Don`t check k-grid
    assert np.all(f1['intinfo'][ind] == f2['intinfo'][ind]), 'incompatible headers'
    assert np.allclose(f1['dblinfo'][...], f2['dblinfo'][...]), 'incompatible cutoffs'
    if (freq_dep==2):
        assert np.allclose(f1['freqs'], f2['freqs']), 'incompatible frequency grids'
        assert np.allclose(f1['freqbrds'], f2['freqbrds']), 'incompatible frequency broadenings'
print('  All files are consistent!')

print("\nSummary:\n")
print("  Flavor: %s"%((scalar_size==2 and 'Complex') or 'Real'))
print("  Frequency dependency: %d"%(freq_dep))
print("  Number of frequencies: %d"%(intinfo[3]))
print("  Number of G-vectors: %d"%(ng))
print("  K-grid: %dx%dx%d"%tuple(intinfo[6:9].tolist()))
dblinfo = f1['dblinfo'][...]
print("  Epsilon cutoff: %f"%(dblinfo[0]))
nmtx_max = np.amax([f['intinfo'][5] for f in fs_in])
print("  Maximum rank of the merged epsilon matrix (nmtx): %d"%(nmtx_max))
nq_tot = np.sum([f['intinfo'][1] for f in fs_in])
print("  Total number of q-points after merging: %d"%(nq_tot))

###############################################################################
print("\nWriting output parameters\n")
###############################################################################

f_out = h5py.File(options.output, 'w')
f_out.copy(f1['versionnumber'], 'versionnumber')
f_out.copy(f1['intinfo'], 'intinfo')
# This should be changed in BerkeleyGW. Lumping different parameters in a
# single array is pathetic, and completely against the principles of HDF5!
f_out['intinfo'][[1,5]] = [nq_tot, nmtx_max]
f_out.copy(f1['dblinfo'], 'dblinfo')
f_out.copy(f1['gvecs'], 'gvecs')
if 'nspin' in f1:
    f_out.copy(f1['nspin'], 'nspin')
if 'mf_header' in f1:
    f_out.copy(f1['mf_header'], 'mf_header')
if 'info' in f1:
    f_out.copy(f1['info'], 'info')

if (freq_dep==2):
    f_out.copy(f1['freqs'], 'freqs')
    f_out.copy(f1['freqbrds'], 'freqbrds')

def merge_fields(field, shape, dtype):
    f_out.create_dataset(field, shape, dtype)
    f_out[field][...] = np.concatenate([f[field][...] for f in fs_in], axis=0)

merge_fields('qpoints', (nq_tot,3), 'd')
merge_fields('nmtx-of-q', (nq_tot,), 'i')
merge_fields('q-gvec-ekin', (nq_tot,ng), 'd')
merge_fields('q-gvec-index', (nq_tot,2,ng), 'i')
if 'qpt_done' in f1:
    merge_fields('qpt_done', (nq_tot,), 'i')

print("  Ok!")

###############################################################################
print("\nWriting output matrices\n")
###############################################################################

shape = np.array(f1['matrix-diagonal'].shape)
shape[[0,1]] = [nq_tot, nmtx_max] #shape = (nq, nmtx_max, 1|2)
f_out.create_dataset('matrix-diagonal', shape, 'd')

shape = np.array(f1['matrix'].shape)
shape[[0,2,3]] = [nq_tot, nmtx_max, nmtx_max] #shape = (nq, 1|2, nmtx_max, nmtx_max, nfreq, 1|2)
f_out.create_dataset('matrix', shape, 'd')

iq_glob = 0
for f in fs_in:
    nq = f['intinfo'][1]
    for iq in xrange(nq):
        nmtx_q = f['nmtx-of-q'][iq]
        print("  Dealing with q=%d/%d (rank=%d)"%(iq_glob+1, nq_tot, nmtx_q))
        f_out['matrix-diagonal'][iq_glob,:nmtx_q,:] = (
            f['matrix-diagonal'][iq,:nmtx_q,:] )
        f_out['matrix'][iq_glob,:,:nmtx_q,:nmtx_q,:,:] = (
            f['matrix'][iq,:,:nmtx_q,:nmtx_q,:,:] )
        iq_glob += 1
f_out.close()

print('\nAll done!\n')
