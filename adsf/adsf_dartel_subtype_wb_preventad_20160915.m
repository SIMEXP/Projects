%% extract adni dartel whole brain subtype weights on the prevent-ad sample

clear all

%% set up paths
path_data = '/gs/project/gsf-624-aa/database2/preventad/dartel_villeneuve_20160817_mnc/';
path_out = '/home/atam/scratch/dartel_subtypes/preventad_dartel/wb_subtypes_adniext_20160922/';

%% set up files_in structure

files_in.model = '/home/atam/scratch/dartel_subtypes/preventad_dartel/model/preventad_model_20160916.csv';
files_in.mask = '/home/atam/scratch/dartel_subtypes/adni_dartel/mask/mask_gm_dartel_adni.mnc.gz';
files_in.subtype.network_1 = '/home/atam/scratch/dartel_subtypes/adni_dartel/dartel_wb_subtypes_20160914/network_1/network_1_subtype.mat';

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
    
    expression  = 'NAP';
    matchStr = regexp(sub_name,expression,'match');
    if ~isempty(matchStr)
        study = matchStr{1};
    else study = 'PRE';
    end
    
    tmp_name = sub_name(2:7);
    file_name = ['smwc1PreventAD_' tmp_name '_' study 'BL00_adniT1001.mnc.gz'];
    file_path = [path_data filesep file_name];
    files_in.data.(sub_name) = file_path;
end

%% options

opt.folder_out = path_out;
opt.scale = 1;
opt.stack.regress_conf = {'age','gender','tiv','mean_gm_wb'};
opt.subtype.nb_subtype = 4;
opt.flag_assoc = true;
opt.association.contrast.delayed_memory_index_score = 1;
opt.flag_chi2 = false;
opt.flag_visu = true;
opt.visu.data_type = 'continuous';

%% run pipeline
[pipe,opt] = niak_pipeline_subtype(files_in,opt);