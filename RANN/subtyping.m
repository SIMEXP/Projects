%% based on script to subtype on adni dartel: whole brain by Angela Tam (available on github: 
%%%https://github.com/SIMEXP/Projects/blob/master/adsf/adsf_dartel_subtype_wb_20160912.m)
%%%adapted to RANN database by Perrine Ferré in a PhD Project, under supervision of Pierre Bellec//SIMEXP.

clear all

%% set up paths
path_data = '/gs/project/gsf-624-aa/RANN/';
path_out = '/gs/project/gsf-624-aa/RANN/RANNbackup/SUBTYPE/';

%% set up files_in structure

files_in.model = '/gs/project/gsf-624-aa/RANN/Models/BEHAV_all_filters_ant_syn.csv';
???????? files_in.mask = '??????? /home/atam/scratch/adni_dartel/mask/mask_gm_dartel_adni.mnc.gz';

%% Configure the inputs for files_in.data
pheno = niak_read_csv_cell(files_in.model);

%%%%%???? fmri??? files_in.fmri = niak_grab_fmri_preprocess([path_data 'RANNbackup/FINAL_preprocess_test_issue100_16.03.03'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored.
%%%%% in case you grab the raw data instead of the niak preprocessed: %%%%
%% Go through the subjects and then make me some files_in struct
%go_by = '';
%% Find where that is
%for ind = 1:size(pheno,2)
%    if strcmp(pheno{1, ind}, go_by)
%        go_ind = ind;
%    end
%end
%
%for ind = 2:size(pheno,1)
%    sub_name = [pheno{ind, go_ind}];
%    % Get the file name and path
%    file_name = sprintf('smwc1ADNI_%s_MR_MPRAGE.mnc.gz', sub_name);
%    file_path = [path_data filesep file_name];
%    files_in.data.(sub_name) = file_path;
%end

%% options

opt.folder_out = path_out;
opt.scale = 1;
opt.stack.regress_conf = {'age','education',''genderMF','Syn_Perf', 'Ant_Perf','mean_gm'};
opt.subtype.nb_subtype = 4;
opt.flag_assoc = true;
opt.association.contrast.diagnosis = 1;
%%%%%% ?????? opt.flag_chi2 = true;
%%%%%% ?????? opt.chi2.group_col_id = 'diagnosis';
opt.flag_visu = true;
%%%%%% ?????? continuous ??? opt.visu.data_type = 'categorical';

%% run pipeline
[pipe,opt] = niak_pipeline_subtype(files_in,opt);
