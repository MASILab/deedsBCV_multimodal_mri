fixed="/home/remedilw/data/pancreas_mri_T2w_from_jack_virostko_ut_austin_downloaded_on_08172023/example_ants_syn/T2.nii.gz"
moving="/home/remedilw/data/pancreas_mri_T2w_from_jack_virostko_ut_austin_downloaded_on_08172023/example_ants_syn/T1.nii.gz"
new_resolution="2x2x2mm"
outdir="/nfs/masi/remedilw/test_deeds_multimodal_mri_output"

/usr/bin/time -v bash reorient_to_LAS_resample_to_isotropic_deeds_registration_and_resample_back_to_fixed_anisotropic.sh $fixed $moving $new_resolution $outdir
