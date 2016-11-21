%% glm on whole brain dartel adni subtypes & fdg

clear all

a_path = '/Users/AngelaTam/Desktop/adsf/dartel_subtypes/adni_dartel/dartel_wb_subtypes_20160926/';
files_in.weight = [a_path 'subtype_weights.mat'];
files_in.model = '/Users/AngelaTam/Desktop/adsf/dartel_subtypes/adni_dartel/adni_dartel_model_20161110.csv';
files_out = struct;
opt.folder_out = [a_path 'glm_fdg_20161110'];
psom_mkdir(opt.folder_out)
opt.scale = 1;
opt.contrast.FDG = 1;
opt.contrast.age = 0;
opt.contrast.sex = 0;
opt.contrast.tiv = 0;
opt.contrast.mean_gm = 0;
opt.contrast.dx = 0;

niak_brick_association_test(files_in,files_out,opt);

% glm visu

files_in.association = [a_path 'glm_fdg_20161110/association_stats.mat'];
files_in.weight = [a_path 'residual_subtype_weights_20161110.mat'];
files_out = struct;
opt.data_type = 'continuous';

niak_brick_visu_subtype_glm(files_in,files_out,opt);
