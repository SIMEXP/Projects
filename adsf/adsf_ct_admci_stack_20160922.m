%% script to stack whole brain civet vertex measures on admci sample for subtyping
% regress out age, gender, whole brain cortical thickness

clear all

files_in.data = '/Users/AngelaTam/Desktop/adsf/admci/admci_civet_vertex_20160916.mat';
files_in.partition = '/Users/AngelaTam/Desktop/adsf/admci/wb_part.mat';
files_in.model = '/Users/AngelaTam/Desktop/adsf/admci/admci_model_20160401_civet_passed.csv';

files_out = struct;

opt.nb_network = 1;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/admci/admci_ct_stack_20160922/';
opt.regress_conf = {'age','gender','mean_ct_wb'};

adsf_brick_ct_stack(files_in,files_out,opt);