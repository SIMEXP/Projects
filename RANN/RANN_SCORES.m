% Copyright (c) Pierre Bellec, 
%   Montreal Neurological Institute, 2008-2010.
%   Research Centre of the Montreal Geriatric Institute
%   & Department of Computer Science and Operations Research
%   University of Montreal, Québec, Canada, 2010-2012
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.

%Modified by Perrine Ferré

clear all
niak_gb_vars
path_niak = ('/gs/project/gsf-624-aa/quarantaine/niak-issue100/');
addpath(genpath(path_niak))
%%%%%%%%%%%%%
path_data = '/gs/project/gsf-624-aa/RANN/'; %% GUILLIMIN
path_fmri = [path_data 'RANNbackup/FINAL_preprocess_test_issue100_16.03.03/fmri/'];
path_folder_out = [path_data 'RANNbackup/RANN_SCORES/SCORES_ant_sc184/'];
%path_folder_out = '/home/perrine/scratch/RANN/SCORES_syn/';
%path_folder_out = '/home/perrine/scratch/RANN/SCORES_pictname/';
%path_folder_out = '/home/perrine/scratch/RANN/SCORES_rest/';

%%%%%%%%%%%%%
%%% Grab the data:
opt.g.filter.run = {'ant'};
opt_g.min_nb_vol = 60; % 
%% preproc
%%%% MERCI YASSINE TYPO %%%%
files_in = niak_grab_fmri_preprocess([ path_data 'RANNbackup/FINAL_preprocess_test_issue100_16.03.03/'],opt_g);
%% exclude subjects:
%opt_g.exclude_subject = {''}
%% partition (based on my sample, at a given scale of interest, out of BASC. Here scale 68 as a trial)
files_in.part = [path_data 'RANNbackup/RANN_MSTEPS_rest_and_tasks/stability_group/sci160_scg176_scf184/brain_partition_consensus_group_sci160_scg176_scf184.mnc.gz']
%% = scale 184 rest&tasks

%%scale 68 ant_syn%% 'RANNbackup/MSTEPS_task_synant4/stability_group/sci70_scg70_scf68/brain_partition_consensus_group_sci70_scg70_scf68.mnc.gz']

%% mask (group out of my sample, extracted from preproc)
files_in.mask = [path_data 'RANNbackup/FINAL_preprocess_test_issue100_16.03.03/quality_control/group_coregistration/anat_mask_group_stereonl.mnc.gz/']

opt.folder_out = path_folder_out;
opt.psom.max_queued = 300;
opt.psom.qsub_options = '-A gsf-624-aa -q sw -l walltime=3:00:00';
% opt.scores.flag_target = true;
% opt.scores.flag_deal = true;
pipeline = niak_pipeline_scores(files_in, opt);



%%%% ________________FORMER VERSION OUT OF P.ORBANS AND TUTORIAL: __________________
%% Grab data test
%clear
%niak_gb_vars
%path_niak = ('/gs/project/gsf-624-aa/quarantaine/niak-issue100/');
%addpath(genpath(path_niak))
%%%%%%%%%%%%%
%path_data = '/gs/project/gsf-624-aa/RANN/'; %% GUILLIMIN
%path_out  = [path_data 'RANNbackup/RANN_SCORES/SCORES_ant/'];
%path_out  = '/home/perrine/scratch/RANN/SCORES_syn/';
%path_out  = '/home/perrine/scratch/RANN/SCORES_pictname/';
%path_out  = '/home/perrine/scratch/RANN/SCORES_rest/';


%%%%%%%%%%%%%%
%% Get the MSTEPS templates, for each task (with same scale)!
%from scores-tutorial:
%template.path = [path_data 'RANNbackup/MSTEPS_task_synant4']
%% ???????? find name of file in stab_group_mnc file pour chaque tâche:
%template.type =  'sci70_scg70_scf68/brain_partition_consensus_group_sci70_scg70_scf68.mnc.gz' %%'cambridge_template_mnc';
%niak_wget(template);

% or Angela's:
%in_path = [path_data 'RANNbackup/FINAL_preprocess_test_issue100_16.03.03/fmri/'];
%% ???????? find name of file in stab_group_mnc file pour chaque tâche:comme 'preventad/templates/template_cambridge_basc_multiscale_sym_scale012.mnc.gz';
%part_path = [path_data 'RANNbackup/MSTEPS_task_synant4/sci70_scg70_scf68/brain_partition_consensus_group_sci70_scg70_scf68.mnc.gz']
%% ???????? find name of file individual:
%file_template = [path_data 'RANNbackup/MSTEPS_task_synant4/...........'] 'fmri_subject[0-9]*_session1_r1d[0-9]*.mnc.gz';
%files_include = {'session1'};
%%%%%%%%%%%%%%%%

%%% ????????? necessary to have a spe. scale (not according to 'help_niak_scores' ?????????
%% Select a specific scale and template
%scale = 7 ; % select a scale
%template_data = [path_data 'template_cambridge_basc_multiscale_mnc_asym'];
%template_name = sprintf('template_cambridge_basc_multiscale_sym_scale%03d.mnc.gz',scale);
%system([' cp -r ' template.path filesep template_name ' ' path_data '/demoniak_preproc/anat/']);

%% Grab the results from the NIAK fMRI preprocessing pipeline
%opt_g.min_nb_vol = 60; % 
%opt_g.type_files = 'scores'; % Specify to the grabber to prepare the files for the stability FIR pipeline ??????? FIR ?????
%files_in = niak_grab_fmri_preprocess([ path_data 'RANN_backup/FINAL_preprocess_test_issue100_16.03.03/';' ],opt_g);
%% exclude subjects:
%opt_g.exclude_subject = {''}

%%%%%%%%%%%%%%%%%%%%
%optional ???????? check syntax here:
% Search for the files we need and build the structure
%f = dir(in_path);
%[~, path_name, ~] = niak_fileparts(in_path);
%in_strings = {f.name};
%in_strings = in_strings(3:end);
%in_files.fmri = struct;
% Compute the number of matched files
%fnames = fieldnames(in_files.fmri);
%numf = length(fnames);
%disp(sprintf('I found %d files in %s.\n', numf, in_path));
%%%%%%%%%%%%%%%%%%%%


%% Set pipeline options
%opt.folder_out = [path_data '/RANN_SCORES/']; % Where to store the results
%opt.flag_vol = true;
%opt.psom.max_queued = 300;
%opt.scores.flag_target = true;
%opt.scores.flag_deal = true;

%% Generate the pipeline
%[pipeline, opt_scores] = niak_pipeline_scores(files_in,opt);
