% script to subtype gmd dartel images in adni2 (yasser)

clear all

path_data = '/gs/project/gsf-624-aa/data/adni2_t1/dartel_gmd_yasser/';
path_model = '/gs/project/gsf-624-aa/data/adni2_t1/models/yasser_subjects_dartel.csv';
path_mask = '/gs/project/gsf-624-aa/data/adni2_t1/yasser_masks/template_6_gm.nii'; 

path_results = '/home/atam/scratch/dartel_subtypes/adnit1_dartel_20170315/';  

%% set up files_in structure

files_in.mask = path_mask;  
files_in.model = path_model;

%% filter out those with failed QC in model
[conf_model,list_subject,cat_names] = niak_read_csv(files_in.model);
qc_col = find(strcmp('dartel_qc',cat_names));
mask_qc = logical(conf_model(:,qc_col));
conf_model = conf_model(mask_qc,:);
list_subject = list_subject(mask_qc);

%% grab oldest mwrc1rl_T1 from each subject's folder

folds = dir(path_data);
folds = {folds.name};
folds = folds(~ismember(folds,{'.','..'}));

for ss = 1:length(folds)
    % From folder name, grab subject ID
    sub_fold = folds{ss};
    tmp = strsplit(folds{ss},'_');
    % Store RID of subject
    rid = tmp{3};
    % Set up subject id for fieldname
    sub_name = strcat('subject',rid);
    
    % Only grab the file if subject passed QC
    if any(ismember(list_subject,sub_name))
        % Identify the correct files
        subj_files = dir([path_data sub_fold filesep 'mwrc1rl*']);
        subj_files = {subj_files.name};
        subj_files = subj_files(~ismember(subj_files,{'.','..'}));
        % If mwrc1rl exists, take the first session
        if ~isempty(subj_files)
            session = subj_files{1};
            files_in.data.network_1.(sub_name) = [path_data sub_fold filesep session];
        end
    end    
end

%% options
opt.folder_out = path_results;
opt.scale = 1;
opt.stack.regress_conf = {'sex','age_bl','mean_gmd_wb','site'};

opt.subtype.nb_subtype = 3;

% glms
% diagnosis
opt.association.diagnosis.contrast.diagnosis = 1;
opt.association.diagnosis.contrast.age = 0;
opt.association.diagnosis.contrast.gender = 0;
%opt.association.diagnosis.contrast.TIV = 0;
opt.association.diagnosis.contrast.mean_gmd_wb = 0;
opt.association.diagnosis.contrast.site = 0;
opt.association.diagnosis.type_visu = 'categorical';

%% run the pipeline
opt.flag_test = false;
[pipe,opt] = niak_pipeline_subtype(files_in,opt);





