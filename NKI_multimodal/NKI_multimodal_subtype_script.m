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
opt.folder_out = [path_root 'subtype4_20161229'];

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
opt.association.TEST.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST.contrast.BMI = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST.type_visu = 'continuous';
%%% Block_1 end


%%% Now we add an association test between subtypes. - Block_2 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST2.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST2.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST2.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST2.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST2.contrast.FullFourSum = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST2.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST2.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST2.type_visu = 'continuous';
%%% Block_2 end


%%% Now we add an association test between subtypes. - Block_3 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST3.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST3.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST3.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST3.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST3.contrast.FullFourPerc = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST3.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST3.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST3.type_visu = 'continuous';
%%% Block_3 end


%%% Now we add an association test between subtypes. - Block_4 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST4.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST4.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST4.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST4.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST4.contrast.Diastolic = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST4.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST4.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST4.type_visu = 'continuous';
%%% Block_4 end


%%% Now we add an association test between subtypes. - Block_5 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST5.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST5.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST5.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST5.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST5.contrast.Systolic = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST5.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST5.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST5.type_visu = 'continuous';
%%% Block_5 end


%%% Now we add an association test between subtypes. - Block_6 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST6.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST6.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST6.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST6.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST6.contrast.Pulse = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST6.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST6.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST6.type_visu = 'continuous';
%%% Block_6 end


%%% Now we add an association test between subtypes. - Block_7 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST7.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST7.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST7.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST7.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST7.contrast.Neuroticism = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST7.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST7.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST7.type_visu = 'continuous';
%%% Block_7 end


%%% Now we add an association test between subtypes. - Block_8 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST8.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST8.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST8.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST8.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST8.contrast.Extraversion = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST8.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST8.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST8.type_visu = 'continuous';
%%% Block_8 end


%%% Now we add an association test between subtypes. - Block_9 begin
% scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.TEST9.fdr = 0.05;
% turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.TEST9.normalize_x = false;
% turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.TEST9.normalize_y = false;
% turn on/off adding a constant covariate to the model
opt.association.TEST9.flag_intercept = true;

% To test a main effect of a variable
opt.association.TEST9.contrast.Openness = 1; % scalar number for the weight of the variable in the contrast
opt.association.TEST9.contrast.FD_scrubbed = 0;      % scalar number for the weight of the variable in the contrast
opt.association.TEST9.contrast.Age = 0;     % scalar number for the weight of the variable in the contrast
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST9.type_visu = 'continuous';
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
% type of data for visulization (options are 'continuous' or 'categorical')
opt.association.TEST11.type_visu = 'continuous';
%%% Block_11 end


%%It is also possible to add a single chi-square test on the relationship between subtypes and a categorical variable.
% string name of the column in files_in.model on which the contigency table will be based.
%opt.chi2 = 'patient';


%%% RUN THE PIPELINE
opt.flag_test = false;
[pipeline,opt] = niak_pipeline_subtype(files_in,opt);

