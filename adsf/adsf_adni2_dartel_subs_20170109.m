%% subtypes on adni2 dartel whole brain

clear all

%% set the paths
path_data = '/gs/project/gsf-624-aa/data/adni2/dartel_20170105/';
path_subj = [path_data 'smwc_subjects/'];
path_model = '/home/atam/scratch/dartel_subtypes/adni2_dartel/adni2_rs_model_20170111.csv';

path_results = '/home/atam/scratch/dartel_subtypes/adni2_dartel/adni2_vbm_subtypes_20170111';

%% set up files_in structure

files_in.mask = [path_data 'mask_GM.nii'];
files_in.model = path_model;

files = dir(path_subj);
files = {files.name};
n_files = length(files);

for ss = 3:n_files
    % Get the file name and path
    tmp = strsplit(files{ss},'_');
    sub_id = tmp{1}(6:9);
    run_name = tmp{2};
    sub_name = strcat('subject',sub_id);
    files_in.data.network_1.(sub_name) = [path_subj sprintf('smwc1%s_%s_1_1.nii',sub_id,run_name)];
end

%% options
opt.folder_out = path_results;
opt.scale = 1;
opt.stack.regress_conf = {'gender','age','mtladni2sites','TIV','mean_gm'};
opt.subtype.nb_subtype = 3;

% glms
% diagnosis
opt.association.diagnosis.contrast.diagnosis = 1;
opt.association.diagnosis.contrast.age = 0;
opt.association.diagnosis.contrast.gender = 0;
opt.association.diagnosis.contrast.TIV = 0;
opt.association.diagnosis.contrast.mean_gm = 0;
opt.association.diagnosis.contrast.mtladni2sites = 0;
opt.association.diagnosis.type_visu = 'categorical';

% patient group (CN vs ad/mci)
opt.association.pt_group.contrast.pt_group = 1;
opt.association.pt_group.contrast.age = 0;
opt.association.pt_group.contrast.gender = 0;
opt.association.pt_group.contrast.TIV = 0;
opt.association.pt_group.contrast.mean_gm = 0;
opt.association.pt_group.contrast.mtladni2sites = 0;
opt.association.pt_group.type_visu = 'categorical';

% adas11
opt.association.ADAS11.contrast.ADAS11 = 1;
opt.association.ADAS11.contrast.age = 0;
opt.association.ADAS11.contrast.gender = 0;
opt.association.ADAS11.contrast.TIV = 0;
opt.association.ADAS11.contrast.mean_gm = 0;
opt.association.ADAS11.contrast.mtladni2sites = 0;
opt.association.ADAS11.type_visu = 'continuous';

% adas11
opt.association.ADAS11_dx.contrast.ADAS11 = 1;
opt.association.ADAS11_dx.contrast.age = 0;
opt.association.ADAS11_dx.contrast.gender = 0;
opt.association.ADAS11_dx.contrast.TIV = 0;
opt.association.ADAS11_dx.contrast.mean_gm = 0;
opt.association.ADAS11_dx.contrast.mtladni2sites = 0;
opt.association.ADAS11_dx.contrast.diagnosis = 0;
opt.association.ADAS11_dx.type_visu = 'continuous';

% mmse
opt.association.MMSE.contrast.MMSE = 1;
opt.association.MMSE.contrast.age = 0;
opt.association.MMSE.contrast.gender = 0;
opt.association.MMSE.contrast.TIV = 0;
opt.association.MMSE.contrast.mean_gm = 0;
opt.association.MMSE.contrast.mtladni2sites = 0;
opt.association.MMSE.type_visu = 'continuous';

% mmse
opt.association.MMSE_dx.contrast.MMSE = 1;
opt.association.MMSE_dx.contrast.age = 0;
opt.association.MMSE_dx.contrast.gender = 0;
opt.association.MMSE_dx.contrast.TIV = 0;
opt.association.MMSE_dx.contrast.mean_gm = 0;
opt.association.MMSE_dx.contrast.mtladni2sites = 0;
opt.association.MMSE_dx.contrast.diagnosis = 0;
opt.association.MMSE_dx.type_visu = 'continuous';

opt.chi2 = 'pt_group';

%% run the pipeline

opt.flag_test = false;
[pipe,opt] = niak_pipeline_subtype(files_in,opt);






