%% script to subtype on adni dartel: whole brain
% regress out age, sex, gender, tiv, mean_gm (whole brain) and site

clear all

%% set up paths
path_data = '/home/atam/scratch/dartel_subtypes/adni_dartel/raw_mnc/';
path_out = '/home/atam/scratch/dartel_subtypes/adni_dartel/dartel_wb_subtypes_20161006/';

%% set up files_in structure

files_in.model = '/home/atam/scratch/dartel_subtypes/adni_dartel/model/adni_dartel_model_20161006.csv';
files_in.mask = '/home/atam/scratch/dartel_subtypes/adni_dartel/mask/mask_gm_dartel_adni.mnc.gz';

%% Configure the inputs for files_in.data
pheno = niak_read_csv_cell(files_in.model);

% Go through the subjects and then make me some files_in struct
go_by = '';
% Find where that is
for ind = 1:size(pheno,2)
    if strcmp(pheno{1, ind}, go_by)
        go_ind = ind;
    end
end

for ind = 2:size(pheno,1)
    sub_name = [pheno{ind, go_ind}];
    % Get the file name and path
    file_name = sprintf('smwc1ADNI_%s_MR_MPRAGE.mnc.gz', sub_name);
    file_path = [path_data filesep file_name];
    files_in.data.(sub_name) = file_path;
end

%% options

opt.folder_out = path_out;
opt.scale = 1;
opt.stack.regress_conf = {'age','sex','tiv','mean_gm','site'};
opt.subtype.nb_subtype = 4;
opt.flag_assoc = true;
opt.association.contrast.diagnosis = 1;
opt.association.contrast.age = 0;
opt.association.contrast.sex = 0;
opt.association.contrast.tiv = 0;
opt.association.contrast.mean_gm = 0;
opt.association.contrast.site = 0;
opt.flag_chi2 = true;
opt.chi2.group_col_id = 'diagnosis';
opt.flag_visu = true;
opt.visu.data_type = 'categorical';

%% run pipeline
[pipe,opt] = niak_pipeline_subtype(files_in,opt);