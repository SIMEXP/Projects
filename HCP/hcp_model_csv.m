% this script generate group models for hcp data
clear all
%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%
task  = 'emotion';
exp   = 'hcp';

%% Setting input/output files 
[status,cmdout] = system ('uname -n');
server          = strtrim(cmdout);
if strfind(server,'lg-1r') % This is guillimin
    root_path = '/gs/scratch/yassinebha/HCP/';
    fprintf ('server: %s (Guillimin) \n ',server)
    my_user_name = getenv('USER');
elseif strfind(server,'ip05') % this is mammouth
    root_path = '/mnt/parallel_scratch_ms2_wipe_on_april_2015/pbellec/benhajal/HCP/';
    fprintf ('server: %s (Mammouth) \n',server)
    my_user_name = getenv('USER');
else
    switch server
        case 'peuplier' % this is peuplier
        root_path = '/media/scratch2/HCP_unproc_tmp/';
        fprintf ('server: %s\n',server)
        my_user_name = getenv('USER');
        
        case 'noisetier' % this is noisetier
        root_path = '/media/database1/';
        fprintf ('server: %s\n',server)
        my_user_name = getenv('USER');
    end
end

%% path and files names
data.dir_output         = [root_path 'fmri_preprocess_' upper(task) '/EVs/'];
data.name_csv_group     = 'hcp_model_group';
data.name_csv_intrarun  = 'hcp_model_intrarun';

%% subjects
data.subs =  {'HCP100307','HCP100408'};

%% group
data.covariates_group_subs        = data.subs;
data.covariates_group_names       = {'sex','age'};
data.covariates_group_values(:,1) = [0;1]; % 1=f
data.covariates_group_values(:,2) = [30;43];

opt.labels_y = data.covariates_group_names;
opt.labels_x = data.covariates_group_subs;
opt.precision = 2;

niak_write_csv(strcat(data.dir_output,data.name_csv_group,'.csv'),data.covariates_group_values,opt)


%% intrarun glmfir
data.covariates_intrarun_names =   {'times','duration'};
data.covariates_intrarun_cond = {'task','baseline'};
data.covariates_intrarun_values(1,1) = 0;
data.covariates_intrarun_values(1,2) = 125.72; %175 vols x 0.72 (=TR)
data.covariates_intrarun_values(2,1) = 0;
data.covariates_intrarun_values(2,2) = 2.16; % 3x0.72 (=TR)
opt.labels_y = data.covariates_intrarun_names;
opt.labels_x = data.covariates_intrarun_cond;
opt.precision = 2;
niak_write_csv(strcat(data.dir_output,data.name_csv_intrarun,'.csv'),data.covariates_intrarun_values,opt)

