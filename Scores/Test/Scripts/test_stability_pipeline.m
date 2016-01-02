%% Simple run script for the niak_pipeline_stability_scores using the standard
% niak test data.
clear all; close all;

%% Grab the demoniak target
%niak_wget('target_test_niak_mnc1');

%% Grab the preprocessed data from the target
path_demo = [pwd filesep 'target_test_niak_mnc1-2015-05-15/demoniak_preproc'];
opt.min_nb_vol = 10;
opt.type_files = 'scores';
in_data = niak_grab_fmri_preprocess(path_demo,opt);
in_data.part = [pwd filesep 'target_test_niak_mnc1-2015-05-15/demoniak_preproc/anat/template_aal.mnc.gz' ];
%% All present and accounted for, let's call the pipeline
opt_scores = struct;
opt_scores.folder_out = [pwd filesep 'scores_demoniak'];
opt_scores.flag_test = false;

%% Call the pipeline
[pipeline, opt_scores] = niak_pipeline_scores(in_data, opt_scores);