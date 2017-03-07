%% script to generate subtype weights for preventad from adni2 cortical thickness subtypes

%% regress the data (covariates age, gender, mean whole brain cortical thickness)

clear all

m_path = '/home/angela/Desktop/adsf/';
files_in.data = [m_path 'preventad/raw_structure_data/cortical_thickness/thickness_files_bl_vertex_20150831/preventad_civet_vertex_bl_20160216.mat'];
files_in.model = [m_path 'model/preventad_model_20160916.csv'];
files_in.partition = [m_path 'ct_subtypes/wb_part.mat'];

files_out = struct;

opt.folder_out = [m_path 'ct_subtypes/preventad_ct/'];

opt.nb_network = 1;
opt.regress_conf = {'age','gender','mean_ct_whole_brain'};

adsf_brick_ct_stack(files_in,files_out,opt);

%%  generate subtype weights

clear all

files_in.data.wb = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/preventad/ct_whole_brain_stack_regress_20161019.mat';
files_in.subtype.wb = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/adni2/wb_ct_subtypes_20170122/subtype.mat';

files_out = struct;

opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/preventad/weights_pad_adni2_wb_20170123';
psom_mkdir(opt.folder_out);
opt.scales = 1;
opt.flag_external = true;

adsf_brick_subtype_weight(files_in,files_out,opt);

%% script to test variables (cognition, etc) on weights
clear all

path_c = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/preventad/';
files_in.weight = [path_c 'weights_pad_adni2_wb_20170123/subtype_weights.mat'];
files_in.model = '/Users/AngelaTam/Desktop/adsf/preventad_model.csv';

%vars = {'immediate_memory_index_score','visuospatial_constructional_index_score','language_index_score','attention_index_score','delayed_memory_index_score'};
%vars = {'apoe4','bdnf'};
%vars = {'Tau','Beta','pTau','apoe_csf'};
vars = {'ptau_beta_ratio'};

for ss = 1:length(vars)
    clear opt
    
    field = vars{ss};
    
    files_out = struct;
    opt.folder_out = strcat(path_c, 'weights_pad_adni2_wb_20170123/', field, filesep);
    psom_mkdir(opt.folder_out);
    opt.scale = 1;
    opt.contrast.age = 0;
    opt.contrast.mean_ct_whole_brain = 0;
    opt.contrast.gender = 0;
    %opt.contrast.apoe4 = 0;
    
    opt.contrast.(field) = 1;
    
    niak_brick_association_test(files_in,files_out,opt);
    opt.data_type = 'continuous';
    files_in.association = strcat(path_c, 'weights_pad_adni2_wb_20170123/', field, filesep, 'association_stats.mat');
    adsf_brick_visu_subtype_glm(files_in,files_out,opt);
    
end