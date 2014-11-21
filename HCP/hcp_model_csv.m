function [] = hcp_model_csv(root_path,opt)
% generate group and individual model for HCP database.
%
% SYNTAX:
% [] = HCP_MODEL_CSV(OPT)
%
% _________________________________________________________________________
% root_path (string, default [pwd]) the full path to the root folder that contain the 
%   HCP Preprocessed data. 
%
% OPT
%   (structure, optional) with the following fields :
%
%   TASK (string, default 'MOTOR') type of tasks that would be extracted. Possibles tasks are: 'EMOTION',
%       'GAMBLING','LANGUAGE','MOTOR','REST','RELATIONAL','SOCIAL','WM'.
%   EXP (string, default '') type of experiment that would be extracted

%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%
%% Default path
if isempty(root_path)
   root_path = [pwd filesep];
end
root_path = niak_full_path (root_path);

%% Default options
list_fields   = { 'task'    , 'exp'};
list_defaults = { 'emotion' , 'hcp'   };
if (nargin > 1)  
    opt = psom_struct_defaults(opt,list_fields,list_defaults);
else
    opt = psom_struct_defaults(struct(),list_fields,list_defaults);
end


%  %  %% Setting input/output files 
%  %  [status,cmdout] = system ('uname -n');
%  %  server          = strtrim(cmdout);
%  %  if strfind(server,'lg-1r') % This is guillimin
%  %      root_path = '/gs/scratch/yassinebha/HCP/';
%  %      fprintf ('server: %s (Guillimin) \n ',server)
%  %      my_user_name = getenv('USER');
%  %  elseif strfind(server,'ip05') % this is mammouth
%  %      root_path = '/mnt/parallel_scratch_ms2_wipe_on_april_2015/pbellec/benhajal/HCP/';
%  %      fprintf ('server: %s (Mammouth) \n',server)
%  %      my_user_name = getenv('USER');
%  %  else
%  %      switch server
%  %          case 'peuplier' % this is peuplier
%  %          root_path = '/media/scratch2/HCP_unproc_tmp/';
%  %          fprintf ('server: %s\n',server)
%  %          my_user_name = getenv('USER');
%  %          
%  %          case 'noisetier' % this is noisetier
%  %          root_path = '/media/database1/';
%  %          fprintf ('server: %s\n',server)
%  %          my_user_name = getenv('USER');
%  %      end
%  %  end

%% path and files names
data.dir_output         = [root_path 'fmri_preprocess_' upper(opt.task) '_' lower(opt.exp) '/EVs/'];
data.name_csv_group     = 'hcp_model_group';
data.name_csv_intrarun  = 'hcp_model_intrarun';

%% subjects
data.subs =  {'HCP100307','HCP100408'};

%% group
data.covariates_group_subs        = data.subs;
data.covariates_group_names       = {'sex','age'};
data.covariates_group_values(:,1) = [0;1]; % 1=f
data.covariates_group_values(:,2) = [30;43];

opt_group.labels_y = data.covariates_group_names;
opt_group.labels_x = data.covariates_group_subs;
opt_group.precision = 2;

niak_write_csv(strcat(data.dir_output,data.name_csv_group,'.csv'),data.covariates_group_values,opt_group);


%% intrarun glmfir
data.covariates_intrarun_names =   {'times','duration'};
data.covariates_intrarun_cond = {'task','baseline'};
data.covariates_intrarun_values(1,1) = 0;
data.covariates_intrarun_values(1,2) = 125.72; %175 vols x 0.72 (=TR)
data.covariates_intrarun_values(2,1) = 0;
data.covariates_intrarun_values(2,2) = 2.16; % 3x0.72 (=TR)
opt_ind.labels_y = data.covariates_intrarun_names;
opt_ind.labels_x = data.covariates_intrarun_cond;
opt_ind.precision = 2;
niak_write_csv(strcat(data.dir_output,data.name_csv_intrarun,'.csv'),data.covariates_intrarun_values,opt_ind);

