function [] = hcp_ind_model_motor_csv(path_folder,opt)
% generate individual model for motor task HCP database.
%
% SYNTAX:
% [] = HCP_IND_MODEL_MOTOR_CSV(OPT)
%
% _________________________________________________________________________
% PATH_FOLDER (string, default [pwd]) the full path to the root folder that contain the 
%   individual HCP EV's variables. 
%
% OPT
%   (structure, optional) with the following fields :
%
%   TRIAL (string, default 'rh') type of trial that would be extracted, possiblr trial : 'rh', 'lh', 'rf', 'lf' and 't'.
%   TRIAL_DELAY (numeric, default '1,5') time delay before each trial to estimate FIR responses.
%   TRIAL_DURATION (numeric, default '16.5') time for each trial to estimate FIR responses.
%   BASELINE_DELAY (numeric, default '2.5') time delay before each trial's baseline estimate.
%   BASELINE_DURATION (numeric, default '4') time for each trial to estimate baselie for FIR responses.
%   EXP (string, default 'hcp') type of preprocessing used. Possible value 'niak', 'hcp'.

%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%

path_folder = niak_full_path (path_folder);

%% Default options
list_fields   = { 'trial' , 'trial_delay' , 'trial_duration' , 'baseline_delay' , 'baseline_duration' , 'exp' };
list_defaults = { 'rh'    , 1.5           ,  16.5            ,  2.5             ,  4                  , 'hcp' };
if (nargin > 1) && ~isempty(opt.trial) 
    opt = psom_struct_defaults(opt,list_fields,list_defaults);
else
    opt = psom_struct_defaults(struct(),list_fields,list_defaults);
end

%% path and files names
data.dir_output         = path_folder;
data.name_csv_intrarun  = ['hcp_model_intrarun_motor_' lower(opt.trial)];

%% intrarun fir
opt_csv_read.separator= sprintf('\t');
data.covariates_intrarun_names = {'times','duration'};
data.covariates_intrarun_cond  = {opt.trial,opt.trial,'baseline','baseline'};
data.covariates_intrarun_values(1,1) = str2num(niak_read_csv_cell([path_folder opt.trial '.txt'],opt_csv_read){1,1}) - opt.trial_delay;
data.covariates_intrarun_values(1,2) = opt.trial_duration;
data.covariates_intrarun_values(2,1) = str2num(niak_read_csv_cell([path_folder opt.trial '.txt'],opt_csv_read){2,1}) - opt.trial_delay;
data.covariates_intrarun_values(2,2) = opt.trial_duration;
data.covariates_intrarun_values(3,1) = str2num(niak_read_csv_cell([path_folder opt.trial '.txt'],opt_csv_read){1,1}) - opt.baseline_delay;
data.covariates_intrarun_values(3,2) = opt.baseline_duration;
data.covariates_intrarun_values(4,1) = str2num(niak_read_csv_cell([path_folder opt.trial '.txt'],opt_csv_read){2,1}) - opt.baseline_delay;
data.covariates_intrarun_values(4,2) = opt.baseline_duration;
opt_csv_write.labels_y = data.covariates_intrarun_names;
opt_csv_write.labels_x = data.covariates_intrarun_cond;
opt_csv_write.precision = 2;
niak_write_csv(strcat(data.dir_output,data.name_csv_intrarun,'.csv'),data.covariates_intrarun_values,opt_csv_write);

