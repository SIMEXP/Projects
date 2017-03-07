% script to subtype gmd dartel images in adni2 (yasser)

clear all

path_data = '/gs/project/gsf-624-aa/data/adni2_t1/dartel_gmd_yasser/';
path_model = '/gs/project/gsf-624-aa/data/adni2_t1/models/yasser_subjects.csv';
path_mask = '/gs/project/gsf-624-aa/data/adni2/dartel_20170105/mask_GM.nii'; 

path_results = '/home/atam/scratch/dartel_subtypes/adni2_dartel/';  

%% set up files_in structure

files_in.mask = path_mask;  
files_in.model = path_model;

folds = dir(path_data);
folds = {folds.name};
folds = folds(~ismember(folds,{'.','..'}));

% grab oldest mwrc1rl_T1 from each subject's folder

for ss = 1:length(folds)
    % From folder name, grab subject ID
    sub_fold = folds{ss};
    tmp = strsplit(folds{ss},'_');
    % Store RID of subject
    rid = tmp{3};
    % Set up subject id for fieldname
    sub_name = strcat('subject',rid);
    % Identify the correct files
    subj_files = dir([path_data sub_fold filesep 'mwrc1rl*']);
    subj_files = {subj_files.name};
    subj_files = subj_files(~ismember(subj_files,{'.','..'}));
    % If mwrc1rl exists, take the first session
    if ~isempty(subj_files)
        session = subj_files{1};
        files_in.data.(sub_name) = [path_data sub_fold filesep session];
    end
end

opt = struct;
files_out = strcat(path_results,'raw_gmd_stack_adni_bl.mat');
niak_brick_network_stack(files_in,files_out,opt);






