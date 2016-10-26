%% script to calculate residuals of variables in preventad

clear all

files_in.model = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/preventad_ct/model/preventad_model_20161022_wb_weights.csv';
files_in.weight = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/preventad_ct/weights_pad_admci_wb_20161019/subtype_weights.mat';
path_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/preventad_ct/weights_pad_admci_wb_20161019/';

[tab,sub,ly] = niak_read_csv(files_in.model);

load(files_in.weight);

model_raw.y = weight_mat;
model_raw.x = tab;
model_raw.labels_y = ly;
model_raw.labels_x = sub;

opt_model.contrast.age = 0;
opt_model.contrast.gender = 0;
opt_model.contrast.edu = 0;
opt_model.contrast.mean_ct_whole_brain = 0;
opt_model.flag_intercept = true;
opt_model.normalize_x = true;
opt_model.normalize_y = false;
opt_model.flag_filter_nan = true;
opt_model.normalize_type = 'mean';

[model_norm, ~] = niak_normalize_model(model_raw, opt_model);

% filter Nan
nan_model = find(isnan(model_norm.y));
model_norm.y(nan_model) = [];
model_norm.labels_x(nan_model,:) = [];
model_norm.x(nan_model,:) = [];

% opt_glm.test = 'ttest';
% opt_glm.flag_rsquare = true;
% opt_glm.flag_beta = true;
opt_glm.flag_residuals = true;
glm = niak_glm(model_norm,opt_glm);
    
save([path_out 'residual_subtype_weights.mat'],'glm','model_raw','model_norm')