#!/usr/bin/env bash

# This script bets the functional scan and estimates the registration from functional to bssfp structural

# definitions
origDir=/vols/Scratch/myelin/4cassandra/30IC_labelled
workDir=/vols/Scratch/myelin/4cassandra/30IC_labelled
scriptDir=/vols/Scratch/alazari/PreclinicalfMRI_registrations

scanList="1"

subjList=""

for i in $subjList; do

  for scan in $scanList ; do

  echo "registering $i"

  # Generate mean image
  meanImage=`fsl_sub -q veryshort.q -l $workDir/${i}/logs fslmaths $workDir/${i}/run"$scan"_rs_clean_workcopy.nii.gz -Tmean $workDir/${i}/run"$scan"_rs_mean_clean`

  # Register 7 func to struct, then invert to bet functional scan
  echo "7 dof registration for $i"
  flirt1=`fsl_sub -q veryshort.q -j ${meanImage} -l $workDir/${i}/logs flirt -in $workDir/${i}/run"$scan"_rs_mean_clean -ref $workDir/${i}/bssfp_bet_workcopy.nii.gz -dof 7 -out $workDir/${i}/run"$scan"_rs_mean_clean_reg2struct_7dof -omat $workDir/${i}/run"$scan"_rs_mean_clean_reg2struct_7dof.mat -interp spline`

  echo "inverting func to struct matrix for $i"
  invMatrix1=`fsl_sub -q veryshort.q -j ${flirt1} -l $workDir/${i}/logs convert_xfm -omat $workDir/${i}/run"$scan"_rs_mean_clean_reg2fun_7dof.mat -inverse $workDir/${i}/run"$scan"_rs_mean_clean_reg2struct_7dof.mat`

  echo "binarise structural $i"
  binarise1=`fsl_sub -q veryshort.q -j ${invMatrix1} -l $workDir/${i}/logs fslmaths $workDir/${i}/bssfp_bet_workcopy.nii.gz -bin $workDir/${i}/bssfp_bet_workcopy_mask`

  echo "apply transformation to brain mask $i"
  flirt2=`fsl_sub -q veryshort.q -j ${binarise1} -l $workDir/${i}/logs flirt -in $workDir/${i}/bssfp_bet_workcopy_mask -ref $workDir/${i}/run"$scan"_rs_mean_clean -applyxfm -init $workDir/${i}/run"$scan"_rs_mean_clean_reg2fun_7dof.mat  -interp nearestneighbour -out $workDir/${i}/bssfp_bet_workcopy_mask_to_func`

  echo "mask func with brain mask $i"
  maskFunc1=`fsl_sub -q veryshort.q -j ${flirt2} -l $workDir/${i}/logs fslmaths $workDir/${i}/run"$scan"_rs_mean_clean -mul $workDir/${i}/bssfp_bet_workcopy_mask_to_func $workDir/${i}/run"$scan"_rs_mean_clean_brain`

  echo "re-run registration with betted func $i"
  flirt3=`fsl_sub -q veryshort.q -j ${maskFunc1} -l $workDir/${i}/logs flirt -in $workDir/${i}/run"$scan"_rs_mean_clean_brain -ref $workDir/${i}/bssfp_bet_workcopy.nii.gz -dof 7 -out $workDir/${i}/run"$scan"_rs_mean_clean_brain_reg2struct_7dof -omat $workDir/${i}/run"$scan"_rs_mean_clean_brain_reg2struct_7dof.mat -interp spline`

done

echo "done"

done
