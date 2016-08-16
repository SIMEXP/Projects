%% script to generate resting-state subtypes on prevent-ad scores

clear all

%% set up paths
path_data = '/home/atam/scratch/preventad_data/';
path_out = '/home/atam/scratch/adsf/rsfmri_subtypes_20160816/';
path_scores = '/home/atam/scratch/preventad_data/scores_20160401_s007_avg/rmap_part/';

%% set up files_in structure

files_in.model = [path_data 'model_preventad_20160813.csv'];
files_in.mask = [path_data 'scores_20160401_s007_avg/mask.mnc.gz'];

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
    file_name = sprintf('%s_BL00_avg_rmap_part.mnc.gz', sub_name);
    file_path = [path_scores filesep file_name];
    files_in.data.(sub_name) = file_path;
end

%% options

opt.folder_out = path_out;
opt.scale = 7;
opt.stack.regress_conf = {'age','gender'};
opt.subtype.nb_subtype = 4;
opt.association.contrast.mean_ct_whole_brain = 1;
opt.visu.data_type = 'continuous';

%% run pipeline
[pipe,opt] = niak_pipeline_subtype(files_in,opt);


