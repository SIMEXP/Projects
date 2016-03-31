% grab the preprocessed NKI data and run niak_pipeline_scores
% grab preprocessed data
opt_grab = struct;
opt_grab.filter.run = {'rest645', 'rest1400', 'rest2500'};
opt_grab.exclude_subject = {'s0101463', 's0110809', 's0130716', 's0144495', 's0163059', 's0175151'};
opt_grab.type_files = 'scores';

path_preproc = '/gs/project/gsf-624-aa/abadhwar/NKI_fiftyplus_preprocessed2_with_niakissue100/fmri_preprocess_all_scrubb05';
data = niak_grab_fmri_preprocess(path_preproc, opt_grab);

% cambridge templates
files_in = struct;
files_in.part = '/gs/project/gsf-624-aa/database2/preventad/templates/template_cambridge_basc_multiscale_sym_scale007.mnc.gz';
files_in.mask = '/gs/project/gsf-624-aa/database2/preventad/templates/mask.mnc.gz';
files_in.data = data.data;

% call pipeline
opt_scores = struct;

opt_scores.files_out.stability_maps = false;
opt_scores.files_out.partition_cores = false;
opt_scores.files_out.stability_intra = false;
opt_scores.files_out.stability_inter = false;
opt_scores.files_out.stability_contrast = false;
opt_scores.files_out.partition_thresh = false;
opt_scores.files_out.rmap_part = true;
opt_scores.files_out.rmap_cores = false;
opt_scores.files_out.dual_regression = false;

opt_scores.psom.max_queued = 50;
opt_scores.folder_out = '/gs/project/gsf-624-aa/abadhwar/Scores';

[pipeline,opt_scores] = niak_pipeline_scores(files_in,opt_scores);
