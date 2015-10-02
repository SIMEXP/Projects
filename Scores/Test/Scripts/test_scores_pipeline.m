%%% demo SCORES script
%% Grab data test
clear all
niak_gb_vars
path_data = [pwd filesep];
niak_wget('target_test_niak_mnc1'); % download demo data set
path_demo = [path_data 'target_test_niak_mnc1-' gb_niak_target_test ];

%% Get the cambridge templates
template.path = [path_demo '/demoniak_preproc/anat/template_cambridge_basc_multiscale_mnc_sym' ];
template.type =  'cambridge_template_mnc';
niak_wget(template);
% select a specific template
scale = 7 ; % select a scale
template_data = [path_data 'template_cambridge_basc_multiscale_mnc_asym'];
template_name = sprintf('template_cambridge_basc_multiscale_sym_scale%03d.mnc.gz',scale);
system([' cp -r ' template.path filesep template_name ' ' path_demo '/demoniak_preproc/anat/']);

%% Grab the results from the NIAK fMRI preprocessing pipeline
opt_g.min_nb_vol = 10; % the demo dataset is very short, so we have to lower considerably the minimum acceptable number of volumes per run
opt_g.type_files = 'scores'; % Specify to the grabber to prepare the files for the stability FIR pipeline

files_in = niak_grab_fmri_preprocess([ path_demo '/demoniak_preproc/' ],opt_g);

%% Set output folder
opt.folder_out = [path_data 'demo_scores/']; % Where to store the results




% Template folder
template_data = [pwd filesep 'template_cambridge_basc_multiscale_mnc_asym'];
template_name = 'template_cambridge_basc_multiscale_asym_scale%03d.mnc.gz';

%% Resample the template to the mask size
scale = 7;
res_in.target = 'target_test_niak_mnc1-2015-05-15/demoniak_preproc/quality_control/group_coregistration/func_mask_group_stereonl.mnc.gz';
res_in.source = 'template_cambridge_basc_multiscale_mnc_asym/template_cambridge_basc_multiscale_asym_scale007.mnc.gz';
res_out = 'template_cambridge_basc_multiscale_mnc_asym/supersmall_mask_007.mnc.gz';
res_opt = struct;
niak_brick_resample_vol(res_in,res_out,res_opt);

%% All present and accounted for, let's call the pipeline
opt_scores = struct;
opt_scores.folder_out = [pwd filesep 'scores_demoniak'];
opt_scores.flag_vol = true;

in_data.part = [template_data filesep 'supersmall_mask_007.mnc.gz'];
in_data.mask = [template_data filesep 'supersmall_mask_007.mnc.gz'];
%% Call the pipeline
[pipeline, opt_scores] = niak_pipeline_stability_scores(in_data, opt_scores);


%% FDR estimation
opt.nb_samps_fdr = 100; % The number of samples to estimate the false-discovery rate

%% Generate the pipeline
[pipeline,opt_pipe] = niak_pipeline_stability_fir(files_in,opt);