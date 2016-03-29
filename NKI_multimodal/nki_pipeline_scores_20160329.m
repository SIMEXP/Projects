% Run scores pipeline on NKI_fiftyplus

clear all
addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-issue100/'))

path_fmri = '/gs/project/gsf-624-aa/abadhwar/NKI_fiftyplus_preprocessed2_with_niakissue100/fmri_preprocess_all_scrubb05/fmri/';

path_folder_out = '/gs/project/gsf-624-aa/abadhwar/NKI_fiftyplus_scores_s007_20160329/';

files_in.part = '/gs/project/gsf-624-aa/database2/preventad/templates/template_cambridge_basc_multiscale_sym_scale007.mnc.gz';
files_in.mask = '/gs/project/gsf-624-aa/database2/preventad/templates/mask.mnc.gz';


%% model
model = '/gs/project/gsf-624-aa/abadhwar/nki_model_20160329.csv';
[tab,sub_id,~,~] = niak_read_csv(model);

for ss = 1:length(sub_id)
    
    files_in.data.(sub_id{ss}).session1.run1 = [path_fmri 'fmri_' sub_id{ss} '_sess1_rest645.mnc.gz'];
    files_in.data.(sub_id{ss}).session1.run2 = [path_fmri 'fmri_' sub_id{ss} '_sess1_rest1400.mnc.gz'];
    files_in.data.(sub_id{ss}).session1.run3 = [path_fmri 'fmri_' sub_id{ss} '_sess1_rest2500.mnc.gz'];
    
end

opt.folder_out = path_folder_out;
opt.psom.max_queued = 300;
opt.psom.qsub_options = '-A gsf-624-aa -q sw -l walltime=03:00:00';
pipeline = niak_pipeline_scores(files_in,opt);
