%% glm on whole brain dartel adni subtypes on mmse

clear all

a_path = '/Users/AngelaTam/Desktop/adsf/dartel_subtypes/adni_dartel/dartel_wb_subtypes_20160926/';
files_in.weight = [a_path 'subtype_weights.mat'];
files_in.model = '/Users/AngelaTam/Desktop/adsf/dartel_subtypes/adni_dartel/adni_dartel_model_20160930.csv';
files_out = struct;
opt.folder_out = [a_path 'glm_adas11_codxedu_20161004'];
opt.scale = 1;
opt.contrast.ADAS11 = 1;
opt.contrast.age = 0;
opt.contrast.sex = 0;
opt.contrast.tiv = 0;
opt.contrast.mean_gm = 0;
opt.contrast.diagnosis = 0;
opt.contrast.education = 0;

niak_brick_association_test(files_in,files_out,opt);

% glm visu

files_in.association = [a_path 'glm_adas11_codxedu_20161004/association_stats.mat'];
files_out = struct;
opt.data_type = 'continuous';

niak_brick_visu_subtype_glm(files_in,files_out,opt);

