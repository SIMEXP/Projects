function []= max_effect_vol(partition_file,fdr_file)

path_root = [pwd filesep] ;
%  partition_file = 'brain_partition_consensus_group_sci180_scg162_scf159.nii.gz';
%  fdr_file = 'fdr_group_average_sci180_scg162_scf159.mat';
[hdr,vol] = niak_read_vol([ path_root partition_file]);
load ([path_root fdr_file]);
max_eff = max(abs(test_fir.mean),[],1);
hdr.file_name = [path_root  'max_abs_eff.nii.gz'];
niak_write_vol(hdr,niak_part2vol(max_eff,vol));
%  errorbar(test_fir.mean(:,75),test_fir.std(:,75))