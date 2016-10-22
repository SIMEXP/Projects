%% subtyping sc4 basc ct admci networks on admci sample

%% make the subtypes
clear all

path_data = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/basc_sc4_stacks/regress_agesexmeanct/';
path_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/';
psom_mkdir(path_out);

for ss = 1:4
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

path_data = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/';

for ss = 1:4
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
path_stack = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/basc_sc4_stacks/regress_agesexmeanct/';
path_sub = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/';

for ss = 1:4
    files_in.data.net = strcat(path_stack, 'ct_network_', num2str(ss), '_stack.mat');
    files_in.subtype.net = strcat(path_sub, 'net', num2str(ss), '/subtype.mat');
    files_out = struct;
    opt.folder_out = strcat(path_sub, 'net', num2str(ss));
    
    adsf_brick_subtype_weight(files_in,files_out,opt);
    clear files_in
end

%% association with diagnosis

clear all

net_fields = {'mean_ct_sc4_net1','mean_ct_sc4_net2','mean_ct_sc4_net3','mean_ct_sc4_net4'};

for ss = 1:4
    files_in.model = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/model/admci_model_20161007_sc4.csv';
    files_in.weight = strcat('/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net',num2str(ss),'/subtype_weights.mat');
    files_out = struct;
    opt.folder_out = strcat('/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net',num2str(ss),'/glm_dx_20161012');
    psom_mkdir(opt.folder_out)
    
    opt.scale = 1;
    opt.contrast.dx = 1;
    opt.contrast.gender = 0;
    opt.contrast.age = 0;
    opt.contrast.mean_ct_wb = 0;
    opt.contrast.mnimci = 0;
    opt.contrast.criugmad = 0;
    opt.contrast.criugmmci = 0;
    opt.contrast.adni5 = 0;
    
    field = net_fields{ss};
    opt.contrast.(field) = 0;
        
    niak_brick_association_test(files_in,files_out,opt);
    
    clear opt
    clear files_in
end

%% visu glm
clear all

files_in.weight = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net1/subtype_weights.mat';
files_in.association = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net1/glm_dx_20161012/association_stats.mat';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net1/glm_dx_20161012/';
opt.contrast.dx = 1;
opt.data_type = 'categorical';
opt.scale = 1;

adsf_brick_visu_subtype_glm(files_in,files_out,opt);

%% chi2 test
clear all

files_in.model = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/model/admci_model_20161007_sc4.csv';
files_in.subtype = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net1/subtype.mat';
files_in.weights = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net1/subtype_weights.mat';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net1/glm_dx_20161012/';
opt.group_col_id = 'dx';
opt.network = 1;

niak_brick_chi_cramer(files_in,files_out,opt);