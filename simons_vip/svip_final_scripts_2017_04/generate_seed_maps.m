clear;
base_path = '/gs/project/gsf-624-aa/simons_vip/';
preproc_path = [base_path filesep 'preproc/svip_prep_final'];
template_path = [base_path filesep 'template/template_cambridge_basc_multiscale_sym_scale012.nii.gz'];
out_path = [base_path filesep 'scores/cambridge012'];

opt_g.exclude_subject = {'s14725xx46xFCAP1','s14785xx5xFCAP1', 's14871xx1xFCAP1', 's14927xx1xFCAP1', 's14928xx1xFCAP1','s14983xx1xFCAP1'};
% Older, stricter QC rules
% opt_g.exclude_subject = {'s14725xx46xFCAP1','s14725xx51xFCAP1', 's14784xx15xFCAP1', 's14785xx5xFCAP1', 's14871xx1xFCAP1', 's14927xx1xFCAP1', 's14928xx1xFCAP1', 's14952xx5xFCAP1', 's14983xx1xFCAP1'};
%% Grab the results from the NIAK fMRI preprocessing pipeline
opt_g.min_nb_vol = 40; % the demo dataset is very short, so we have to lower considerably the minimum acceptable number of volumes per run
opt_g.type_files = 'scores'; % Specify to the grabber that we want to run scores
files_in = niak_grab_fmri_preprocess(preproc_path, opt_g);
files_in.part = template_path;

%% Set pipeline options
opt.folder_out = out_path; % Where to store the results
opt.flag_vol = true;

%% Generate the pipeline
[pipeline, opt_scores] = niak_pipeline_scores(files_in,opt);
