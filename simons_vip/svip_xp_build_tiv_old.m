clear

% Hard-coded variable
niak_gb_vars
path_data = '/home/pbellec/data/simons_vip/tiv';
file_mask_brain = [path_data filesep 'anat_s14702xx3xFCAP1_mask_stereonl.nii.gz'];
file_aal_stereo = [path_data filesep 'mask_aal_stereo.nii.gz'];
file_aal_label = [gb_niak_path_niak filesep 'template' filesep 'labels_aal.mat'];

% The AAL template
clear in out opt
file_aal = [gb_niak_path_niak filesep 'template' filesep 'roi_aal.mnc.gz'];
in.source = file_aal;
in.target = file_mask_brain;
out = file_aal_stereo;
opt.interpolation = 'nearest_neighbour';
niak_brick_resample_vol(in,out,opt);
[hdr,mask_aal] = niak_read_vol(file_aal_stereo);
labels = load(file_aal_label);

% Build a mask of the cortical grey matter
[hdr_stereo,mask_brain] = niak_read_vol(file_mask_brain);

%mask_label_grey = ~niak_find_str_cell(labels.labels_aal,{'Cerebelum','Vermis','Caudate','Putamen','Pallidum','Thalamus'});
%mask_grey = ismember(mask_aal,labels.rois_aal(mask_label_grey));
mask_label_cerebelum = niak_find_str_cell(labels.labels_aal,{'Cerebelum','Vermis'});
mask_cerebelum = ismember(mask_aal,labels.rois_aal(mask_label_cerebelum));
mask_grey = mask_brain & ~mask_cerebelum;

hdr.file_name = [path_data filesep 'mask_grey_cortex.nii.gz'];
niak_write_vol(hdr,mask_grey);

%% Concatenate the native2stereolin and stereolin2stereonlin transformation
in{1} = [path_data filesep 'transf_s14702xx3xFCAP1_nativet1_to_stereolin.xfm'];
in{2} = [path_data filesep 'transf_s14702xx3xFCAP1_stereolin_to_stereonl.xfm'];
out   = [path_data filesep 'transf_s14702xx3xFCAP1_nativet1_to_stereonl.xfm'];
niak_brick_concat_transf(in,out);

%% Resample the mask in the native space
clear in out opt
in.source = [path_data filesep 'mask_grey_cortex.nii.gz'];
in.target = [path_data filesep 'anat_s14702xx3xFCAP1_nuc_nativet1.nii.gz'];
in.transformation = [path_data filesep 'transf_s14702xx3xFCAP1_nativet1_to_stereonl.xfm'];
out = [path_data filesep 'mask_grey_cortex_native.nii.gz'];
opt.flag_invert_transf = true;
opt.interpolation = 'nearest_neighbour';
opt.voxel_size = [1 1 1];
niak_brick_resample_vol(in,out,opt);
