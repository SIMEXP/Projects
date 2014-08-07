#!/bin/bash

in_dir=${1}
ref=${2}

for brain in 10 50 100 200 500
do
    echo ${in_dir}
    echo
    echo ${ref}
    echo
	file=`echo ${1}/brain_partition_consensus_group_sci${brain}_scg${brain}_scf${brain}.mnc.gz`
	echo 'Converting '${file}
    out_name=`echo part_sc${brain}.nii`
	mnc2nii ${file} ${out_name}
    
    echo 'Resampling '${out_name}' according to '${2}
	out_file=`echo ${1}/part_sc${brain}_resampled.nii.gz`
	reference=${2}
	3dresample -master ${reference} -prefix ${out_file} -inset ${out_name}
    
done
