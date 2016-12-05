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

opt.folder_out = [path_root 'subtype_test'];

%% Then specify which covariates to use as confounds before the generation of subtypes.
% A list of variable names to be regressed out. If unspecified or left empty, no confounds are regressed

opt.stack.regress_conf = {'FD_scrubbed'};

%% Subtyping
% The options for the subtypes themselves.

opt.subtype.nb_subtype = 3;        % the number of subtypes to extract
opt.subtype.sub_map_type = 'mean'; % the model for the subtype maps (options are 'mean' or 'median')

%%% Now we add an association test between subtypes.
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

%%It is also possible to add a single chi-square test on the relationship between subtypes and a categorical variable.
% string name of the column in files_in.model on which the contigency table will be based.
%opt.chi2 = 'patient';


%%% RUN THE PIPELINE
opt.flag_test = false;
[pipeline,opt] = niak_pipeline_subtype(files_in,opt);

