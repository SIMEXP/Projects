function stack = adsf_brick_3d_to_4d(path_in,path_out,path_model)
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
% OUTPUTS:
%
% STACK_4D.nii.gz
%       a 4D volume containing maps of individual subjects
% STACK_MEAN.nii.gz
% STACK_STD.nii.gz
%
%
% (C) Angela Tam 2016


%% Read model
[~,id,~,~] = niak_read_csv(path_model);

% Create output directory
psom_mkdir(path_out)

% Network 4D volumes with M subjects

for ii = 1:length(id)
    sub = id{ii};
    path_vol = [path_in '*' sub '*.nii'];
    [hdr,vol] = niak_read_vol(path_vol);
    stack(:,:,:,ii) = vol(:,:,:);
end
hdr.file_name = [path_out 'stack_4d.nii'];
niak_write_vol(hdr,stack);

% Mean & std 4D volumes with N networks
mean_stack(:,:,:,ss) = mean(stack,4);
std_stack(:,:,:,ss) = std(stack,0,4);

hdr.file_name = [path_out 'stack_mean.nii'];
niak_write_vol(hdr,mean_stack);
hdr.file_name = [path_out,'stack_std.nii'];
niak_write_vol(hdr,std_stack);