clear;

i_path = '/';
o_path = '/';
m_path = '/';
p_path = '/';

% Make sure the paths are good paths
in_path = niak_full_path(i_path);
out_path = niak_full_path(o_path);
mask_path = niak_full_path(m_path);
part_path = niak_full_path(p_path);

% Make sure the base output directory exists
if ~psom_exist(out_path)
    psom_mkdir(out_path);
end

% Define the brain mask 
mask_name = 'mask_resample.nii.gz';
mask_file = [mask_path mask_name];

% Define the partition
part_name = 'part_res.mat';
part_file = [part_path part_name];

% Define the search pattern for the functional file and for the subject ID
data_pattern = 'fmri_\d*_session_1_run1.nii.gz';
sub_pattern = '\d*';

% Set up the main pipeline
main_pipe = struct;

f = struct;
files = dir(in_path)';
count = 1;
for file = files
    match = regexp(file.name, data_pattern, 'match');
    if ~isempty(match)
        % We have a match - find the subject name
        sub_match = regexp(file.name, sub_pattern, 'match');
        s_name = sub_match{1};
        s_file = [niak_full_path(in_path) file.name];
        sub_name = sprintf('sub_%s', s_name);
        f.(sub_name).ss1.r1 = s_file;
        count = count + 1;
    
    elseif file.isdir
        % It's a directory. Go inside
        dir_path = [in_path file.name];
        sub_files = dir(dir_path)';
        for sub_file = sub_files
            sub_match = regexp(sub_file.name, data_pattern, 'match');
             if ~isempty(sub_match)
                 sub_sub_match = regexp(sub_file.name, sub_pattern, 'match');
                 s_name = sub_sub_match{1};
                 s_file = [niak_full_path(dir_path) sub_file.name];
                 sub_name = sprintf('sub_%s', s_name);
                 f.(sub_name).ss1.r1 = s_file;
                 count = count + 1;
             end
        end
    end
end

files_in.data = f;
files_in.mask = mask_file;
files_in.part = part_file;
opt.folder_out = o_path;
opt.scale_grid = [10 50 100 200 500];
opt.target_type = 'manual';
opt.stability_atom.clustering.type = 'kcores';
opt.stability_vertex.clustering.type = 'kcores';
opt.cores.type = 'kmeans';
% opt.consensus.scale_target = [10 50 100];
opt.stability_atom.nb_batch = 2;
opt.stability_vertex.nb_batch = 2;
opt.psom.max_queued = 1;
% Other options
opt.flag_cores = true;

fprintf('Starting pipeline!\n');
niak_pipeline_stability_voxel(files_in, opt);
