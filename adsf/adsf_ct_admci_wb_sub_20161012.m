%% admci cortical thickness subtypes whole brain

%% script to stack whole brain civet vertex measures on admci sample for subtyping
% regress out age, gender, whole brain cortical thickness, and sites

clear all

files_in.data = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/admci_civet_vertex_20160916.mat';
files_in.partition = '/Users/AngelaTam/Desktop/adsf/admci/wb_part.mat';
files_in.model = '/Users/AngelaTam/Desktop/adsf/admci/admci_model_20160401_civet_passed.csv';

files_out = struct;

opt.nb_network = 1;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/admci_ct_wb_stack_20161012/';
opt.regress_conf = {'age','gender','mean_ct_wb','mnimci','criugmad','criugmmci','adni5'};

adsf_brick_ct_stack(files_in,files_out,opt);


%% make the subtypes
clear all

path_data = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/admci_ct_wb_stackr_20161012/';
path_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/';
psom_mkdir(path_out);

for ss = 1
    files_in.data = strcat(path_data, 'ct_network_', num2str(ss), '_stack.mat');
    files_in.mask = strcat(path_data, 'mask_network', num2str(ss), '.mat');
    files_out = struct;
    opt.nb_subtype = 4;
    opt.folder_out = [path_out, 'net', num2str(ss)];
    psom_mkdir(opt.folder_out)
    
    adsf_brick_subtyping(files_in,files_out,opt);
    clear files_in
end

%% make the maps
clear all

path_data = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/';

for ss = 1
    files_in = strcat(path_data, 'net', num2str(ss), '/subtype.mat');
    files_out = struct;
    opt.folder_out = strcat(path_data, 'net', num2str(ss), '/figures');
    psom_mkdir(opt.folder_out)
    opt.nb_subtype = 4;
    
    adsf_brick_visu_ct_sub(files_in,files_out,opt);
    clear files_in
end

%% weight extraction

clear all
path_stack = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/admci_ct_wb_stackr_20161012/';
path_sub = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/';

for ss = 1
    files_in.data.net = strcat(path_stack, 'ct_network_', num2str(ss), '_stack.mat');
    files_in.subtype.net = strcat(path_sub, 'net', num2str(ss), '/subtype.mat');
    files_out = struct;
    opt.folder_out = strcat(path_sub, 'net', num2str(ss));
    
    adsf_brick_subtype_weight(files_in,files_out,opt);
    clear files_in
end

%% association with diagnosis

clear all

files_in.weight = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/subtype_weights.mat';
files_in.model = '/Users/AngelaTam/Desktop/adsf/admci/admci_model_20160401_civet_passed.csv';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/glm_dx_20161012';
opt.scale = 1;
opt.contrast.dx = 1;
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
files_in.association = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/glm_dx_20161012/association_stats.mat';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/glm_dx_20161012/';
opt.contrast.dx = 1;
opt.data_type = 'categorical';
opt.scale = 1;

adsf_brick_visu_subtype_glm(files_in,files_out,opt);

%% chi2 test
clear all

files_in.model = '/Users/AngelaTam/Desktop/adsf/admci/admci_model_20160401_civet_passed.csv';
files_in.subtype = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/subtype.mat';
files_in.weights = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/subtype_weights.mat';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/net1/glm_dx_20161012/';
opt.group_col_id = 'dx';
opt.network = 1;

niak_brick_chi_cramer(files_in,files_out,opt);
