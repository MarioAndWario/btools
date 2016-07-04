#!/bin/bash
LOOPLIST="20 25 30 35 40 45 50"
for ScreenCutoff in $LOOPLIST
do
  cd $ScreenCutoff
  eqp.py eqp1 sigma_hp.log eqp.dat
  cd ..
done
