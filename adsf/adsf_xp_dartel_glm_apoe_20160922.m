%% glm on whole brain dartel admci subtypes on prevent-ad data apoe

clear all

a_path = '/Users/AngelaTam/Desktop/adsf/dartel_subtypes/preventad_dartel/wb_subtype_adniext_20160922/';
files_in.weight = [a_path 'subtype_weights.mat'];
files_in.model = '/Users/AngelaTam/Desktop/adsf/model/preventad_model_20160916.csv';
files_out = struct;
opt.folder_out = [a_path 'glm_apoe_20160922'];
opt.scale = 1;
opt.contrast.apoe4 = 1;

niak_brick_association_test(files_in,files_out,opt);

% glm visu

files_in.association = [a_path 'glm_apoe_20160922/association_stats.mat'];
files_out = struct;
opt.data_type = 'categorical';

niak_brick_visu_subtype_glm(files_in,files_out,opt);

% chi2 test

files_in.weights = files_in.weight;
files_out = struct;
opt.group_col_id = 'apoe4';
opt.flag_weights = true;
opt.network = 1;

niak_brick_chi_cramer(files_in,files_out,opt);