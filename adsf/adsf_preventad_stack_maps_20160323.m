%% script to build stack maps with prevent-ad data release 2.0

%% set paths

path_in = '/Users/AngelaTam/Desktop/adsf/scores/rmap_part_20160121_nii/';
path_out = '/Users/AngelaTam/Desktop/adsf/scores/rmap_stack_20160121_nii/';
path_model = '/Users/AngelaTam/Desktop/adsf/model/preventad_model_vol_bl_dr2_20160316_qc.csv';
scale = 7;

%% Read model
[~,id,~,~] = niak_read_csv(path_model);

%% Create output directory
psom_mkdir(path_out)

%% Network 4D volumes with M subjects
for ss = 1:scale
    for ii = 1:length(id)
        sub = id{ii};
        path_vol = [path_in 'fmri_' sub '*_rest1_rmap_part.nii.gz'];
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