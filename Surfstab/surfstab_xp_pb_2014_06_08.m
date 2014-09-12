clear
path_data = '/home/pbellec/database/stability_surf/';

in.fmri = [path_data 'preproc' filesep 'EJ2203' filesep 'fmri_EJ2203_session1_rest.nii.gz'];

% Scale 10
in.part = [path_data 'basc_cambridge_sc10.nii.gz'];
opt.folder_out = [path_data 'xp_pb_2014_06_08' filesep];
opt.sampling.type = 'window';
opt.sampling.opt.length = 30;
psom_mkdir(opt.folder_out);
niak_brick_scores_fmri_v2(in,struct(),opt);

% mricron /home/pbellec/database/stability_surf/preproc/EJ2203/anat_EJ2203_nuc_stereonl.nii.gz -c -0 -o stability_maps.nii.gz -c 5redyell -l 0.05 -h 1&

% Scale 100
in.part = [path_data 'basc_cambridge_sc100.nii.gz'];
opt.folder_out = [path_data 'xp_pb_2014_06_08b' filesep];
opt.sampling.type = 'window';
opt.sampling.opt.length = 30;
psom_mkdir(opt.folder_out);
niak_brick_scores_fmri_v2(in,struct(),opt);
