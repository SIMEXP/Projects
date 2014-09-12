% S. Urchs, P. Bellec 2014/02/24. 
% Small experiment to test the new "checkerboard" type of simulations and the stability_surf pipeline

clear

psom_set_rand_seed(0);

path_simu = '/home/sebastian/Projects/niak_multiscale/local_test/simus/';
%path_simu = '/home/pbellec/database/surf_stab/xp_2014_02_24/';
if ~psom_exist(path_simu)
    psom_mkdir(path_simu);
end

%% Simulate data
t = 100;
k = 32;
n = k^2;

opt_s.type = 'checkerboard'; % Checkerboard simulations
opt_s.t = t; % The number of time points. Times series are generated as AR(1) Gaussian processes. See NIAK_SAMPLE_MPLM.
opt_s.n = n % The space is a 32x32 square. N needs to be of the form 2^N
opt_s.nb_clusters = [4 16]; % Number of clusters for multiscale structure. Any number of levels is supported, but the scales have to be of the form 4^N
opt_s.fwhm = 5; % The FWHM of the Gaussian isotropic 2D spatial filtering. This will blur the edges between clusters.
opt_s.variance = 3; % The variance of the signal to simulate the cluster structure. The i.i.d. has a variance of 1, so a choice of 1 here corresponds to a SNR of 1. 

[tseries,opt_s] = niak_simus_scenario (opt_s);

% Get a mask for the neighbourhood
mask = true(k);
neigh = niak_build_neighbour(mask, 6);
out = struct;
out.neigh = neigh;
out_neigh = [path_simu 'neigh.mat'];
save(out_neigh, '-struct', 'out');

% Vectorize the tseries again
tvec = reshape(tseries, [t, n]);
out = struct;
out.data = tvec;
data_path = [path_simu 'data.mat'];
save(data_path, '-struct', 'out');

% Set up the input file
in.data = [path_simu 'data.mat'];
in.neigh = out_neigh;

% Set up opt
opt.folder_out = [path_simu 'stability_surf_4'];
opt.name_data = 'data';
opt.scale = [2 4 8 10];
opt.region_growing.thre_size = 0;
opt.stability_atom.nb_batch = 5;
opt.stability_vertex.nb_batch = 10;
opt.flag_cons = true;
opt.flag_cores = true;
opt.flag_rand = false;
opt.flag_verbose = true;
opt.flag_test = false;
%opt.psom.qsub_options = '-q qwork@ms -l nodes=1:m32G,walltime=05:00:00';
%opt.psom.max_queued = 1;

opt_p.path_logs = [opt.folder_out filesep 'logs'];
opt_p.flag_pause = false;
% Call the pipeline
pipe = niak_pipeline_stability_surf(in,opt);

