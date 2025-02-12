#!

# This script needs to be executed from inside an anaconda environment that has mrgrid installed
# This script assumes that the fixed image is in LAS (according to FSL and nibabel) or RPI (cd3).
# If this assumption is not met, I don't elieve the final conversion of the moving image from isotropic to original fixed image resolution  will succeed or make sense

fixed="$1"
moving="$2"
new_resolution="$3" #example: 2x2x2mm
outdir="$4"

echo "Command line args:"
echo fixed: $fixed
echo moving: $moving
echo resolution during registration: $new_resolution
echo output directory: $outdir
echo

# MASI paths to installations of c3d and 3dresample. These are accessible to anything on the MASI network
c3d="/home-nfs2/local/VANDERBILT/remedilw/programs/c3d-1.0.0-Linux-x86_64/bin/c3d"
reorient="/home-nfs2/local/VANDERBILT/remedis/3dresample"
Warp="/home-nfs2/local/VANDERBILT/remedis/abin/3dWarp"
#fslreorient2std="/home/local/VANDERBILT/caily/Apps/fsl/fsl_v6.0.4/bin/fslreorient2std"

FSLDIR=/home/local/VANDERBILT/caily/Apps/fsl/fsl_v6.0.4
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH



# make output directory if it doesn't exist
if [ ! -d "$outdir" ]; then
    # If it doesn't exist, create it
    mkdir -p "$outdir"
    echo "Directory created: $outdir"
else
    echo "Directory already exists: $outdir"
fi


# Deoblique the data if necessary:
#echo "De-obliquing data if necesary"
#$Warp -deoblique -prefix "$outdir/fixed_deoblique.nii.gz" $fixed
#$Warp -deoblique -prefix "$outdir/moving_deoblique.nii.gz" $moving
#fslreorient2std $fixed "$outdir/fixed_deoblique.nii.gz"
#fslreorient2std $moving "$outdir/moving_deoblique.nii.gz"
#echo
#echo

#fixed="$outdir/fixed_oblique.nii.gz"
#moving="$outdir/moving_oblique.nii.gz"


# Show orientation before correction
echo "Fixed and Moving image orientations before correction:"
$c3d $fixed -info
$c3d $moving -info
echo
echo

#reorient to LAS(in FSL / nibabel convention) (this command uses the opposite convention that's why RPI)
echo Reorienting both fixed and moving image to LAS
mrconvert $fixed "$outdir/fixed_reoriented.nii.gz" -strides -1,2,3 -force
mrconvert $moving "$outdir/moving_reoriented.nii.gz" -strides -1,2,3 -force
#$reorient -orient RPI -inset $fixed -prefix "$outdir/fixed_reoriented.nii.gz"
#$reorient -orient RPI -inset $moving -prefix "$outdir/moving_reoriented.nii.gz"
echo
echo

# Show orientation after correction
echo "Fixed and Moving image orientations after correction:"
$c3d "$outdir/fixed_reoriented.nii.gz" -info
$c3d "$outdir/moving_reoriented.nii.gz" -info
echo

# resample FIXED with c3d without changing the origin
$c3d "$outdir/fixed_reoriented.nii.gz" -resample-mm $new_resolution -o "$outdir/fixed_reoriented_resampled.nii.gz"

# resample MOVING to match fixed_resampled, this respects nifti header information 
mrgrid "$outdir/moving_reoriented.nii.gz" regrid -template "$outdir/fixed_reoriented_resampled.nii.gz" "$outdir/moving_reoriented_resampled.nii.gz"

#=================================================
# Deeds deformable registration
linear="/nfs/masi/remedilw/deedsBCV_multimodal_mri/linearBCV"

deeds="/nfs/masi/remedilw/deedsBCV_multimodal_mri/deedsBCV"


# Linear Registration to initialize deeds
$linear -F "$outdir/fixed_reoriented_resampled.nii.gz" -M "$outdir/moving_reoriented_resampled.nii.gz" -O "$outdir/affine"

$deeds -F "$outdir/fixed_reoriented_resampled.nii.gz" -M "$outdir/moving_reoriented_resampled.nii.gz" -O "$outdir/deeds_nonlinear_isotropic" -A "$outdir/affine_matrix.txt"
#==================================================



# resample the deeds deformably registered isotropic moving image back to the original anisotropic fixed image
# Because the moving image in this command has been forced into LAS, if the original fixed image is not LAS, this amy cause problems.
mrgrid "$outdir/deeds_nonlinear_isotropic_deformed.nii.gz" regrid -template $fixed "$outdir/moving_deeds_nonlinear_resampled_to_fixed_original_resolution.nii.gz" 


















