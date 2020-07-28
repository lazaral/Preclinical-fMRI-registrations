#!/usr/bin/env bash

# This script bets and applies func2template transformations to the full timeseries. It also smoothes the preprocessed functional timeseries.

# definitions
origDir=/vols/Scratch/myelin/4cassandra/30IC_labelled
workDir=/vols/Scratch/myelin/4cassandra/30IC_labelled
scriptDir=/vols/Scratch/alazari/PreclinicalfMRI_registrations

scanList="1"

subjList=""

for i in $subjList; do

  for scan in $scanList ; do

  echo "betting and applying transform to $i"

  # bet timeseries
  maskFunc1=`fsl_sub -q veryshort.q -l $workDir/${i}/logs fslmaths $workDir/${i}/run"$scan"_rs_clean_workcopy.nii.gz -mul $workDir/${i}/bssfp_bet_workcopy_mask_to_func $workDir/${i}/run"$scan"_rs_clean_brain`

  # Apply full linear registration
  flirt20=`fsl_sub -q veryshort.q -j ${maskFunc1} -l $workDir/${i}/logs flirt -in $workDir/${i}/run"$scan"_rs_clean_brain -ref $scriptDir/template_fslcpgeom_brain.nii.gz -applyxfm -init $workDir/${i}/func2template.mat -out $workDir/${i}/run"$scan"_rs_timeseries_func2template_linear_spline -interp spline`

  # Apply full non-linear registration
  applywarp=`fsl_sub -q veryshort.q -j ${maskFunc1} -l $workDir/${i}/logs applywarp --in=$workDir/${i}/run"$scan"_rs_clean_brain --out=$workDir/${i}/run"$scan"_rs_timeseries_func2template_nonlinear_spline --ref=$scriptDir/template_fslcpgeom_brain.nii.gz --premat=$workDir/${i}/run"$scan"_rs_mean_clean_brain_reg2struct_7dof.mat --warp=$workDir/${i}/run"$scan"_struct_to_template_fnirt_dof12_warpcoef --interp=spline`

  # Created smoothed alternative
  smooth1=`fsl_sub -q veryshort.q -j ${flirt20} -l $workDir/${i}/logs fslmaths $workDir/${i}/run"$scan"_rs_timeseries_func2template_linear_spline -s 4 $workDir/${i}/run"$scan"_rs_timeseries_func2template_linear_spline_s4`


done

echo "done"

done
