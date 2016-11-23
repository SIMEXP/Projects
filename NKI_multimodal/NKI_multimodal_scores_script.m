%%% grab the preprocessed NKI data and run niak_pipeline_scores

%% niak_grab_fmri_preprocess.m
% grab preprocessed data 
opt_grab = struct;
%opt_grab.filter.run = {'rest645', 'rest1400', 'rest2500'};
opt_grab.filter.run = {'rest2500'};
opt_grab.exclude_subject = {'s0101463', 's0110809', 's0130716', 's0144495', 's0163059', 's0175151'};
opt_grab.type_files = 'scores';

path_preproc = '/gs/project/gsf-624-aa/abadhwar/NKI_fiftyplus_preprocessed2_with_niakissue100/fmri_preprocess_all_scrubb05';
data = niak_grab_fmri_preprocess(path_preproc, opt_grab);

%% refer to niak_pipeline_scores
% files_in: providing path to data, mask and part(in this case cambridge templates)
files_in = struct;
files_in.data = data.data;
files_in.mask = '/gs/project/gsf-624-aa/database2/preventad/templates/mask.mnc.gz';
files_in.part = '/gs/project/gsf-624-aa/database2/preventad/templates/template_cambridge_basc_multiscale_sym_scale007.mnc.gz';
%files_in.part = '/gs/project/gsf-624-aa/database2/preventad/templates/brain_parcellation_mcinet_basc_sym_77rois.mnc.gz';
%files_in.part = '/gs/project/gsf-624-aa/database2/preventad/templates/brain_parcellation_mcinet_basc_sym_77rois_21-22.mnc';
%files_in.part = '/gs/project/gsf-624-aa/database2/preventad/templates/brain_parcellation_mcinet_basc_sym_77rois.mnc';

% opt: files_out
opt_scores = struct;
opt_scores.files_out.stability_maps = true;
opt_scores.files_out.partition_cores = false;
opt_scores.files_out.stability_intra = false;
%opt_scores.files_out.stability_inter = false;
opt_scores.files_out.stability_inter = true;
opt_scores.files_out.stability_contrast = false;
opt_scores.files_out.partition_thresh = false;
opt_scores.files_out.rmap_part = true;
opt_scores.files_out.rmap_cores = true;
opt_scores.files_out.dual_regression = false;

% note this option is missing from the documentation and have asked for this to be fixed
%opt_scores.folder_out = '/gs/project/gsf-624-aa/abadhwar/Scores';
%opt_scores.folder_out = '/gs/project/gsf-624-aa/abadhwar/Scores_test';
%opt_scores.folder_out = '/gs/project/gsf-624-aa/abadhwar/Scores_T77';
%opt_scores.folder_out = '/gs/project/gsf-624-aa/abadhwar/Scores_T77_P21_P22';
%opt_scores.folder_out = '/gs/project/gsf-624-aa/abadhwar/Scores_T77_P21_P22_test';
%opt_scores.folder_out = '/gs/project/gsf-624-aa/abadhwar/Scores_T77_gunzipped';
opt_scores.folder_out = '/gs/project/gsf-624-aa/abadhwar/Scores_Cam7';

% psom option
opt_scores.psom.max_queued = 50;


% call pipeline
[pipeline,opt_scores] = niak_pipeline_scores(files_in,opt_scores);
