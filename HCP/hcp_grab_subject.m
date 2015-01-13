% grab subject from each of the five HCP discs

opt.path_out = '/media/database8/HCP_task/';
opt.type_task = 'EMOTION';
path_data = '/media/database8/HCP/';
[files_ind,files_group] = niak_extract_preprocessed_hcp(path_data,opt);
