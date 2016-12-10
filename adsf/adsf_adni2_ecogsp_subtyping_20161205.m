%% script to make cognitive subtypes out of ECOG (pt and study partner) in adni dartel sample

clear all

path_data = '/Users/AngelaTam/Desktop/adsf/';

%% regress out diagnosis from the stack

files_in.data = [path_data 'cognitive_subtypes/adni2_ecogsp_stack.mat'];
files_in.model = [path_data 'rsfmri_subtypes/adni/adni2_model_20161202.csv'];
files_out = [path_data 'cognitive_subtypes/adni2_ecogsp_stack_r_20161205.mat'];

data = load(files_in.data);
stack = data.stack;
list_data = data.list_subject;

% variables to regress
opt.regress_conf = {'diagnosis','age','gender'};

[conf_model, list_subject , cat_names] = niak_read_csv(files_in.model);

% Find the confounds in the variable of the model
mask_conf = ismember(cat_names,opt.regress_conf);
conf_model = conf_model(:,mask_conf);

% Remove subjects with NaN
mask_nan = max(isnan(conf_model),[],2);
if any(mask_nan)
    list_subject(mask_nan)
    warning(sprintf('I had to remove %i subjects (listed above) who had missing values in their confounds.',sum(mask_nan)));
end
conf_model = conf_model(~mask_nan,:);
list_subject = list_subject(~mask_nan,:);

% Remove subjects with no cognitive data
mask_data = ismember(list_subject,list_data);
if any(~mask_data)
    list_subject(~mask_data)
    warning(sprintf('I had to remove %i subjects (listed above) who had missing data.',sum(~mask_data)));
end
conf_model = conf_model(mask_data,:);
list_subject = list_subject(mask_data,:);

% Set up the model structure for the regression
opt_mod = struct;
opt_mod.flag_residuals = true;
m = struct;
m.x = [ones(length(list_subject),1) conf_model];
% Get the correct network
m.y = stack;
[res] = niak_glm(m, opt_mod);
stack = res.e;

% Build the provenance data
provenance = struct;
provenance.subjects = list_subject;
provenance.model = struct;
provenance.model.matrix = m.x;
provenance.model.confounds = opt.regress_conf;
provenance.var_names = data.var_names;

% Save the stack matrix
save(files_out, 'stack', 'provenance');

%% perform subtyping 

clear all

path_data = '/Users/AngelaTam/Desktop/adsf/';
files_in.data = [path_data 'cognitive_subtypes/adni2_ecogsp_stack_r_20161205.mat'];
files_out = struct;
opt.folder_out = 'adni_cog/ecogsp_20161205';
psom_mkdir(opt.folder_out);
opt.nb_subtype = 4;

adsf_brick_cog_subtyping(files_in,files_out,opt);

%% extract weights

clear all

path_data = '/Users/AngelaTam/Desktop/adsf/';
files_in.data.network1 = [path_data 'cognitive_subtypes/adni2_ecogsp_stack_r_20161205.mat'];
files_in.subtype.network1 = [path_data 'cognitive_subtypes/adni_cog/ecogsp_20161205/subtype.mat'];
files_out = struct;
opt.folder_out = [path_data 'cognitive_subtypes/adni_cog/ecogsp_20161205/'];
opt.scales = 1;

adsf_brick_cog_sub_weight(files_in,files_out,opt);
