%% script to subtype the "rest" of adni2 resting-state

clear all

%% set up paths
path_data = '/home/atam/scratch/rs_subtypes/adni2/rmap_seeds/rmap_stacks/';
path_sub = '/gs/project/gsf-624-aa/database2/preventad/results/subtype_admci_s07_gui_20160705/';
path_out = '/home/atam/scratch/rs_subtypes/adni2_subtype_20161123/';

%% set up files_in structure
 
files_in.model = '/home/atam/scratch/rs_subtypes/adni2_model_multi_site_scanner_fd_snr_20161123.csv';
files_in.mask = '/gs/project/gsf-624-aa/database2/preventad/mask_mnc/mask.mnc';
files_in.subtype.network_1 = [path_sub 'network_1/network_1_subtype.mat'];
files_in.subtype.network_2 = [path_sub 'network_2/network_2_subtype.mat'];
files_in.subtype.network_3 = [path_sub 'network_3/network_3_subtype.mat'];
files_in.subtype.network_4 = [path_sub 'network_4/network_4_subtype.mat'];
files_in.subtype.network_5 = [path_sub 'network_5/network_5_subtype.mat'];
files_in.subtype.network_6 = [path_sub 'network_6/network_6_subtype.mat'];
files_in.subtype.network_7 = [path_sub 'network_7/network_7_subtype.mat'];



%% set up files_in structure

files = dir(path_data);
files = {files.name};
n_files = length(files);

for ss = 3:n_files
    % Get the file name and path
    tmp = strsplit(files{ss},'_');
    sub_name = strcat(tmp{1});
    files_in.data.(sub_name) = [path_data sprintf('%s_stack.mnc.gz', sub_name)];
end
     

%% options

opt.folder_out = path_out;
opt.scale = 7;
opt.stack.regress_conf = {'age','gender','fd'};
opt.subtype.nb_subtype = 3;
opt.flag_assoc = false;
opt.flag_chi2 = false;
opt.flag_visu = false;

%% run pipeline
[pipe,opt] = niak_pipeline_subtype(files_in,opt);