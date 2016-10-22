%% script to generate subtype weights for preventad from admci cortical thickness subtypes

% regress the data (covariates age, gender, mean whole brain cortical thickness)

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

%  generate subtype weights

clear all

files_in.data.wb = '/home/angela/Desktop/adsf/ct_subtypes/preventad_ct/ct_whole_brain_stack_regress_20161019.mat';
files_in.subtype.wb = '/home/angela/Desktop/adsf/ct_subtypes/admci_ct/ct_wb_sub_20161012/subtype.mat';

files_out = struct;

opt.folder_out = '/home/angela/Desktop/adsf/ct_subtypes/preventad_ct/weights_pad_admci_wb_20161019';
opt.scales = 1;
opt.flag_external = true;

adsf_brick_subtype_weight(files_in,files_out,opt);

