octave:39> diary on
octave:40> cd /home/pbellec/database
octave:41> cd HCP_task/
octave:42> ls
octave:43> cd stability_fir_perc_MOTORrh_hcp
octave:44> ls
octave:45> cd stability_group/
octave:46> ls
octave:47> cd sci130_scg104_scf107_nii/
octave:48> ls
octave:49> [hdr,vol] = niak_read_vol('brain_partition_consensus_group_sci130_scg104_scf107.nii.gz');
octave:50> load fdr_group_average_sci130_scg104_scf107.mat
octave:51> max_eff = max(test_fir.mean,[],1);
octave:52> max_eff = max(abs(test_fir.mean),[],1);
octave:53> hdr.file_name = 'max_abs_eff.nii.gz';
octave:54> niak_write_vol(hdr,niak_part2vol(max_eff,vol));
octave:55> 
octave:55> errorbar(test_fir.mean(:,75),test_fir.std(:,75))
octave:56> diary off
