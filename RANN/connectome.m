%% Script to run connectome NIAK connectome pipeline to generate seed-based functional maps. Rmaps will be used to generate the subsequent subtype-based analysisé
%% adapted from NKI_multimodal@Aman_Bahdwar
%% SIMEXP - Pierre Bellec

clear all

% Set paths
path_niak = ('/gs/project/gsf-624-aa/quarantaine/niak-issue100/')
addpath(genpath(path_niak))
path_data = '/gs/project/gsf-624-aa/RANN/'; %% GUILLIMIN
%%% path_data = '/home/pferr/RANN/'; %% MAGMA 

% Grab files created by NIAK_PIPELINE_FMRI_PREPROCESS
%%opt_grab.filter.run = {'rest'}; % FILTER RUN - Only those runs will be grabbed.
%%opt_grab.exclude_subject = {'s0101463', 's0110809', 's0130716', 's0144495', 's0163059', 's0175151'}; % EXCLUDE_SUBJECT
opt_grab.type_files = 'glm_connectome'; % TYPE_FILES - formating FILES based on the purpose of subsequent analysis.
files_in.fmri = niak_grab_fmri_preprocess([path_data 'RANNbackup/FINAL_preprocess_test_issue100_16.03.03'],opt_g).fmri; 

% Add brain parcels to files_in structure
%% partition (based on my sample, at a given scale of interest, out of BASC. Here scale 68 as a trial)
files_in.network = [path_data 'RANNbackup/MSTEPS_task_synant4/stability_group/sci70_scg70_scf68/brain_partition_consensus_group_sci70_scg70_scf68.mnc.gz'];

%Aman's: files_in.network = '/gs/project/gsf-624-aa/database2/preventad/templates/template_cambridge_basc_multiscale_sym_scale007.mnc.gz';

%%% LIST OF SEEDS
% The next step is to generate a list of seeds. This requires creating a text file.
% We are going to use NIAK’s tool to write comma-separated values (CSV) in a file.

%files_in.seeds = [path_preproc filesep 'list_seeds.csv'];
files_in.seeds = [path_preproc filesep 'list_seeds_RANN_rest_and_tasks_68.csv'];
opt_csv.labels_x = { 'broca' , 'temporal_post','temporal_ant','temporal_lobe' }; % The labels for the network
opt_csv.labels_y = { 'index' };
tab = [30 ; 47; 51 ; 44];
niak_write_csv(files_in.seeds,tab,opt_csv);

%%% SET PIPELINE OPTIONS

% Setup where to store the date
opt.folder_out = [path_data 'RANNbackup/RANN_connectome_sc53_161128'];

% Set options such that we will or not generate graph properties, (or just the correlation maps):
opt.flag_p2p = false; % parcel-to-parcel correlation values
opt.flag_global_prop = false; % global graph properties
opt.flag_local_prop  = false; % local graph properties
opt.flag_rmap = true; % Generate correlation maps

% psom option
opt_scores.psom.max_queued = 300;

%%% RUN THE PIPELINE

opt.flag_test = false;
[pipeline,opt] = niak_pipeline_connectome(files_in,opt);
