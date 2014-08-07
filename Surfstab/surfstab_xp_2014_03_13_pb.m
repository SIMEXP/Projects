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
[tseries,opt_mplm] = niak_simus_scenario (opt_s);

%% To get a feel of what is going on, it's possible to compute correlation maps for all clusters
%% at scale 16
part16 = reshape(opt_mplm.space.mpart{2},sqrt(length(opt_mplm.space.mpart{2})),sqrt(length(opt_mplm.space.mpart{2})),1);
opt_v.limits = [-0.3 1];
clf
list_fwhm = [0 1 5 10];
nb_plot = 1;
list_variance = [0.1 0.3 0.6 1];
for cc = 1:length(list_fwhm)
    for vv = 1:length(list_variance)
        opt_s.fwhm = list_fwhm(cc);
        opt_s.variance = list_variance(vv);
        [tseries,opt_mplm] = niak_simus_scenario (opt_s);   
        vol = reshape(tseries',[sqrt(size(tseries,2)) sqrt(size(tseries,2)) 1 size(tseries,1)]);
        rmap = niak_build_rmap (vol,part16==1);   
        subplot(4,4,nb_plot)
        axis tight
        nb_plot = nb_plot + 1;
        title('rows: variance; columns: fwhm')
        niak_visu_matrix(rmap,opt_v);
    end
end
