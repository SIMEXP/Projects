%% script to test admci status with network cortical thickness subtypes in admci sample

%% association with admci status

clear all

files_in.weight = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc11_sub_20161013/net1/subtype_weights.mat';
files_in.model = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/model/admci_model_20161013_civet_sc11.csv';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc11_sub_20161013/net1/glm_admci_20161013';
psom_mkdir(opt.folder_out);
opt.scale = 1;
opt.contrast.admci = 1;
opt.contrast.gender = 0;
opt.contrast.age = 0;
opt.contrast.mean_ct_wb = 0;
opt.contrast.sc11_mean_ct_net1 = 0;
opt.contrast.mnimci = 0;
opt.contrast.criugmad = 0;
opt.contrast.criugmmci = 0;
opt.contrast.adni5 = 0;

niak_brick_association_test(files_in,files_out,opt);

%% visu glm

files_in.association = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc11_sub_20161013/net1/glm_admci_20161013/association_stats.mat';
files_out = struct;
opt.contrast.admci = 1;
opt.data_type = 'categorical';
opt.scale = 1;

adsf_brick_visu_subtype_glm(files_in,files_out,opt);

%% chi2 test

files_in.subtype = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc11_sub_20161013/net1/subtype.mat';
files_in.weights = files_in.weight;
opt.group_col_id = 'admci';
opt.network = 1;

niak_brick_chi_cramer(files_in,files_out,opt);