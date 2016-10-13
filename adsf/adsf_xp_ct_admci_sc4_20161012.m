%% glm to test admci status with scale 4 ct basc admci networks on admci sample

%% association with admci status

clear all

net_fields = {'mean_ct_sc4_net1','mean_ct_sc4_net2','mean_ct_sc4_net3','mean_ct_sc4_net4'};

for ss = 1:4
    files_in.model = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/model/admci_model_20161007_sc4.csv';
    files_in.weight = strcat('/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net',num2str(ss),'/subtype_weights.mat');
    files_out = struct;
    opt.folder_out = strcat('/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net',num2str(ss),'/glm_admci_20161012');
    psom_mkdir(opt.folder_out)
    
    opt.scale = 1;
    opt.contrast.admci = 1;
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
files_in.association = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net1/glm_admci_20161012/association_stats.mat';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net1/glm_admci_20161012/';
opt.contrast.admci = 1;
opt.data_type = 'categorical';
opt.scale = 1;

adsf_brick_visu_subtype_glm(files_in,files_out,opt);

%% chi2 test
clear all

files_in.model = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/model/admci_model_20161007_sc4.csv';
files_in.subtype = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net1/subtype.mat';
files_in.weights = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net1/subtype_weights.mat';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/net1/glm_admci_20161012/';
opt.group_col_id = 'admci';
opt.network = 1;

niak_brick_chi_cramer(files_in,files_out,opt);