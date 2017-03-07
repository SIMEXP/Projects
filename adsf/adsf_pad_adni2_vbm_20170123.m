%% extract adni dartel whole brain subtype weights on the prevent-ad sample

clear all

%% set up paths
path_data = '/gs/project/gsf-624-aa/database2/preventad/dartel_villeneuve_20160817_mnc/';
path_out = '/home/atam/scratch/dartel_subtypes/preventad_dartel/wb_subtypes_adni2ext_20170123/';

%% set up files_in structure

files_in.model = '/home/atam/scratch/dartel_subtypes/preventad_dartel/preventad_model.csv';
files_in.mask = '/home/atam/scratch/dartel_subtypes/adni_dartel/mask/mask_gm_dartel_adni.mnc.gz';
files_in.subtype.network_1 = '/home/atam/scratch/dartel_subtypes/adni2_dartel/adni2_vbm_subtypes_20170123/networks/network_1/subtype_network_1.mat';

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
    files_in.data.network_1.(sub_name) = file_path;
end

%% options

opt.folder_out = path_out;
opt.scale = 1;
opt.stack.regress_conf = {'age','gender','TIV','mean_gm_wb'};
opt.subtype.nb_subtype = 3;

%% glms
% immediate memory
opt.association.immediate_memory_index_score.contrast.immediate_memory_index_score = 1;
opt.association.immediate_memory_index_score.contrast.age = 0;
opt.association.immediate_memory_index_score.contrast.gender = 0;
opt.association.immediate_memory_index_score.contrast.TIV = 0;
opt.association.immediate_memory_index_score.contrast.mean_gm_wb = 0;
opt.association.immediate_memory_index_score.flag_visu = true;
opt.association.immediate_memory_index_score.type_visu = 'continuous';

% visuospatial
opt.association.visuospatial_constructional_index_score.contrast.visuospatial_constructional_index_score = 1;
opt.association.visuospatial_constructional_index_score.contrast.age = 0;
opt.association.visuospatial_constructional_index_score.contrast.gender = 0;
opt.association.visuospatial_constructional_index_score.contrast.TIV = 0;
opt.association.visuospatial_constructional_index_score.contrast.mean_gm_wb = 0;
opt.association.visuospatial_constructional_index_score.flag_visu = true;
opt.association.visuospatial_constructional_index_score.type_visu = 'continuous';

% language
opt.association.language_index_score.contrast.language_index_score = 1;
opt.association.language_index_score.contrast.age = 0;
opt.association.language_index_score.contrast.gender = 0;
opt.association.language_index_score.contrast.TIV = 0;
opt.association.language_index_score.contrast.mean_gm_wb = 0;
opt.association.language_index_score.flag_visu = true;
opt.association.language_index_score.type_visu = 'continuous';

% attention
opt.association.attention_index_score.contrast.attention_index_score = 1;
opt.association.attention_index_score.contrast.age = 0;
opt.association.attention_index_score.contrast.gender = 0;
opt.association.attention_index_score.contrast.TIV = 0;
opt.association.attention_index_score.contrast.mean_gm_wb = 0;
opt.association.attention_index_score.flag_visu = true;
opt.association.attention_index_score.type_visu = 'continuous';

% delayed memory
opt.association.delayed_memory_index_score.contrast.delayed_memory_index_score = 1;
opt.association.delayed_memory_index_score.contrast.age = 0;
opt.association.delayed_memory_index_score.contrast.gender = 0;
opt.association.delayed_memory_index_score.contrast.TIV = 0;
opt.association.delayed_memory_index_score.contrast.mean_gm_wb = 0;
opt.association.delayed_memory_index_score.flag_visu = true;
opt.association.delayed_memory_index_score.type_visu = 'continuous';

% amyloid
opt.association.Beta.contrast.Beta = 1;
opt.association.Beta.contrast.age = 0;
opt.association.Beta.contrast.gender = 0;
opt.association.Beta.contrast.TIV = 0;
opt.association.Beta.contrast.mean_gm_wb = 0;
opt.association.Beta.flag_visu = true;
opt.association.Beta.type_visu = 'continuous';

% tau
opt.association.Tau.contrast.Tau = 1;
opt.association.Tau.contrast.age = 0;
opt.association.Tau.contrast.gender = 0;
opt.association.Tau.contrast.TIV = 0;
opt.association.Tau.contrast.mean_gm_wb = 0;
opt.association.Tau.flag_visu = true;
opt.association.Tau.type_visu = 'continuous';

% ptau
opt.association.pTau.contrast.pTau = 1;
opt.association.pTau.contrast.age = 0;
opt.association.pTau.contrast.gender = 0;
opt.association.pTau.contrast.TIV = 0;
opt.association.pTau.contrast.mean_gm_wb = 0;
opt.association.pTau.flag_visu = true;
opt.association.pTau.type_visu = 'continuous';

% ptau_beta_ratio
opt.association.ptau_beta_ratio.contrast.ptau_beta_ratio = 1;
opt.association.ptau_beta_ratio.contrast.age = 0;
opt.association.ptau_beta_ratio.contrast.gender = 0;
opt.association.ptau_beta_ratio.contrast.TIV = 0;
opt.association.ptau_beta_ratio.contrast.mean_gm_wb = 0;
opt.association.ptau_beta_ratio.flag_visu = true;
opt.association.ptau_beta_ratio.type_visu = 'continuous';

% apoe
opt.association.apoe4.contrast.apoe4 = 1;
opt.association.apoe4.contrast.age = 0;
opt.association.apoe4.contrast.gender = 0;
opt.association.apoe4.contrast.TIV = 0;
opt.association.apoe4.contrast.mean_gm_wb = 0;
opt.association.apoe4.flag_visu = true;
opt.association.apoe4.type_visu = 'categorical';

% bdnf
opt.association.bdnf.contrast.bdnf = 1;
opt.association.bdnf.contrast.age = 0;
opt.association.bdnf.contrast.gender = 0;
opt.association.bdnf.contrast.TIV = 0;
opt.association.bdnf.contrast.mean_gm_wb = 0;
opt.association.bdnf.flag_visu = true;
opt.association.bdnf.type_visu = 'categorical';

%% run pipeline
[pipe,opt] = niak_pipeline_subtype(files_in,opt);