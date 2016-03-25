%% Grab data test
clear all
scrub = 'scrub';
path_root = ['/home/yassinebha/scratch/twins/'];
path_preproc = ['/home/yassinebha/database/twins/fmri_preprocess_' scrub filesep ];

%% Get the cambridge templates
%template.path = [path_preproc 'anat/template_cambridge_basc_multiscale_mnc_sym' ];
%template.type =  'cambridge_template_mnc';
%niak_wget(template);

%% Select a specific scale for template
%scale = 7 ; 
%template_name = sprintf('template_cambridge_basc_multiscale_sym_scale%03d.mnc.gz',scale);
%system([' cp -r ' template.path filesep template_name ' ' path_preproc 'anat/']);

%% Grab the results from the NIAK fMRI preprocessing pipeline
opt_g.min_nb_vol = 70;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0.5; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
%opt_g.max_translation = 3 ; % the maximal transition (difference between two adjacent volumes) in translation motion parameters within-run (in mm)
%opt_g.max_rotation = 3 ; % the maximal transition (difference between two adjacent volumes) in rotation motion parameters within-run (in degrees)
opt_g.type_files = 'scores'; % Specify to the grabber to prepare the files for the stability FIR pipeline
opt_g.template =  [path_root '/brain_partition_consensus_group_sci10_scg7_scf7.mnc.gz'];

files_in = niak_grab_fmri_preprocess(path_preproc,opt_g);

%% Set pipeline options
opt.folder_out = [path_root 'stability_scores_' scrub '/']; % Where to store the results
opt.flag_vol = true;

%% Generate the pipeline
opt.psom.max_queued = 300;
[pipeline, opt_scores] = niak_pipeline_scores(files_in,opt);

%%extra
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '/.']); % make a copie of this script to output folder

