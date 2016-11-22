%% script to subtype the "rest" of adni2 resting-state

clear all

%% set up paths
path_data = '/gs/project/gsf-624-aa/database2/preventad/results/adni_scores_s007_20160121/rmap_part/';
path_sub = '/gs/project/gsf-624-aa/database2/preventad/results/subtype_admci_s07_gui_20160705/';
path_out = '/home/atam/scratch/rs_subtypes/adni_missing_20161117/';

%% set up files_in structure
 
files_in.model = '/home/atam/scratch/rs_subtypes/model_rs_adni_to_subtype.csv';
files_in.mask = '/gs/project/gsf-624-aa/database2/preventad/mask_mnc/mask.mnc';
files_in.subtype.network_1 = [path_sub 'network_1/network_1_subtype.mat'];
files_in.subtype.network_2 = [path_sub 'network_2/network_2_subtype.mat'];
files_in.subtype.network_3 = [path_sub 'network_3/network_3_subtype.mat'];
files_in.subtype.network_4 = [path_sub 'network_4/network_4_subtype.mat'];
files_in.subtype.network_5 = [path_sub 'network_5/network_5_subtype.mat'];
files_in.subtype.network_6 = [path_sub 'network_6/network_6_subtype.mat'];
files_in.subtype.network_7 = [path_sub 'network_7/network_7_subtype.mat'];

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
%for ind = 2:size(pheno,1)
 %   sub_name = [pheno{ind, go_ind}];
    % Get the file name and path
  %  file_name = sprintf('smwc1ADNI_%s_MR_MPRAGE.mnc.gz', sub_name);
   % file_path = [path_data filesep file_name];
    %files_in.data.(sub_name) = file_path;
%end

files = dir(path_data);
files = {files.name};

n_files = length(files);


%% set up files_in structure
for ind = 2:size(pheno,1)
    for ss = 3:length(files)
        sub_name = [pheno{ind, go_ind}];
        % Get the file name and path
        tmp = strsplit(files{ss},'_');
        expression = tmp{2};
        sub_date = tmp{4};
        matchstr = regexp(sub_name, expression, 'match');
            if ~isempty(matchstr)
            files_in.data.(sub_name) = [path_data filesep sprintf('fmri_%s_session1_%s_rmap_part.mnc.gz', sub_name, sub_date)];
        end
    end
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