function [] = maven_model_inscape(path_folder,opt)
% generate individual model for motor task HCP database.
%
% SYNTAX:
% [] = MAVEN_MODEL_INSCAPE(PATH_FOLDER,OPT)
%
% _________________________________________________________________________
% PATH_FOLDER (string, default [pwd]) the full path to the root folder that contain the 
%   individual NKI task model variables. 
%
% OPT
%   (structure, optional) with the following fields :
%
%   TASK (string, default 'inscape') type of trial that would be extracted, possiblr trial : 'inscape'.
%   TRIAL_DELAY (numeric, default '3') time delay before each trial to estimate FIR responses.
%   TRIAL_DURATION (numeric, default '16.5') time for each trial to estimate FIR responses.
%   BASELINE_DELAY (numeric, default '0') time delay before each trial's baseline estimate.
%   BASELINE_DURATION (numeric, default '4') time for each trial to estimate baselie for FIR responses.
%   EXP (string, default '2680') type of TR used. Possible value '2680'.

%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%

path_folder = niak_full_path (path_folder);

%% Default options
list_fields   = { 'task'         , 'trial_delay' , 'trial_duration' , 'baseline_delay' , 'baseline_duration' };
list_defaults = { 'inscape' , 3             ,  415             ,  0               ,  6                  };
if (nargin > 1) && ~isempty(opt.task) 
    opt = psom_struct_defaults(opt,list_fields,list_defaults);
else
    opt = psom_struct_defaults(struct(),list_fields,list_defaults);
end

%% path and files names
data.dir_output         = path_folder;
data.name_csv_intrarun  = ['maven_model_intrarun_' lower(opt.task)];

%% intrarun fir model
opt_csv_read.separator= sprintf(',');
data.covariates_intrarun_names = {'times','duration'};
data.covariates_intrarun_cond  = {'baseline',opt.task};
data.covariates_intrarun_values(1,1) = opt.baseline_delay;
data.covariates_intrarun_values(1,2) = opt.baseline_duration;
data.covariates_intrarun_values(2,1) = opt.trial_delay;
data.covariates_intrarun_values(2,2) = opt.trial_duration;
%% write model to csv
opt_csv_write.labels_y = data.covariates_intrarun_names;
opt_csv_write.labels_x = data.covariates_intrarun_cond;
opt_csv_write.precision = 2;
niak_write_csv(strcat(data.dir_output,data.name_csv_intrarun,'.csv'),data.covariates_intrarun_values,opt_csv_write);

