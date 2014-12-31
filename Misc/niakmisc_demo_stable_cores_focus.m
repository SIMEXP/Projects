clear

%% This script will download and extract some data in the current folder, if it can't find an archive called cambridge_24_subjects_tseries.zip
%  It will also generate a number of figures and volumes
%  Please execute in a dedicated folder

% Download example time series
if ~psom_exist('cambridge_24_subjects_tseries')
    system('wget http://www.nitrc.org/frs/download.php/6779/cambridge_24_subjects_tseries.zip')
    system('unzip cambridge_24_subjects_tseries.zip')
    psom_clean('cambridge_24_subjects_tseries.zip')
end

if ~psom_exist('single_subject_cambridge_preprocessed_nii')
    system('wget http://www.nitrc.org/frs/download.php/6784/single_subject_cambridge_preprocessed_nii.zip')
    system('unzip single_subject_cambridge_preprocessed_nii.zip')
    psom_clean('single_subject_cambridge_preprocessed_nii.zip')
end

%% build the average group connectome
list_files = dir([pwd filesep 'cambridge_24_subjects_tseries' filesep 'tseries_rois_*_session1_rest.mat']);
list_files = {list_files.name};
for ss = 2:length(list_files)
    data = load([pwd filesep 'cambridge_24_subjects_tseries' filesep list_files{ss}]);
    tseries = data.tseries;
    if ss == 2
        Rg = corr(tseries);
    else
        Rg = Rg + corr(tseries);
    end
end
Rg = Rg / (length(list_files)-1);

%% cluster a region of interest, based on the connectivity of
% this region with a reference region
% Here we use a higher scale partition to define the prior and the existing
% partition at scale 8 to define the ROI and the reference

% Read individual 3D+t data
[hdr,vol] = niak_read_vol([pwd filesep 'single_subject_cambridge_preprocessed_nii' filesep 'fmri_sub00156_session1_rest.nii.gz']); % read some preprocessed fmri data
mask = vol_part>0; % extract a mask of the grey matter
tseries_vox = niak_vol2tseries(vol,mask); % convert the 3D+t dataset into a 2D space x time array

% Build partitions
hier_g = niak_hierarchical_clustering(Rg); % the hierarchical clustering
opt_t.thresh = 30; % option to extract the partition (number of clusters)
part_prior = niak_threshold_hierarchy(hier_g,opt_t); % extract the prior partition
vol_prior = niak_part2vol(part_prior,rois);
part_prior = vol_prior(mask(:));
opt_t.thresh = 8; % option to extract the partition (number of clusters)
part_temp = niak_threshold_hierarchy(hier_g,opt_t); % extract the partition
vol_temp = niak_part2vol(part_temp,rois);
part_temp = vol_temp(mask(:));
part_roi = part_temp == 2; % Only those voxels will be clustered
part_ref = part_temp == 6; % Voxels are clustered base on the connectivity with this target area
part_in = [part_prior, part_roi, part_ref];

% Run stability cores
opt_scores = struct;
opt_scores.flag_focus = true;
res = niak_stability_cores(tseries_vox,part_in,opt_scores);

% Map the partition back into volume space and show what it looks like
vol_stab = niak_tseries2vol(res.stab_maps',mask);
vol_part = niak_tseries2vol(res.part_cores',mask);
part_prior_roi = part_prior'.*part_roi';
val = unique(part_prior_roi);
part_prior_roi(part_prior_roi==val(2))=1;
part_prior_roi(part_prior_roi==val(3))=2;
vol_part_prior = niak_tseries2vol(part_prior_roi,mask);
vol_part_roi = niak_tseries2vol(part_roi',mask);
vol_part_ref = niak_tseries2vol(part_ref',mask);
subplot(2,3,1)
niak_montage(vol_part_prior(:,:,24:2:40))
title('Prior partition')
subplot(2,3,2)
niak_montage(vol_part_roi(:,:,24:2:40))
title('region of interest')
subplot(2,3,3)
niak_montage(vol_part_ref(:,:,24:2:40))
title('reference regions')
subplot(2,3,4)
niak_montage(vol_part(:,:,24:2:40))
title('Consensus partition')
subplot(2,3,5)
niak_montage(vol_stab(:,:,24:2:40,1))
title('Stab map (cluster 1)')
subplot(2,3,6)
niak_montage(vol_stab(:,:,24:2:40,2))
title('Stab map (cluster 2)')

niak_montage(vol_part);
print('partition_of_roi_subject1_voxel_demoniak.png','-dpng');
hdr.file_name = 'part_roi_subject1_voxel_demoniak.nii.gz'; % save the partition in a nifti file
niak_write_vol(hdr,vol_part); 
hdr.file_name = 'stability_map_focus_subject1_voxel_demoniak.nii.gz'; % save the partition in a nifti file
niak_write_vol(hdr,vol_stab); 
