%% script to stack adni2 in cortical thickness whole brain

clear all

path_c = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/';

files_in.data = [path_c 'adni2/adni2_civet_vertex_native_raw_rms_rsl_20170228.mat'];
files_in.partition = [path_c 'mask_whole_brain.mat'];
files_in.model = '/Users/AngelaTam/Desktop/adsf/adni2_csv/adni2_t1_niak_model.csv';

files_out = [path_c 'adni2/adni2_civet_vertex_stack_r_sites_20170326.mat'];

opt.folder_out = [path_c 'adni2/'];
opt.nb_network = 1;
opt.regress_conf = {'age','gender','mean_ct_wb','manufacturer'};
                	 % confounds to be regressed out
                     
qc_label = 'civet_qc'; % name of column in csv for qc mask
% sites to be excluded
%exc_sites = {'site10','site20','site33','site51','site57','site70','site98','site114','site129','site131'};

%% load the data
data = load(files_in.data);
ct = data.ct;
list_data = data.subject;

% load the basc parcellations
part = load(files_in.partition);
part = part.part';

%% filter out those with failed QC in model
[conf_model,list_subject,cat_names] = niak_read_csv(files_in.model);
qc_col = find(strcmp(qc_label,cat_names));
mask_qc = logical(conf_model(:,qc_col));
conf_model = conf_model(mask_qc,:);
list_subject = list_subject(mask_qc);

% %% filter out subjects in excluded sites
% 
% for ss = 1:length(exc_sites)
%     site_col = find(strcmp(exc_sites{ss},cat_names));
%     mask_site = logical(conf_model(:,site_col));
%     conf_model = conf_model(~mask_site,:);
%     list_subject = list_subject(~mask_site);
% end


%% prepare the confounds

% Find the confounds in the variable of the model
mask_conf = ismember(cat_names,opt.regress_conf);
conf_model = conf_model(:,mask_conf);

% Remove subjects with no imaging data
mask_data = ismember(list_subject,list_data);
if any(~mask_data)
    list_subject(~mask_data)
    warning(sprintf('I had to remove %i subjects (listed above) who had missing imaging data.',sum(~mask_data)));
end
conf_model = conf_model(mask_data,:);
list_subject = list_subject(mask_data,:);

% Remove subjects with NaN from the model and data
mask_nan = max(isnan(conf_model),[],2);
if any(mask_nan)
    list_subject(mask_nan)
    warning(sprintf('I had to remove %i subjects (listed above) who had missing values in their confounds.',sum(mask_nan)));
end
conf_model = conf_model(~mask_nan,:);
list_subject = list_subject(~mask_nan,:);
ct = ct(~mask_nan,:);

%% grab dimensions of the data
n_sub = size(ct,1); % get number of subjects
n_vox = size(ct,2); % number of vertices

%% Regress confounds

% Set up the model structure for the regression
opt_mod = struct;
opt_mod.flag_residuals = true;
m = struct;
m.x = [ones(length(list_subject),1) conf_model];

m.y = ct;
[res] = niak_glm(m, opt_mod);
% Store the residuals in the confound stack
stack = res.e;

%% provenance
provenance = struct;
provenance.subjects = list_subject;
provenance.model = struct;
provenance.model.matrix = m.x;
provenance.model.confounds = opt.regress_conf;

% Save the stack matrix
save(files_out, 'stack', 'provenance');