function stack = adsf_brick_3d_to_4d(path_in,path_out,path_model,ext_v)
% Create a single 4D map (stack) of multiple 3D maps
%
% Syntax: STACK = adsf_brick_3d_to_4d(PATH_IN,PATH_OUT,PATH_MODEL)
%
% INPUTS:
%
% PATH_IN full path to a folder containing the individual maps (e.g. rmap_part,
%    stability_maps, etc). NB: assumes there is only 1 .nii.gz map per individual.
%
% PATH_OUT full path to write stack output. NB: assumes the folder is non-existent 
% and should be created.
%
% PATH_MODEL full path + name of .csv model with list of labels_x that
%   correspond to subject names in functional maps. 
%
% EXT_V string, extension of the input volumes
%
% OUTPUTS:
%
% STACK_4D.nii.gz
%       a 4D volume containing maps of individual subjects
% STACK_MEAN.nii.gz
% STACK_STD.nii.gz
%
%
% (C) Angela Tam 2016


%% Brick starts here
% Read model
[~,id,~,~] = niak_read_csv(path_model);

% Create output directory
psom_mkdir(path_out)

% grab file extension
ext_m = ext_v;

% set up stack dimensions
tmp_id = id{1};
vol_ex = [path_in '*' tmp_id '*' ext_m];
[hdr,mask] = niak_read_vol(vol_ex); % grab first volume for dimensions
stack = zeros([size(mask) length(id)]);

% Network 4D volumes with M subjects

for ii = 1:length(id)
    sub = id{ii};
    path_vol = [path_in '*' sub '*' ext_m];
    [hdr,vol] = niak_read_vol(path_vol);
    if size(vol,4) > 1
        vol = vol(:,:,:,1);
    end
    stack(:,:,:,ii) = vol;
end
hdr.file_name = strcat(path_out, 'stack_4d', ext_m);
niak_write_vol(hdr,stack);

% Mean & std 4D volumes with N networks
mean_stack(:,:,:) = mean(stack,4);
std_stack(:,:,:) = std(stack,0,4);

hdr.file_name = [path_out 'stack_mean' ext_m];
niak_write_vol(hdr,mean_stack);
hdr.file_name = [path_out,'stack_std' ext_m];
niak_write_vol(hdr,std_stack);