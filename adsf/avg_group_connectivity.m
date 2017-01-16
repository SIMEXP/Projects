%% script to calculate group-level average connectivity maps

clear all

%% generate the raw stack

% set files in

path_data = '/home/atam/scratch/rs_subtypes/adni2_connectomes_20161217/';

files_conn = niak_grab_connectome(path_data);
% files_in.data = files_conn.rmap;

files_in.mask = files_conn.network_rois;
files_in.model = '/home/atam/scratch/rs_subtypes/adni2_model_civet.csv';

opt.folder_out = [path_data 'stacks'];

r_fields = {'net1','net2','net3','net4','net5','net6','net7'};

for ss = 1:7
    r_field = r_fields{ss};
    files_in.data = files_conn.rmap.(r_field);
    files_out = strcat(opt.folder_out, filesep, 'stack_network', num2str(ss), '.mat');
    hack_brick_network_stack(files_in,files_out,opt);
end
    

%% calculate the average and write the volume

clear all

path_stack = '/Users/AngelaTam/Desktop/adsf/rsfmri_subtypes/adni2_rmaps_connectome/stacks/';
path_mask = '/Users/AngelaTam/Desktop/adsf/rsfmri_subtypes/adni2_rmaps_connectome/network_rois.nii.gz';
% path_out = '/home/atam/scratch/rs_subtypes/adni2_connectomes_20161217_nii/stacks/';

% read mask
[hdr,mask] = niak_read_vol(path_mask);
mask = logical(mask);

for ss = 1:7
    stack_f = strcat(path_stack, 'stack_network', num2str(ss), '.mat');
    load(stack_f); 
    raw_stack_vol = niak_tseries2vol(stack,mask);
    hdr.file_name = strcat(path_stack, 'mean_network', num2str(ss), '.nii.gz');
    niak_write_vol(hdr,mean(raw_stack_vol,4));
    hdr.file_name = strcat(path_stack, 'std_network', num2str(ss), '.nii.gz');
    niak_write_vol(hdr,std(raw_stack_vol,0,4));
end
    
   