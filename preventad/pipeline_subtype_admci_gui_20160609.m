clear;
addpath(genpath('/home/porban/gsf-624-aa/quarantaine/tmp_niak_subtype'));

%% Set up the paths
model_path = '/gs/project/gsf-624-aa/database2/preventad/models/admci_model_20160401.csv';
data_path = '/gs/project/gsf-624-aa/database2/preventad/results/admci_balanced2_scores_s007_20160222/rmap_part/';
mask_path = '/home/porban/gsf-624-aa/database2/preventad/mask/mask.mnc.gz';
out_path = '/gs/project/gsf-624-aa/database2/preventad/results/subtype_admci_s07_gui_20160609/';

%% Read model
[tab,sub_id,~,~] = niak_read_csv(model_path);


%% Files_in
for ss = 1:length(sub_id)    
    sub = sub_id{ss};
    files_in.data.(sub) = [data_path sub '_session1_run1_rmap_part.mnc.gz'];
end
files_in.model = model_path;
files_in.mask = mask_path;

%% Options
opt.flag_test = false;
opt.folder_out = out_path;
opt.scale = 7;
opt.stack.regress_conf = {'gender','age','fd','mnimci','criugmad','criugmmci','adni5'};
opt.subtype.nb_subtype = 3;
opt.subtype.sub_map_type = 'median'; 
opt.subtype.group_col_id = 12;
opt.association.contrast.admci = 1;
opt.psom.qsub_options = '-A gsf-624-aa -q sw -l walltime=01:00:00';

%% Start the pipeline
[pipe,opt] = niak_pipeline_subtype(files_in,opt);


