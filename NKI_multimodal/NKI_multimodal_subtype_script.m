%% Script to run Subtype pipeline
%% subtypes on NKI_multimodal data

clear all
%%% SET PIPELINE FILES_IN
% Set paths
path_root = '/gs/project/gsf-624-aa/abadhwar/'; % Root path of you project

%%% Phenotypic data
% Specify path to model file
files_in.model = [path_root 'nki_2016_10_05_ALL3_aman.csv'];

%%% Connectivity maps
% Grab files created by niak_pipeline_connectome
path_connectome = [path_root 'connectome_T77_20161124']; % Path of Connectome data
files_conn = niak_grab_connectome(path_connectome);

% Note: files_conn = scalar structure containing the fields network_rois, connectome, rmap, R77_aDMN_1, R77_aDMN_2, mask

files_in.data = files_conn.rmap;

%%% Brain mask
% Specify the mask of brain networks to the pipeline, so that it can use it to mask the grey matter

files_in.mask = files_conn.network_rois;


%%% SET PIPELINE OPTIONS
%% Setup where to store the date.

%opt.folder_out = [path_root 'subtype_test'];
%opt.folder_out = [path_root 'subtype_test_4subtypes'];
%opt.folder_out = [path_root 'subtype_test_5subtypes'];
%opt.folder_out = [path_root 'subtype_test_6subtypes'];
%opt.folder_out = [path_root 'subtype4_FullFourSum'];
%opt.folder_out = [path_root 'subtype4_testing_2bassociations'];
opt.folder_out = [path_root 'subtype4_20170104'];

%% Then specify which covariates to use as confounds before the generation of subtypes.
% A list of variable names to be regressed out. If unspecified or left empty, no confounds are regressed

opt.stack.regress_conf = {'FD_scrubbed'};

%% Subtyping
% The options for the subtypes themselves.

%opt.subtype.nb_subtype = 3;        % the number of subtypes to extract
opt.subtype.nb_subtype = 4;        % the number of subtypes to extract
%opt.subtype.nb_subtype = 5;        % the number of subtypes to extract
%opt.subtype.nb_subtype = 6;        % the number of subtypes to extract
opt.subtype.sub_map_type = 'mean'; % the model for the subtype maps (options are 'mean' or 'median')


%%% Now we add an association test between subtypes. - Block_1 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST01.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST01.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST01.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST01.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST01.contrast.BMI = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST01.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST01.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
opt.association.TEST01.contrast.Sex = 0;      % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST01.type_visu = 'continuous';
%%% Block_1 end


%%% Now we add an association test between subtypes. - Block_2 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST02.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST02.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST02.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST02.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST02.contrast.FullFourSum = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST02.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST02.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
opt.association.TEST02.contrast.Sex = 0;      % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST02.type_visu = 'continuous';
%%% Block_2 end


%%% Now we add an association test between subtypes. - Block_3 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST03.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST03.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST03.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST03.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST03.contrast.FullFourPerc = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST03.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST03.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
opt.association.TEST03.contrast.Sex = 0;      % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST03.type_visu = 'continuous';
%%% Block_3 end


%%% Now we add an association test between subtypes. - Block_4 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST04.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST04.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST04.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST04.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST04.contrast.Diastolic = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST04.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST04.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
opt.association.TEST04.contrast.Sex = 0;      % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST04.type_visu = 'continuous';
%%% Block_4 end


%%% Now we add an association test between subtypes. - Block_5 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST05.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST05.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST05.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST05.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST05.contrast.Systolic = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST05.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST05.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
opt.association.TEST05.contrast.Sex = 0;      % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST05.type_visu = 'continuous';
%%% Block_5 end


%%% Now we add an association test between subtypes. - Block_6 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST06.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST06.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST06.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST06.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST06.contrast.Pulse = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST06.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST06.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
opt.association.TEST06.contrast.Sex = 0;      % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST06.type_visu = 'continuous';
%%% Block_6 end


%%% Now we add an association test between subtypes. - Block_7 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST07.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST07.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST07.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST07.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST07.contrast.Neuroticism = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST07.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST07.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
opt.association.TEST07.contrast.Sex = 0;      % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST07.type_visu = 'continuous';
%%% Block_7 end


%%% Now we add an association test between subtypes. - Block_8 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST08.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST08.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST08.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST08.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST08.contrast.Extraversion = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST08.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST08.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
opt.association.TEST08.contrast.Sex = 0;      % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST08.type_visu = 'continuous';
%%% Block_8 end


%%% Now we add an association test between subtypes. - Block_9 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST09.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST09.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST09.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST09.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST09.contrast.Openness = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST09.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST09.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
opt.association.TEST09.contrast.Sex = 0;      % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST09.type_visu = 'continuous';
%%% Block_9 end


%%% Now we add an association test between subtypes. - Block_10 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST10.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST10.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST10.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST10.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST10.contrast.Agreeableness = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST10.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST10.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
opt.association.TEST10.contrast.Sex = 0;      % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST10.type_visu = 'continuous';
%%% Block_10 end


%%% Now we add an association test between subtypes. - Block_11 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST11.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST11.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST11.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST11.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST11.contrast.Conscientiousness = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST11.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST11.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
opt.association.TEST11.contrast.Sex = 0;      % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST11.type_visu = 'continuous';
%%% Block_11 end


%%% Now we add an association test between subtypes. - Block_12 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST12.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST12.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST12.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST12.flag_intercept = true;

% To test a main effect of a variable _ AGE
opt.association.TEST12.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST12.contrast.Sex = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST12.contrast.Age = 1;     % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST12.type_visu = 'continuous';
%%% Block_12 end

%%% Now we add an association test between subtypes. - Block_13 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST13.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST13.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST13.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST13.flag_intercept = true;

% To test a main effect of a variable _ AGE
opt.association.TEST13.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST13.contrast.Sex = 1;      % scalar number for the weight of the variable in the contrast
opt.association.TEST13.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST13.type_visu = 'continuous';
%%% Block_13 end


%%It is also possible to add a single chi-square test on the relationship between subtypes and a categorical variable.
% string name of the column in files_in.model on which the contigency table will be based.
%opt.chi2 = 'patient';


%%% RUN THE PIPELINE
opt.flag_test = false;
[pipeline,opt] = niak_pipeline_subtype(files_in,opt);

