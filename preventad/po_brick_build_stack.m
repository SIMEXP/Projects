function stack = po_brick_build_stack(path_in,path_out,path_model,scale)
% Create network, mean and std stack 4D maps from individual functional maps
% Syntax: STACK = PO_BRICK_BUILD_STACK(PATH_IN,PATH_OUT,PATH_MODEL,SCALE,OPT)
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
% SCALE (integer) the number of networks in individual maps
%
% STACK 4D volumes stacking individual maps x N networks + 4D volumes stacking 
%   networks for the mean and std across individual maps. 
%
% (C) Pierre Orban 2016


%% Read model
[~,id,~,~] = niak_read_csv(path_model);

% Create output directory
psom_mkdir(path_out)

% Network 4D volumes with M subjects
for ss = 1:scale
    for ii = 1:length(id)
        sub = id{ii};
        path_vol = [path_in sub '*.nii.gz'];
        [hdr,vol] = niak_read_vol(path_vol);
        stack(:,:,:,ii) = vol(:,:,:,ss);
    end
    hdr.file_name = [path_out 'stack_net_' num2str(ss) '.nii.gz'];
    niak_write_vol(hdr,stack);
    
    % Mean & std 4D volumes with N networks
    mean_stack(:,:,:,ss) = mean(stack,4);
    std_stack(:,:,:,ss) = std(stack,0,4);
end
hdr.file_name = [path_out 'stack_mean.nii.gz'];
niak_write_vol(hdr,mean_stack);
hdr.file_name = [path_out,'stack_std.nii.gz'];
niak_write_vol(hdr,std_stack);









