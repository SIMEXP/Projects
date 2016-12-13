clear

% Hard-coded variable
path_data = '/home/pbellec/data/simons_vip/tiv';
file_mask_brain = [path_data filesep 'anat_s14702xx3xFCAP1_mask_stereonl.nii.gz'];
file_mask_native = [path_data filesep 'mask_grey_cortex_native.nii.gz'];

%% Concatenate the native2stereolin and stereolin2stereonlin transformation
in{1} = [path_data filesep 'transf_s14702xx3xFCAP1_nativet1_to_stereolin.xfm'];
in{2} = [path_data filesep 'transf_s14702xx3xFCAP1_stereolin_to_stereonl.xfm'];
out   = [path_data filesep 'transf_s14702xx3xFCAP1_nativet1_to_stereonl.xfm'];
niak_brick_concat_transf(in,out);

%% Resample the mask in the native space
clear in out opt
in.source = file_mask_brain;
in.target = [path_data filesep 'anat_s14702xx3xFCAP1_nuc_nativet1.nii.gz'];
in.transformation = [path_data filesep 'transf_s14702xx3xFCAP1_nativet1_to_stereonl.xfm'];
out = file_mask_native;
opt.flag_invert_transf = true;
opt.interpolation = 'nearest_neighbour';
opt.voxel_size = [1 1 1];
niak_brick_resample_vol(in,out,opt);

%% Read the mask. Compute volume. 
[hdr_native,mask_native] = niak_read_vol(file_mask_native);
v = sum(mask_native(:))*prod(hdr_native.info.voxel_size)