%% Simple run script for the niak_pipeline_stability_scores using the standard
% niak test data.
clear all; close all;

%% Grab the demoniak target
niak_wget('target_test_niak_mnc1');

%% Grab the preprocessed data from the target
fmri_data = [pwd filesep 'target_test_niak_mnc1-2015-05-15/demoniak_preproc'];
opt.min_nb_vol = 10;
in_data = niak_grab_fmri_preprocess(fmri_data, opt);

%% Get the cambridge template
data.url = 'http://files.figshare.com/1861822/template_cambridge_basc_multiscale_mnc_asym.zip';
data.name = 'template_cambridge_basc_multiscale_mnc_asym.zip';
niak_wget(data);
% Template folder
template_data = [pwd filesep 'template_cambridge_basc_multiscale_mnc_asym'];
template_name = 'template_cambridge_basc_multiscale_asym_scale%03d.mnc.gz';

%% Resample the template to the mask size
scale = 7;
system('mincresample -like target_test_niak_mnc1-2015-05-15/demoniak_preproc/quality_control/group_coregistration/func_mask_group_stereonl.mnc.gz template_cambridge_basc_multiscale_mnc_asym/template_cambridge_basc_multiscale_asym_scale007.mnc.gz template_cambridge_basc_multiscale_mnc_asym/supersmall_mask_007.mnc');

%% All present and accounted for, let's call the pipeline
opt_scores = struct;
opt_scores.folder_out = [pwd filesep 'scores_demoniak'];
in_data.part = [template_data filesep 'supersmall_mask_007.mnc'];
%% Call the pipeline
[pipeline, opt_scores] = niak_pipeline_stability_scores(in_data, opt_scores);