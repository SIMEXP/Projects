i_path = '/data1/abide/Stanford/';
o_path = '/data1/abide/Out/Test2/';
m_path = '/data1/abide/Mask/';

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
data_name = 'fmri_0051162_session_1_run1.nii.gz';
data_file = [in_path data_name];

f.sub1.session1.run1 = data_file;
files_in.data = f;
files_in.mask = mask_file;
opt.folder_out = o_path;
opt.scale = 2:2:20;
opt.stability_atom.nb_batch = 10;
opt.stability_vertex.nb_batch = 10;
opt.flag_test = false;
opt.psom.max_queued = 8;
fprintf('Starting pipeline!\n');
niak_pipeline_stability_voxel(files_in, opt);
