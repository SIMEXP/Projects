%%%%%%%%%%
%% Script to generate SNR in a single seed region for individual subjects
%%%%%%%%%%

clear all 
addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-boss-0.12.18'));
path_data = '/gs/scratch/atam/';
path_results = '/gs/scratch/atam/adnet/results/glm30b_nii/sci35_scg35_scf33/';

% define the template to be used for mask
[h,parcels] = niak_read_vol('/home/atam/scratch/adnet/results/glm30b_nii/networks/networks_sci35_scg35_scf33.nii.gz');

kk = 1;

%% adni2
subj_list = dir([path_data 'adni2/fmri_preprocess/anat/subject*']); % generate list of subjects
for ii = 1:length(subj_list)
    subj_name = subj_list(ii).name;
    files_list = [path_data 'adni2/fmri_preprocess/anat/' subj_name '/func_' subj_name '_mean_stereonl.mnc.gz']; % grab the mean functional image
    [h,vol]=niak_read_vol(files_list);
    
    % calculate signal in one region
    mask1 = parcels==22; % select parcel for the mask
    avg_signal = mean(vol(mask1));
    
    % calculate standard deviation of noise in square outside of the brain
    tmp_noise= vol(1:12,1:12,1:12);
    std_noise = std(tmp_noise(:));
    
    % calculate the SNR
    snr(kk) = avg_signal/std_noise;
    
    subj_names{kk} = subj_name;  % store subject names
    kk = kk+1;
end

%% mni_mci
subj_list = dir([path_data 'ad_mtl/mni_mci/fmri_preprocess/anat/ad_*']); % generate list of subjects
for ii = 1:length(subj_list)
    subj_name = subj_list(ii).name;
    files_list = [path_data 'ad_mtl/mni_mci/fmri_preprocess/anat/' subj_name '/func_' subj_name '_mean_stereonl.mnc.gz']; % grab the mean functional image
    [h,vol]=niak_read_vol(files_list);
    
    % calculate signal in one region
    mask1 = parcels==22; % select parcel for the mask
    avg_signal = mean(vol(mask1));
    
    % calculate standard deviation of noise in square outside of the brain
    tmp_noise= vol(1:12,1:12,1:12);
    std_noise = std(tmp_noise(:));
    
    % calculate the SNR
    snr(kk) = avg_signal/std_noise;
    
    subj_names{kk} = subj_name;  % store subject names
    kk = kk+1;
end

%% criugm_mci aka criugm_a
subj_list = dir([path_data 'ad_mtl/criugm_mci/fmri_preprocess/anat/SB_*']); % generate list of subjects
for ii = 1:length(subj_list)
    subj_name = subj_list(ii).name;
    files_list = [path_data 'ad_mtl/criugm_mci/fmri_preprocess/anat/' subj_name '/func_' subj_name '_mean_stereonl.mnc.gz']; % grab the mean functional image
    [h,vol]=niak_read_vol(files_list);
    
    % calculate signal in one region
    mask1 = parcels==22; % select parcel for the mask
    avg_signal = mean(vol(mask1));
    
    % calculate standard deviation of noise in square outside of the brain
    tmp_noise= vol(1:12,1:12,1:12);
    std_noise = std(tmp_noise(:));
    
    % calculate the SNR
    snr(kk) = avg_signal/std_noise;
    
    subj_names{kk} = subj_name;  % store subject names
    kk = kk+1;
end

%% adpd aka criugm_b
subj_list = dir([path_data 'ad_mtl/adpd/fmri_preprocess/anat/AD*']); % generate list of subjects
for ii = 1:length(subj_list)
    subj_name = subj_list(ii).name;
    files_list = [path_data 'ad_mtl/adpd/fmri_preprocess/anat/' subj_name '/func_' subj_name '_mean_stereonl.mnc.gz']; % grab the mean functional image
    [h,vol]=niak_read_vol(files_list);
    
    % calculate signal in one region
    mask1 = parcels==22; % select parcel for the mask
    avg_signal = mean(vol(mask1));
    
    % calculate standard deviation of noise in square outside of the brain
    tmp_noise= vol(1:12,1:12,1:12);
    std_noise = std(tmp_noise(:));
    
    % calculate the SNR
    snr(kk) = avg_signal/std_noise;
    
    subj_names{kk} = subj_name;  % store subject names
    kk = kk+1;
end

%% write csv
opt.labels_y = {'snr'};
opt.labels_x = subj_names;
niak_write_csv(strcat(path_results,'adnet_vmpfc_sc33_snr.csv'),snr',opt)

