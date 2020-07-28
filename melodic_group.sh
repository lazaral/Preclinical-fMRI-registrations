#!/usr/bin/env bash

# This script gets cleaned rs data for each subject and sets off smoothed and unsmoothed gICAs

# definitions
origDir=/vols/Scratch/myelin/4cassandra/30IC_labelled
workDir=/vols/Scratch/myelin/4cassandra/30IC_labelled
scriptDir=/vols/Scratch/alazari/PreclinicalfMRI_registrations

scanList="1"

for i in $(cat 'Preclinical_fulllist_all.txt'); do

  echo "preparing $i"

  for scan in $scanList ; do

  find $workDir/${i}/run"$scan"_rs_timeseries_func2template_linear_spline.nii.gz
  find $workDir/${i}/run"$scan"_rs_timeseries_func2template_linear_spline_s4.nii.gz

  echo "$workDir/${i}/run"$scan"_rs_timeseries_func2template_linear_spline.nii.gz" >> $scriptDir/standard_linear_dirs.txt
  echo "$workDir/${i}/run"$scan"_rs_timeseries_func2template_linear_spline_s4.nii.gz" >> $scriptDir/standard_linear_smoothed_dirs.txt

done

done

mkdir -p $workDir/groupICA30
mkdir -p $workDir/groupICA30_smoothed

# gICA, 30 dimensions, unsmoothed
fsl_sub -q verylong.q melodic -i $scriptDir/standard_linear_dirs.txt -o $workDir/groupICA30 \
    --tr=0.7 --nobet -a concat \
    -m $scriptDir/template_fslcpgeom_brain_mask.nii.gz \
    --report --Oall -d 30

# gICA, 30 dimensions, smoothed
fsl_sub -q verylong.q melodic -i $scriptDir/standard_linear_smoothed_dirs.txt -o $workDir/groupICA30_smoothed \
    --tr=0.7 --nobet -a concat \
    -m $scriptDir/template_fslcpgeom_brain_mask.nii.gz \
    --report --Oall -d 30
