% grab subject from each of the five HCP discs

for nn = 1:4 
    path_data = ['/media/S500-' num2str(nn) '-20140805/'];
    opt.path_out = '/media/database1/';
    opt.type_task = 'EMOTION';
    files = niak_extract_preprocessed_hcp(path_data,opt);
end

opt.path_out = '/media/database1/tmp/';
opt.type_task = 'EMOTION';
path_data = '/media/database1/hcp/';
[files_ind,files_group] = niak_extract_preprocessed_hcp(path_data,opt);

[cell_fmri_mean,labels] = niak_fmri2cell(files_mean);
files_in.vol = cell_fmri_mean;
files_in.mask = files_group.func_mask;
files_out.mean_vol= '';
files_out.tab_coregister= '/fmri_preprocess/quality_control/group_coregistration/func_tab_qc_coregister_stereonl.csv';
files_out.mask_average= '';
files_out.mask_group= '';
opt_g.folder_out = '/media/database1/tmp/';
[files_in,files_out,opt] = niak_brick_qc_coregister(files_in,files_out,opt_g);