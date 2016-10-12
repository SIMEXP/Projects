%% script to make stacks for scale 4 ct networks

clear all

files_in.data = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/admci_civet_vertex_20160916.mat';
files_in.partition = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/basc_networks_20160922/ct_admci_sc4_part.mat';
files_in.model = '/Users/AngelaTam/Desktop/adsf/admci/admci_model_20160401_civet_passed.csv';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/basc_sc4_stacks/raw/';
opt.nb_network = 4;
opt.flag_conf = false;

adsf_brick_ct_stack(files_in,files_out,opt);

