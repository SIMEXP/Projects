%% based on script to subtype on adni dartel: whole brain by Angela Tam (available on github: 
%%%https://github.com/SIMEXP/Projects/blob/master/adsf/adsf_dartel_subtype_wb_20160912.m)
%%%adapted to RANN database by Perrine Ferré in a PhD Project, under supervision of Pierre Bellec//SIMEXP.

clear all

%% set up paths
path_data = '/gs/project/gsf-624-aa/RANN/path/to/individual_rmpas'; %rmaps can come from SCORES or connectome (but SCORES too complex for the need and connectome deals with difficulty with FDR correction)
path_out = '/gs/project/gsf-624-aa/RANN/RANNbackup/SUBTYPE/';

%% set up files_in structure
%%note: check subjects order

% mask (could be out of preproc or grey matter only (check PB script))
%???????? files_in.mask = '??????? /home/atam/scratch/adni_dartel/mask/mask_gm_dartel_adni.mnc.gz';

%read the model file (specific to the data explored: if exploration of different groups, better have differente models, or possible to have an opt.filter)
files_in.model = '/gs/project/gsf-624-aa/RANN/Models/XXX';

%file_name_template 
file_template = 

%% Configure the inputs for files_in.data
pheno = niak_read_csv_cell(files_in.model);

%%%%%%%%%%%%%%%%%%%%%%%
%% Pipeline options  %%
%%%%%%%%%%%%%%%%%%%%%%%

%% General
opt.scale = 4;                                      % integer for the number of networks specified in files_in.data

%% Stack :CONFOUND REGRESSION (averages the different groups)
opt.stack.flag_conf = true;                    % turn on/off regression of confounds during stacking (true: apply / false: don't apply)
opt.stack.regress_conf = {'gender','fd'};     % a list of varaible names to be regressed out (average FD)

%% Subtyping
opt.subtype.nb_subtype = 3;       % the number of subtypes to extract
opt.subtype.sub_map_type = 'mean';        % the model for the subtype maps (options are 'mean' or 'median')


%% Association testing via GLM
%note: better correct for confound variables here AGAIN (would not hurt at least). 

% GLM options
opt.flag_assoc = true;                                % turn on/off GLM association testing (true: apply / false: don't apply)
opt.association.fdr = 0.05;                           % scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.type_fdr = 'BH';                      % method for how the FDR is controlled
opt.association.normalize_x = true;                   % turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.normalize_y = false;                  % turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.normalize_type = 'mean';              % type of correction for normalization (options: 'mean', 'mean_var')
opt.association.flag_intercept = true;                % turn on/off adding a constant covariate to the model

% Note the pipeline can only test one main effect or interaction at a time

% To test a main effect of a variable
opt.association.contrast.diagnosis = 1;    % scalar number for the weight of the variable in the contrast
opt.association.contrast.age = 0;               % scalar number for the weight of the variable in the contrast
opt.association.contrast.gender = 0;               % scalar number for the weight of the variable in the contrast

% Visualization
opt.flag_visu = true;               % turn on/off making plots for GLM testing (true: apply / false: don't apply)
opt.visu.data_type = 'categorical';  % type of data for contrast or interaction in opt.association (options are 'continuous' or 'categorical')

%% Chi2 statistics

opt.flag_chi2 = true;               % turn on/off running Chi-square test (true: apply / false: don't apply)
opt.chi2.group_col_id = 'diagnosis';    % string name of the column in files_in.model on which the contigency table will be based
%%%%%???? fmri??? files_in.fmri = niak_grab_fmri_preprocess([path_data 'RANNbackup/FINAL_preprocess_test_issue100_16.03.03'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored.
%%%%% in case you grab the raw data instead of the niak preprocessed: %%%%
%% Go through the subjects and then make me some files_in struct
%go_by = '';
%% Find where that is
%for ind = 1:size(pheno,2)
%    if strcmp(pheno{1, ind}, go_by)
%        go_ind = ind;
%    end
%end
%
%for ind = 2:size(pheno,1)
%    sub_name = [pheno{ind, go_ind}];
%    % Get the file name and path
%    file_name = sprintf('smwc1ADNI_%s_MR_MPRAGE.mnc.gz', sub_name);
%    file_path = [path_data filesep file_name];
%    files_in.data.(sub_name) = file_path;
%end

%% options

opt.folder_out = path_out;
opt.scale = 1;
opt.stack.regress_conf = {'age','education',''genderMF','Syn_Perf', 'Ant_Perf','mean_gm'};
opt.subtype.nb_subtype = 4;
opt.flag_assoc = true;
opt.association.contrast.diagnosis = 1;
%%%%%% ?????? opt.flag_chi2 = true;
%%%%%% ?????? opt.chi2.group_col_id = 'diagnosis';
opt.flag_visu = true;
%%%%%% ?????? continuous ??? opt.visu.data_type = 'categorical';

%% run pipeline
[pipe,opt] = niak_pipeline_subtype(files_in,opt);
