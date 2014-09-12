clear;

i_path = '/data1/Abide/Stanford/';
o_path = '/data1/Abide/Out/Test/kmeans_gobbel/';
m_path = '/data1/Abide/Out/Test/';

% Make sure the paths are good paths
in_path = niak_full_path(i_path);
out_path = niak_full_path(o_path);
mask_path = niak_full_path(m_path);

% Make sure the base output directory exists
if ~psom_exist(out_path)
    psom_mkdir(out_path);
end

% Define the brain mask 
mask_name = 'mask.nii.gz';
mask_file = [mask_path mask_name];

% Define the search pattern for the functional file and for the subject ID
data_pattern = 'fmri_\d*_session_1_run1.nii';
sub_pattern = '\d*';

% Set up the main pipeline
main_pipe = struct;

files = dir(in_path)';
in.data = struct;
in.mask = mask_file;
opt.grid_scales = [2 4 6 8 10];
opt.folder_out = o_path;

for file = files
    match = regexp(file.name, data_pattern, 'match');
    if ~isempty(match)
        % We have a match - find the subject name
        sub_match = regexp(file.name, sub_pattern, 'match');
        s_name = ['sub_' sub_match{1}];
        s_file = [niak_full_path(in_path) file.name];
        in.data.(s_name).ss1.r1 = s_file;
    end
end
