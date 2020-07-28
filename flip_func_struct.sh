#!/usr/bin/env bash

# This script makes working copies of original files and flips them according to paw preference

# definitions
origDir=/vols/Scratch/myelin/4cassandra/30IC_labelled
workDir=/vols/Scratch/myelin/4cassandra/30IC_labelled
scriptDir=/vols/Scratch/alazari/PreclinicalfMRI_registrations

scanList="1"

subjList=""

for i in $subjList; do

  for scan in $scanList ; do

  echo "making working copy of $i"

  # make a working copy of original files
  cp $workDir/${i}/bssfp_bet.nii.gz $workDir/${i}/bssfp_bet_workcopy.nii.gz
  cp $workDir/${i}/run0"$scan".ica/filtered_func_data_clean.nii.gz $workDir/${i}/run"$scan"_rs_clean_workcopy.nii.gz

  echo "flipping $i"

  # flip functional scan
  fslswapdim $workDir/${i}/run"$scan"_rs_clean_workcopy.nii.gz -x y z $workDir/${i}/run"$scan"_rs_mean_clean_workcopy.nii.gz

  # flip structural scan
  fslswapdim $workDir/${i}/bssfp_bet_workcopy.nii.gz -x y z $workDir/${i}/bssfp_bet_workcopy.nii.gz


done

echo "done"

done
