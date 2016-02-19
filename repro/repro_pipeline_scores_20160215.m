
clear all
addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-issue100/'))

path_fmri = '/gs/project/gsf-624-aa/data/hnu1/preproc_20160215/fmri/';
path_folder_out = '/gs/project/gsf-624-aa/database2/repro/results/repro_scores_20160215_s007_session1/';

files_in.part = '/gs/project/gsf-624-aa/database2/repro/templates/template_cambridge_basc_multiscale_sym_scale007.mnc.gz';
files_in.mask = '/gs/project/gsf-624-aa/database2/repro/templates/mask.mnc.gz';


%% model
model = '/gs/project/gsf-624-aa/data/hnu1/model/hnu1_model_20160215.csv';
[tab,sub_id,label_y,label_id] = niak_read_csv(model);


for n = 1:length(sub_id)
    files_in.data.(sub_id{n}).session1.run1 = [path_fmri 'fmri_' sub_id{n} '_session1_run1.mnc'];
end  

opt.folder_out = path_folder_out;
opt.psom.max_queued = 300;
opt.psom.qsub_options = '-A gsf-624-aa -q sw -l nodes=1:ppn=4,walltime=3:00:00';
% opt.scores.flag_target = true;
% opt.scores.flag_deal = true;
pipeline = niak_pipeline_scores(files_in, opt);
