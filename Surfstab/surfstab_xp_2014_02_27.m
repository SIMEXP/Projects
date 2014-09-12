clear all;
close all;

t = 100;
k = 32;
n = k^2;

opt_s.type = 'checkerboard'; % Checkerboard simulations
opt_s.t = t; % The number of time points. Times series are generated as AR(1) Gaussian processes. See NIAK_SAMPLE_MPLM.
opt_s.n = n; % The space is a 32x32 square. N needs to be of the form 2^N
opt_s.nb_clusters = [4 16]; % Number of clusters for multiscale structure. Any number of levels is supported, but the scales have to be of the form 4^N
opt_s.fwhm = 1; % The FWHM of the Gaussian isotropic 2D spatial filtering. This will blur the edges between clusters.
opt_s.variance = 1; % The variance of the signal to simulate the cluster structure. The i.i.d. has a variance of 1, so a choice of 1 here corresponds to a SNR of 1. 

batch = 100;
avg_r = zeros(n, n);

for i = 1:batch
    fprintf('batch %d of %d\n', i, batch);
    
    psom_set_rand_seed(i);

    %% Simulate data
    [tseries,opt_x] = niak_simus_scenario(opt_s);

    %% There is a strong spatial structure in these simulations
    R = niak_build_correlation(reshape(tseries,[opt_x.time.t,size(tseries,2)*size(tseries,3)]));
    avg_r = avg_r + R;

end

avg_r =  avg_r / batch;

hier = niak_hierarchical_clustering(avg_r);
order = niak_hier2order(hier);

niak_visu_matrix(avg_r(order, order));
title(sprintf('Averaged temp correlation across %d random runs', batch));
print('average_correlation.png', '-dpng');