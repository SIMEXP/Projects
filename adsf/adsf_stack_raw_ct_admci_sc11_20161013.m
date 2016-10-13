
%% script to make stacks for scale 11 ct networks on admci sample

clear all

files_in.data = '/home/angela/Desktop/adsf/ct_subtypes/admci/admci_civet_vertex_20160916.mat';
files_in.partition = '/home/angela/Desktop/adsf/ct_subtypes/admci/admci_basc_ct_20160922/msteps_part.mat';
files_in.model = '/home/angela/Desktop/adsf/ct_subtypes/admci/model/admci_model_20160401_civet_passed.csv';
files_out = struct;
opt.folder_out = '/home/angela/Desktop/adsf/ct_subtypes/admci/basc_sc11_stacks';
psom_mkdir(opt.folder_out);
opt.nb_network = 11;
opt.flag_conf = false;

adsf_brick_ct_stack(files_in,files_out,opt);


