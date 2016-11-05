%%%%SCORES pipeline
%%%%%november 2016 
%%%%P. Bellec lab
%%%% Simons VIP cohort , C. Moreau


clear all

addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-v0.17.0/'))

%niak_gb_vars
path_data = '/gs/project/gsf-624-aa/simons_vip/';

%% Select a specific scale and template

template.path = path_data;
template.type ='cambridge_template_nii';
niak_wget(template);

%scale = 12 ; % select a scale
template_data = path_data ;
%template_name = sprintf('template_cambridge_basc_multiscale_sym_scale%03d.nii.gz',scale);
template_name = 'template_cambridge_basc_multiscale_asym_scale007.nii.gz';

%%% 
opt_g.exclude_subject = {'s14867xx37xFCAP1','s14979xx2xFCAP1'};
%% Grab the results from the NIAK fMRI preprocessing pipeline
opt_g.min_nb_vol = 100; % the demo dataset is very short, so we have to lower considerably the minimum acceptable number of volumes per run
opt_g.type_files = 'scores'; % Specify to the grabber to prepare the files for the stability FIR pipeline
files_in = niak_grab_fmri_preprocess('/gs/project/gsf-624-aa/simons_vip/svip_prep_test_rest1_2_10_27',opt_g);

files_in.part = [template_data filesep template_name];

%% Set pipeline options
opt.folder_out = [path_data 'scores_11_04/']; % Where to store the results
opt.flag_vol = true;

%% Generate the pipeline
[pipeline, opt_scores] = niak_pipeline_scores(files_in,opt);
