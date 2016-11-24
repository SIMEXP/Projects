%% Script to run connectome NIAK connectome pipeline to generate seed-based functional 
%% connectivity maps on NKI_multimodal data

clear all
%%% SET PIPELINE FILES_IN
% Set paths 
path_root = '/gs/project/gsf-624-aa/abadhwar/'; % Root path of you project
path_preproc = [path_root '/NKI_fiftyplus_preprocessed2_with_niakissue100/fmri_preprocess_all_scrubb05']; % Path of Preprocessed data

% Grab files created by NIAK_PIPELINE_FMRI_PREPROCESS
opt_grab.filter.run = {'rest2500'}; % FILTER RUN - Only those runs will be grabbed.
opt_grab.exclude_subject = {'s0101463', 's0110809', 's0130716', 's0144495', 's0163059', 's0175151'}; % EXCLUDE_SUBJECT
opt_grab.type_files = 'glm_connectome'; % TYPE_FILES - formating FILES based on the purpose of subsequent analysis.
files_in = niak_grab_fmri_preprocess(path_preproc, opt_grab);


% Add brain parcels to files_in structure
files_in.network = '/gs/project/gsf-624-aa/database2/preventad/templates/template_cambridge_basc_multiscale_sym_scale007.mnc.gz';

%%% LIST OF SEEDS
% The next step is to generate a list of seeds. This requires creating a text file.
% We are going to use NIAK’s tool to write comma-separated values (CSV) in a file.

files_in.seeds = [path_preproc filesep 'list_seeds.csv'];
opt_csv.labels_x = { 'MOTOR' , 'DMN' }; % The labels for the network
opt_csv.labels_y = { 'index' };
tab = [3 ; 5];
niak_write_csv(files_in.seeds,tab,opt_csv);

%%% SET PIPELINE OPTIONS

% Setup where to store the date
opt.folder_out = [path_root 'connectome_test'];

% Set options such that we will not generate graph properties, just the correlation maps:
opt.flag_p2p = false; % No parcel-to-parcel correlation values
opt.flag_global_prop = false; % No global graph properties
opt.flag_local_prop  = false; % No local graph properties
opt.flag_rmap = true; % Generate correlation maps

% psom option
opt_scores.psom.max_queued = 50;

%%% RUN THE PIPELINE

opt.flag_test = false;
[pipeline,opt] = niak_pipeline_connectome(files_in,opt);

