#!/bin/bash
#This script will transform KP.q into qpoints list (for epsilon) or kpoints list (for sigma)
#
sed -n "3,$ p" KP.q | awk '{printf("%20.10f %20.10f %20.10f %5.1f %3d \n",$1,$2,$3,1.0,0.0)}' > QP