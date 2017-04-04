% script to extract gray matter volume whole brain

clear all

path_data = '/gs/project/gsf-624-aa/data/adni2_t1/dartel_gmd_yasser/';
path_model = '/gs/project/gsf-624-aa/data/adni2_t1/models/adni_yasser_subjects_qc.csv';
path_mask = '/gs/project/gsf-624-aa/data/adni2_t1/yasser_masks/template_6_gm.nii'; 

path_results = '/home/atam/scratch/dartel_subtypes/';  

%% set up files_in structure

files_in.mask = path_mask;  
files_in.model = path_model;

%% structure for subject data
folds = dir(path_data);
folds = {folds.name};
folds = folds(~ismember(folds,{'.','..'}));

%% read the mask
[hdr_mask,mask] = niak_read_vol(path_mask);
% make mask logical
mask = mask > 0; 

%% prep the csv
labels = cell(length(folds)+1,3);
labels{1,1} = 'subject';
labels{1,2} = 'PTID';
labels{1,3} = 'mean_gm';

csvname = [path_results 'adni_s_mean_gm_wholebrain.csv'];
fid = fopen(csvname,'w');
fprintf(fid, '%s, %s, %s\n', labels{1,:});

%% grab oldest smwrc1rl_T1 from each subject's folder

for ss = 1:length(folds)
    % From folder name, grab subject ID
    sub_fold = folds{ss};
    tmp = strsplit(folds{ss},'_');
    % Store RID of subject
    rid = tmp{3};
    % Set up subject id for fieldname
    sub_name = strcat('subject',rid);
    % Identify the correct files
    subj_files = dir([path_data sub_fold filesep 'smwrc1rl*']);
    subj_files = {subj_files.name};
    subj_files = subj_files(~ismember(subj_files,{'.','..'}));
    % If smwrc1rl exists, take the first session
    if ~isempty(subj_files)
        session = subj_files{1};
        smwrc_vol = [path_data sub_fold filesep session];
        % read the volume
        [hdr_vol,vol] = niak_read_vol(smwrc_vol);
        % calculate the gm average & print to csv
        labels{ss+1,1} = sub_name;
        labels{ss+1,2} = sub_fold;
        labels{ss+1,3} = mean(vol(mask));
        fprintf(fid, '%s, %s, %f\n', labels{ss+1,1}, labels{ss+1,2}, labels{ss+1,3});
    else
        % if does not exist
        labels{ss+1,1} = sub_name;
        labels{ss+1,2} = sub_fold;
        labels{ss+1,3} = 'NaN';
        fprintf(fid, '%s, %s, %s\n', labels{ss+1,1}, labels{ss+1,2}, labels{ss+1,3});
    end
end

fclose(fid)



