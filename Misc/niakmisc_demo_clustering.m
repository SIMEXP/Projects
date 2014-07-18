clear

%% This script will download and extract some data in the current folder, if it can't find an archive called cambridge_24_subjects_tseries.zip
%% It will also generate a number of figures and volumes
%% Please execute in a dedicated folder

%% Download example time series
if ~psom_exist('cambridge_24_subjects_tseries.zip')
    system('wget http://www.nitrc.org/frs/download.php/6779/cambridge_24_subjects_tseries.zip')
    system('unzip cambridge_24_subjects_tseries.zip')
end

%% Load one time series and the brain mask
data = load([pwd filesep 'cambridge_24_subjects_tseries' filesep 'tseries_rois_sub00156_session1_rest.mat']);
tseries = data.tseries;
[hdr,rois] = niak_read_vol([pwd filesep 'cambridge_24_subjects_tseries' filesep 'brain_rois.nii.gz']);

%% Compute the similarity matrix, here the correlation between regional time series
%% and apply a hierarchical clustering 
R = corr(tseries);
opt_hier.type_sim = 'ward'; % available option 'single', 'complete', 'average' and 'ward'
hier = niak_hierarchical_clustering(R);

%% let's threshold the hierarchy to generate 10 clusters, and have a look at the brain partition
opt_t.thresh = 10;
part = niak_threshold_hierarchy(hier,opt_t);
vol_part = niak_part2vol(part,rois);
hf = figure;
niak_montage(vol_part)
print('montage_scale10_sub00156.png','-dpng');
close(hf)
hdr.file_name = 'partition_scale10_sub00156.nii.gz';
niak_write_vol(hdr,vol_part);

%% OK, now let's infer an order on the regions, based on the hierarchy, and use that to have a look both at the partition 
%% and the similarity matrix
order = niak_hier2order(hier);
hf = figure;
niak_visu_part(part(order));
print('partition_matrix_ordered_scale10_sub00156.png','-dpng');
close(hf)
hf = figure;
niak_visu_matrix(abs(R(order,order)));
print('abs_corr_matrix_ordered_sub00156.png','-dpng');
close(hf);

%% Let's run a k-means this time, trying a single random partition for the initial points
psom_set_rand_seed(0); % let's seed the random number generator to get 100% reproducible clusters
opt_kmeans.type_init = 'random_partition'; % That's how initial points are selected
opt_kmeans.nb_iter = 1; % Just run k-means once
opt_kmeans.nb_classes = 10; % the number of clusters
opt_kmeans.type_death = 'singleton'; % Try to resurect empty cluster by looking at singleton data
opt_kmeans.flag_verbose = true;
[part_kmeans,gi,i_intra] = niak_kmeans_clustering(niak_normalize_tseries(tseries),opt_kmeans);
fprintf('The final intra-cluster inertia with a random partition initialization is (lower=better): %1.5f\n',sum(i_intra));

%% Let's now run k-means with k-means++ initialization, and 10 iterations
psom_set_rand_seed(0);
opt_kmeans.nb_iter = 10; % Just run k-means once
opt_kmeans.type_init = 'kmeans++';
[part_kmeansxx,gixx,i_intraxx] = niak_kmeans_clustering(niak_normalize_tseries(tseries),opt_kmeans);
fprintf('The final intra-cluster inertia with k-means++ initialization is (lower=better): %1.5f\n',sum(i_intraxx));

%% In my case (with octave) I got 61.61 with random partition and one iteration, and 60.83 with k-means++ and 10 iterations
%% Not impressive, but better

%% The clusters are in an arbitrary order, so to be able to better compare them, let's re-order them based on how
%% much overlap there is between them
match = niak_match_part(part,part_kmeansxx);
part_kmeansxx = match.part2_to_1;

%% Finally, let's have a look at the partition
vol_partxx = niak_part2vol(part_kmeansxx,rois);
hf = figure;
niak_montage(vol_partxx)
print('montage_scale10_kmeansxx_sub00156.png','-dpng');
close(hf)
hdr.file_name = 'partition_scale10_kmeansxx_sub00156.nii.gz';
niak_write_vol(hdr,vol_partxx);