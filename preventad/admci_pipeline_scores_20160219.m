%% Run scores pipeline on admci data
%% Includes samples adni2 and ad_mtl (adpd, belleville,criugm_mci, mni_mci)
%% The model file is cleaned of subjects with missing data for either dx, age, sex, fd or scanner/site
%% Here we only run the pipeline for subjects with at least 70 frames_OK.


clear all
addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-boss-0.13.4/'))

path_data = '/gs/project/gsf-624-aa/data/';
path_folder_out = '/gs/project/gsf-624-aa/database2/preventad/results/admci_scores_s007_20160219/';

files_in.part = '/gs/project/gsf-624-aa/database2/preventad/templates/template_cambridge_basc_multiscale_sym_scale007.mnc.gz';
files_in.mask = '/gs/project/gsf-624-aa/database2/preventad/templates/mask.mnc.gz';


%% model
model = '/gs/project/gsf-624-aa/database2/preventad/models/admci_model_subtype_20160219.csv';
[tab,sub_id,~,~] = niak_read_csv(model);

sample_tag = {'subject','AD0','ad_dat','ad_hc','SB_30','ad_00','ad_10'}; % {'adni2','adpd','belleville','belleville','criugm_mci','mni_mci','mni_mci'}

for ss = 1:length(sub_id)
    
    sub = sub_id{ss};
    
    if tab(ss,4) >69 % keep only subjects with at least 70 vols (frames_OK)
        
        for tt = 1:length(sample_tag)
            
            tag = sample_tag{tt};
            match = findstr(tag,sub);
            
            if ~isempty(match)
                
                if tt == 1
                    path_fmri = [path_data 'adni2/fmri_preprocess/fmri/'];
                    file_list = dir(path_fmri);
                    expression = [sub_id{ss} '_session1_r1d[0-9]*'];
                    for ff = 3:size(file_list,1)
                        file_name = file_list(ff).name;
                        matchstr = regexp(file_name,expression,'match');
                        if ~isempty(matchstr)
                            file_tag = matchstr{1};
                        end
                    end
                    files_in.data.(sub_id{ss}).session1.run1 = [path_fmri 'fmri_' file_tag '.mnc.gz'];
                    
                elseif tt == 2
                    files_in.data.(sub_id{ss}).session1.run1 = [path_data 'ad_mtl/adpd/fmri_preprocess/fmri/fmri_' sub_id{ss} '_session1_rest1.mnc.gz'];
                    
                elseif tt == 3 | tt == 4
                    files_in.data.(sub_id{ss}).session1.run1 = [path_data 'ad_mtl/belleville/fmri_preprocess/fmri/fmri_' sub_id{ss} '_session1_rest.mnc.gz'];
                    
                elseif tt == 5
                    files_in.data.(sub_id{ss}).session1.run1 = [path_data 'ad_mtl/criugm_mci/fmri_preprocess/fmri/fmri_' sub_id{ss} '_session1_rest.mnc.gz'];
                    
                elseif tt == 6 | tt == 7
                    files_in.data.(sub_id{ss}).session1.run1 = [path_data 'ad_mtl/mni_mci/fmri_preprocess/fmri/fmri_' sub_id{ss} '_session1_run1.mnc.gz'];
                end
            end
        end
    else
    end
end

opt.folder_out = path_folder_out;
opt.psom.max_queued = 300;
opt.psom.qsub_options = '-A gsf-624-aa -q sw -l walltime=03:00:00';
% opt.scores.flag_target = true;
% opt.scores.flag_deal = true;
pipeline = niak_pipeline_scores(files_in,opt);
