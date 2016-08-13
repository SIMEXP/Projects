%% making ct stack maps regressing out age, gender, mean_whole_brain_ct

clear all

files_in.data = '/Users/AngelaTam/Desktop/adsf/raw_structure_data/cortical_thickness/thickness_files_bl_vertex_20150831/preventad_civet_vertex_bl_20160216.mat';
files_in.partition = '/Users/AngelaTam/Desktop/adsf/ct_basc/adsf_basc_ct_20160316/msteps_part.mat';
files_in.model = '/Users/AngelaTam/Desktop/adsf/model/model_preventad_20160813.csv';

files_out = struct;

opt.nb_network = 9;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_stack_age_gender_meanwbct/';
opt.regress_conf = {'age','gender','mean_ct_whole_brain'};

adsf_brick_ct_stack(files_in,files_out,opt);