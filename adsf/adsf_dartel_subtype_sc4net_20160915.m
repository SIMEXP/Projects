%% script to subtype on adni dartel across networks at scale 4

clear all

%% set up paths
path_data = '/home/atam/scratch/adni_dartel/raw_mnc';
path_mask = '/home/atam/scratch/adni_dartel/basc_masks_mnc/';
files_in.model = '/home/atam/scratch/adni_dartel/model/adni_dartel_model_sc4_20160914.csv';

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

%% set up files_in structure
for ind = 2:size(pheno,1)
    sub_name = [pheno{ind, go_ind}];
    % Get the file name and path
    file_name = sprintf('smwc1ADNI_%s_MR_MPRAGE.mnc.gz', sub_name);
    file_path = [path_data filesep file_name];
    files_in.data.(sub_name) = file_path;
end

for nn = 1:4
    path_out = strcat('/home/atam/scratch/adni_dartel/dartel_sc4_net', num2str(nn), '_subtypes_20160915/');

    files_in.mask = strcat(path_mask, 'adni_dartel_basc_sc4_net', num2str(nn), '.mnc.gz');

    %% options

    opt.folder_out = path_out;
    opt.scale = 1;
    opt.stack.regress_conf = {'age','sex','tiv','mean_gm_wb', strcat('sc4_net', num2str(nn), '_gm')};
    opt.subtype.nb_subtype = 4;
    opt.flag_assoc = true;
    opt.association.contrast.diagnosis = 1;
    opt.flag_chi2 = true;
    opt.chi2.group_col_id = 'diagnosis';
    opt.flag_visu = true;
    opt.visu.data_type = 'categorical';

    %% run pipeline
    [pipe,opt] = niak_pipeline_subtype(files_in,opt);
end