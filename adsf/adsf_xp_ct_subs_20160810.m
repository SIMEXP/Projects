clear all

files_in.partition = '/Users/AngelaTam/Desktop/adsf/ct_basc/adsf_basc_ct_20160316/msteps_part.mat';
files_in.data = '/Users/AngelaTam/Desktop/adsf/structure_data/cortical_thickness/thickness_files_bl_vertex_20150831/preventad_civet_vertex_bl_20160216.mat';
files_in.model = '/Users/AngelaTam/Desktop/adsf/model/preventad_model_20160408.csv';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160810/';
opt.nb_network = 9;
opt.regress_conf = {'age','gender'};

adsf_ct_network_stack(files_in,files_out,opt);

%% subtyping

clear all

path_data = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160810/';
files_in.data = [path_data, 'ct_network_9_stack.mat'];
files_in.mask = [path_data, 'mask_network9.mat'];
files_out = struct;
opt.nb_subtype = 5;
opt.folder_out = [path_data, 'net9'];

adsf_brick_subtyping(files_in,files_out,opt);

%% visu

clear all

files_in = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160810/net9/subtype.mat';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160810/net9/figures/';
opt.nb_subtype = 5;

adsf_visu_ct_subtype(files_in,files_out,opt);

%% weight extraction

clear all

files_in.data.net9 = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160810/ct_network_9_stack.mat';
files_in.subtype.net9 = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160810/net9/subtype.mat';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160810/net9/';

niak_brick_subtype_weight(files_in,files_out,opt);



