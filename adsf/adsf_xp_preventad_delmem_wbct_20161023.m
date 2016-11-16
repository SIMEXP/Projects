%% script for glm of wb ct subtype weights on delayed memory in prevent-ad

clear all

files_in.model = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/preventad_ct/model/preventad_model_20161022_wb_weights.csv';
path_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/preventad_ct/weights_pad_admci_wb_20161019/glm_delmem_20161023/';

[tab,sub,ly] = niak_read_csv(files_in.model);

model_raw.y = tab(:,22);
model_raw.x = tab;
model_raw.labels_y = ly;
model_raw.labels_x = sub;

x_field = {'sub1_w','sub2_w','sub3_w','sub4_w'};

for xx = 1:length(x_field)
    field = x_field{xx};
    
    opt_model.contrast.(field) = 1;
    opt_model.contrast.age = 0;
    opt_model.contrast.gender = 0;
    opt_model.contrast.edu = 0;
    opt_model.contrast.mean_ct_whole_brain = 0;
    opt_model.flag_intercept = true;
    opt_model.normalize_x = true;
    opt_model.normalize_y = false;
    opt_model.flag_filter_nan = true;
    opt_model.normalize_type = 'mean';
    
    [model_norm.(field), ~] = niak_normalize_model(model_raw, opt_model);

    % filter Nan
    nan_model = find(isnan(model_norm.(field).y));
    model_norm.(field).y(nan_model) = [];
    model_norm.(field).labels_x(nan_model,:) = [];
    model_norm.(field).x(nan_model,:) = [];
    
    opt_glm.test = 'ttest';
    opt_glm.flag_rsquare = true;
    opt_glm.flag_beta = true;
    opt_glm.flag_residuals = true;
    glm.(field) = niak_glm(model_norm.(field),opt_glm);
    clear opt_model
end
save([path_out 'association_stats.mat'],'glm','model_raw','model_norm')

clear all

files_in.weight = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/preventad_ct/weights_pad_admci_wb_20161019/subtype_weights.mat';
files_in.residuals = 'residual_association_stats.mat';
files_out = struct;
opt.folder_out = pwd;
opt.contrast.delayed_memory_index_score = 1;
opt.data_type = 'continuous';
opt.scale = 1;

adsf_brick_visu_subtype_glm_res(files_in,files_out,opt);



