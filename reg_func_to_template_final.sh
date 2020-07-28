#!/usr/bin/env bash

# This script estimates linear and nonlinear functional to template registrations

# definitions
origDir=/vols/Scratch/myelin/4cassandra/30IC_labelled
workDir=/vols/Scratch/myelin/4cassandra/30IC_labelled
scriptDir=/vols/Scratch/alazari/PreclinicalfMRI_registrations

scanList="1"

subjList=""

for i in $subjList; do

  for scan in $scanList ; do

  echo "registering $i"

  # FLIRT affine, dof 12
  flirt10=`fsl_sub -q veryshort.q -l $workDir/${i}/logs flirt -in $workDir/${i}/bssfp_bet_workcopy.nii.gz -ref $scriptDir/template_fslcpgeom_brain.nii.gz -dof 12 -out $workDir/${i}/run"$scan"_struct_to_template_linear -omat $workDir/${i}/run"$scan"_struct_to_template_linear.mat -interp spline`

  # FNIRT with affine, betted input, DOF 12
  fnirt2=`fsl_sub -q veryshort.q -j ${flirt10} -l $workDir/${i}/logs fnirt --in=$workDir/${i}/bssfp_bet_workcopy.nii.gz --ref=$scriptDir/template_fslcpgeom_brain.nii.gz --aff=$workDir/${i}/run"$scan"_struct_to_template_linear.mat --iout=$workDir/${i}/run"$scan"_struct_to_template_fnirt_dof12 --cout=$workDir/${i}/run"$scan"_struct_to_template_fnirt_dof12_warpcoef`

  # Concat linear func2struct and struct2template
  convert_xfm1=`fsl_sub -q veryshort.q -j ${flirt10} -l $workDir/${i}/logs convert_xfm -omat $workDir/${i}/func2template.mat -concat $workDir/${i}/run"$scan"_struct_to_template_linear.mat $workDir/${i}/run"$scan"_rs_mean_clean_brain_reg2struct_7dof.mat`

  # Apply full linear registration
  flirt20=`fsl_sub -q veryshort.q -j ${convert_xfm1} -l $workDir/${i}/logs flirt -in $workDir/${i}/run"$scan"_rs_mean_clean_brain -ref $scriptDir/template_fslcpgeom_brain.nii.gz -applyxfm -init $workDir/${i}/func2template.mat -out $workDir/${i}/run"$scan"_rs_func2template_linear_spline -interp spline`

  # Apply full non-linear registration
  applywarp=`fsl_sub -q veryshort.q -j ${fnirt2} -l $workDir/${i}/logs applywarp --in=$workDir/${i}/run"$scan"_rs_mean_clean_brain --out=$workDir/${i}/run"$scan"_rs_func2template_nonlinear_spline --ref=$scriptDir/template_fslcpgeom_brain.nii.gz --premat=$workDir/${i}/run"$scan"_rs_mean_clean_brain_reg2struct_7dof.mat --warp=$workDir/${i}/run"$scan"_struct_to_template_fnirt_dof12_warpcoef --interp=spline`

done

echo "done"

done
