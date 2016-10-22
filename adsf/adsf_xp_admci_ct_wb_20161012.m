%% script to test admci status with whole brain cortical thickness subtypes in admci sample

%% association with admci status

clear all

files_in.weight = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/subtype_weights.mat';
files_in.model = '/Users/AngelaTam/Desktop/adsf/admci/admci_model_20160401_civet_passed.csv';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/glm_admci_20161012';
opt.scale = 1;
opt.contrast.admci = 1;
opt.contrast.gender = 0;
opt.contrast.age = 0;
opt.contrast.mean_ct_wb = 0;
opt.contrast.mnimci = 0;
opt.contrast.criugmad = 0;
opt.contrast.criugmmci = 0;
opt.contrast.adni5 = 0;

niak_brick_association_test(files_in,files_out,opt);

%% visu glm
clear all

files_in.weight = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/subtype_weights.mat';
files_in.association = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/glm_admci_20161012/association_stats.mat';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/glm_admci_20161012/';
opt.contrast.admci = 1;
opt.data_type = 'categorical';
opt.scale = 1;

adsf_brick_visu_subtype_glm(files_in,files_out,opt);

%% chi2 test
clear all

files_in.model = '/Users/AngelaTam/Desktop/adsf/admci/admci_model_20160401_civet_passed.csv';
files_in.subtype = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/subtype.mat';
files_in.weights = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/subtype_weights.mat';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/glm_admci_20161012/';
opt.group_col_id = 'admci';
opt.network = 1;

niak_brick_chi_cramer(files_in,files_out,opt);