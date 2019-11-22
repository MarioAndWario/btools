#!/bin/bash

# This script will sum up all the values in a3Dr

File=$1

sed -n "14,$ p" $File | awk '{total = total + $3} END {print "Total Amount collected = "total}'
