#!/bin/bash

grep 'Head of Epsilon Inverse =' ./eps.out | awk '{print $8}' | tee ./epsinv.dat
