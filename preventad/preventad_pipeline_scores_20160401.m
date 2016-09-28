
clear all
addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-boss-0.13.4/'))

path_fmri = '/gs/project/gsf-624-aa/database2/preventad/rsn_preprocess_20150831/fmri/';
path_folder_out = '/gs/project/gsf-624-aa/database2/preventad/results/preventad_scores_20160401_s007_avg/';

files_in.part = '/gs/project/gsf-624-aa/database2/preventad/templates/template_cambridge_basc_multiscale_sym_scale007.mnc.gz';
files_in.mask = '/gs/project/gsf-624-aa/database2/preventad/templates/mask.mnc.gz';


%% model
model = '/gs/project/gsf-624-aa/database2/preventad/models/preventad_model_20160331.csv';
[tab,sub_id,label_y,label_id] = niak_read_csv(model);


for n = 1:length(sub_id)
    
    sub = sub_id{n};
    
    expression  = 'NAP';
    matchStr = regexp(sub,expression,'match');
    if ~isempty(matchStr)
        study = matchStr{1};
    else study = 'PRE';
    end
    
    name_file_1 = [sub '_' study 'BL00_rest1'];
    name_file_2 = [sub '_' study 'BL00_rest2'];
    
    [hdr1,vol1] = niak_read_vol([path_fmri 'fmri_' sub '_' study 'BL00_rest1.mnc.gz']);
    [hdr2,vol2] = niak_read_vol([path_fmri 'fmri_' sub '_' study 'BL00_rest2.mnc.gz']);
    
    v1=size(vol1,4);
    v2=size(vol2,4);
    vol_avg = vol1;
    vol_avg(:,:,:,v1+1:v1+v2) = vol2(:,:,:,:);
    
    hdr1.file_name = [path_fmri 'fmri_' sub '_' study 'BL00_avg.mnc.gz'];
    niak_write_vol(hdr1,vol_avg)
    
    files_in.data.(sub_id{n}).BL00.avg = hdr1.file_name;
end

opt.folder_out = path_folder_out;
opt.psom.max_queued = 300;
opt.psom.qsub_options = '-A gsf-624-aa -q sw -l walltime=3:00:00';
% opt.scores.flag_target = true;
% opt.scores.flag_deal = true;
pipeline = niak_pipeline_scores(files_in, opt);
