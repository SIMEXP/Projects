% P. Bellec 2014/02/19. 
% Small experiment to test the new "checkerboard" type of simulations. 

clear

psom_set_rand_seed(0);

opt_s.type = 'checkerboard'; % Checkerboard simulations
opt_s.t = 100; % The number of time points. Times series are generated as AR(1) Gaussian processes. See NIAK_SAMPLE_MPLM.
opt_s.n = 32*32; % The space is a 32x32 square. N needs to be of the form 2^N
opt_s.nb_clusters = [4 16]; % Number of clusters for multiscale structure. Any number of levels is supported, but the scales have to be of the form 4^N
opt_s.fwhm = 1; % The FWHM of the Gaussian isotropic 2D spatial filtering. This will blur the edges between clusters.
opt_s.variance = 1; % The variance of the signal to simulate the cluster structure. The i.i.d. has a variance of 1, so a choice of 1 here corresponds to a SNR of 1. 

%% Simulate data
[tseries,opt_s] = niak_simus_scenario (opt_s);

%% Note that now the OPT_S structure is updated with the ground truth for the simulations
hf = figure;
imagesc(reshape(opt_s.space.mpart{1},[32,32]))
title('Partition at 4 clusters')
print('part_ground_truth_sc4.png','-dpng')
clf
imagesc(reshape(opt_s.space.mpart{2},[32,32]))
title('Partition at 16 clusters')
print('part_ground_truth_sc16.png','-dpng')

%% There is a strong spatial structure in these simulations
R = niak_build_correlation(tseries);
hier = niak_hierarchical_clustering(R);
order = niak_hier2order(hier);
clf 
opt_v.limits = [-0.3 1];
niak_visu_matrix(R(order,order),opt_v);
print('R.png','-dpng');

%% The spatial correlation, fortunately, does reflect the simulated clustering structure
clf
part4 = niak_threshold_hierarchy(hier,struct('thresh',4));
imagesc(reshape(part4,[32,32]))
title('Estimated partition at 4 clusters')
print('part_estimated_sc4.png','-dpng')
clf
part16 = niak_threshold_hierarchy(hier,struct('thresh',16));
imagesc(reshape(part16,[32,32]))
title('Estimated partition at 16 clusters')
print('part_estimated_sc16.png','-dpng')

%% To get a feel of what is going on, it's possible to compute correlation maps for all clusters
%% at scale 16
part16 = opt_s.space.mpart{2};
vol = reshape(tseries,[size(tseries,1) size(tseries,2)*size(tseries,3)]);
vol = reshape(vol',[size(tseries,2) size(tseries,3) 1 size(tseries,1)]);
opt_v.limits = [-0.3 1];
clf
for cc = 1:16
   rmap = niak_build_rmap (vol,reshape(part16==cc-1,[size(tseries,2) size(tseries,3)]));
   subplot(4,4,cc)
   niak_visu_matrix(rmap,opt_v);
end
print('rmaps_sc16.png','-dpng')
% Not how the position of the rmap in the 4x4 montage corresponds to the spatial location of the seed network.
% This would please Daniel Margulies, and makes for a nice figure. 
% I'd be curious to see how this compares with stability maps