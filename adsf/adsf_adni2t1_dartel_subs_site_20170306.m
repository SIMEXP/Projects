% script to subtype gmd dartel images in adni (yasser)

clear all

path_data = '/gs/project/gsf-624-aa/data/adni2_t1/dartel_gmd_yasser/';
path_model = '/gs/project/gsf-624-aa/data/adni2_t1/models/yasser_subjects_dartel.csv';
path_mask = '/gs/project/gsf-624-aa/data/adni2_t1/yasser_masks/template_6_gm.nii'; 

path_results = '/home/atam/scratch/dartel_subtypes/adnit1_dartel_20170315_s/';  

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
opt.stack.regress_conf = {'sex','age_bl','mean_gmd_wb',...
                          'site2','site6','site7','site9','site10',...
                          'site11','site12','site13','site14','site18',...
                          'site19','site20','site22','site23','site24',...
                          'site27','site31','site32','site33','site36',...
                          'site37','site41','site53','site67','site70',...
                          'site73','site94','site98','site100','site109',...
                          'site116','site123','site127','site128','site129',...
                          'site130','site131','site135','site136','site137',...
                          'site141','site153','site941'};
opt.subtype.nb_subtype = 3;

% glms
% diagnosis
opt.association.diagnosis.contrast.dx_bl_3 = 1;
opt.association.diagnosis.contrast.age_bl = 0;
opt.association.diagnosis.contrast.sex = 0;
%opt.association.diagnosis.contrast.TIV = 0;
opt.association.diagnosis.contrast.mean_gmd_wb = 0;
opt.association.diagnosis.contrast.site2 = 0;
opt.association.diagnosis.contrast.site6 = 0;
opt.association.diagnosis.contrast.site7 = 0;
opt.association.diagnosis.contrast.site9 = 0;
opt.association.diagnosis.contrast.site10 = 0;
opt.association.diagnosis.contrast.site11 = 0;
opt.association.diagnosis.contrast.site12 = 0;
opt.association.diagnosis.contrast.site13 = 0;
opt.association.diagnosis.contrast.site14 = 0;
opt.association.diagnosis.contrast.site18 = 0;
opt.association.diagnosis.contrast.site19 = 0;
opt.association.diagnosis.contrast.site20 = 0;
opt.association.diagnosis.contrast.site22 = 0;
opt.association.diagnosis.contrast.site23 = 0;
opt.association.diagnosis.contrast.site24 = 0;
opt.association.diagnosis.contrast.site27 = 0;
opt.association.diagnosis.contrast.site31 = 0;
opt.association.diagnosis.contrast.site32 = 0;
opt.association.diagnosis.contrast.site33 = 0;
opt.association.diagnosis.contrast.site36 = 0;
opt.association.diagnosis.contrast.site37 = 0;
opt.association.diagnosis.contrast.site41 = 0;
opt.association.diagnosis.contrast.site53 = 0;
opt.association.diagnosis.contrast.site67 = 0;
opt.association.diagnosis.contrast.site70 = 0;
opt.association.diagnosis.contrast.site73 = 0;
opt.association.diagnosis.contrast.site94 = 0;
opt.association.diagnosis.contrast.site98 = 0;
opt.association.diagnosis.contrast.site100 = 0;
opt.association.diagnosis.contrast.site109 = 0;
opt.association.diagnosis.contrast.site116 = 0;
opt.association.diagnosis.contrast.site123 = 0;
opt.association.diagnosis.contrast.site127 = 0;
opt.association.diagnosis.contrast.site128 = 0;
opt.association.diagnosis.contrast.site129 = 0;
opt.association.diagnosis.contrast.site130 = 0;
opt.association.diagnosis.contrast.site131 = 0;
opt.association.diagnosis.contrast.site135 = 0;
opt.association.diagnosis.contrast.site136 = 0;
opt.association.diagnosis.contrast.site137 = 0;
opt.association.diagnosis.contrast.site141 = 0;
opt.association.diagnosis.contrast.site153 = 0;
opt.association.diagnosis.contrast.site941 = 0;
opt.association.diagnosis.type_visu = 'categorical';

%% run the pipeline
opt.flag_test = false;
[pipe,opt] = niak_pipeline_subtype(files_in,opt);





