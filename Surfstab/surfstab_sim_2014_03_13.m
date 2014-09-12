% S. Urchs, P. Bellec 2014/03/11. 
% Small experiment to test the new "checkerboard" type of simulations and the stability_surf pipeline
clear

psom_set_rand_seed(3);

%path_simu = '/home/pbellec/database/surf_stab/xp_2014_02_24/';
path_simu = '/home/sebastian/Projects/niak_multiscale/local_test/';
if ~psom_exist(path_simu)
    psom_mkdir(path_simu);
end

%% Simulate data
t = 100;
k = 16;
n = k^2;

% 6 steps each
range_fwhm = [1 2 3 4 5 6];
range_variance = [0.1:0.2:1.2];

% Run the reference simulation
opt_r.type = 'checkerboard';
opt_r.t = t; 
opt_r.n = n;
opt_r.nb_clusters = [4 16];
opt_r.fwhm = 1;
opt_r.variance = 1;

[ref_tseries,opt_rx] = niak_simus_scenario (opt_r);
R_ref = niak_build_correlation(ref_tseries);
hier_ref = niak_hierarchical_clustering(R_ref);
order_ref = niak_hier2order(hier_ref);

% Prepare Figure
plot_id = 1;
fig = figure;

for fwhm_id = 1:length(range_fwhm)
    fwhm = range_fwhm(fwhm_id);
    
    for var_id = 1:length(range_variance)
        variance = range_variance(var_id);
        opt_s.type = 'checkerboard'; % Checkerboard simulations
        opt_s.t = t; % The number of time points. Times series are generated as AR(1) Gaussian processes. See NIAK_SAMPLE_MPLM.
        opt_s.n = n % The space is a 32x32 square. N needs to be of the form 2^N
        opt_s.nb_clusters = [4 16]; % Number of clusters for multiscale structure. Any number of levels is supported, but the scales have to be of the form 4^N
        opt_s.fwhm = fwhm; % The FWHM of the Gaussian isotropic 2D spatial filtering. This will blur the edges between clusters.
        opt_s.variance = variance; % The variance of the signal to simulate the cluster structure. The i.i.d. has a variance of 1, so a choice of 1 here corresponds to a SNR of 1. 

        [sub_tseries,opt_rx] = niak_simus_scenario (opt_s);
        R_sub = niak_build_correlation(sub_tseries);
        % hier_sub = niak_hierarchical_clustering(R_sub);
        % order_sub = niak_hier2order(hier_sub);
        subplot(6,6,plot_id);
        axis tight;
        opt_p.color_map = niak_hot_cold;
        opt_p.limits = [-1 1];
        opt_p.flag_bar = false;
        niak_visu_matrix(R_sub(order_ref, order_ref), opt_p);
        set(gca,'xtick',[],'ytick',[]);
        set( get(gca,'YLabel'), 'String', sprintf('%.2f',fwhm) );
        set( get(gca,'XLabel'), 'String', sprintf('%.2f',variance) );

        plot_id = plot_id + 1;

    end
end

