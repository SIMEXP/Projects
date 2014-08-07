for brain in 10 50 100 200 500
do
	in_file=`echo part_sc${brain}.nii.gz`
	out_file=`echo part_sc${brain}_resampled.nii.gz`
	reference='/home/surchs/Projects/stability_abstract/data/fmri_0051193_session_1_run1.nii.gz'
	3dresample -master ${reference} -prefix ${out_file} -inset ${in_file}
done
