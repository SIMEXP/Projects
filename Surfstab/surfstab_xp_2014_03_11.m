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

opt_s.type = 'checkerboard'; % Checkerboard simulations
opt_s.t = t; % The number of time points. Times series are generated as AR(1) Gaussian processes. See NIAK_SAMPLE_MPLM.
opt_s.n = n % The space is a 32x32 square. N needs to be of the form 2^N
opt_s.nb_clusters = [4 16]; % Number of clusters for multiscale structure. Any number of levels is supported, but the scales have to be of the form 4^N
opt_s.fwhm = 3; % The FWHM of the Gaussian isotropic 2D spatial filtering. This will blur the edges between clusters.
opt_s.variance = 1; % The variance of the signal to simulate the cluster structure. The i.i.d. has a variance of 1, so a choice of 1 here corresponds to a SNR of 1. 

% Set up opt
simu_name = sprintf('stabsurf_fwhm_%d_var_%d', opt_s.fwhm, opt_s.variance);
opt.folder_out = [path_simu simu_name];
opt.name_data = 'data';
opt.scale = [2 4 6 8 10 12 14 16 18 20];
opt.region_growing.thre_size = 0;
opt.stability_atom.nb_batch = 10;
opt.stability_vertex.nb_batch = 10;
% Sampling
opt.sampling = opt_s;
% Flags
opt.flag_cons = true;
opt.flag_cores = true;
opt.flag_rand = false;
opt.flag_verbose = true;
opt.flag_test = false;
opt.psom.qsub_options = '-q sw -l nodes=1:ppn=2,walltime=05:00:00';
opt.psom.max_queued = 2;

% Copy this file to the working directory as an efference copy
file_name = sprintf('%s_%s.m', date, simu_name);
script_path = [opt.folder_out '/' file_name];
if ~isdir(opt.folder_out)
    niak_mkdir(opt.folder_out);
end
orig_path = sprintf('%s.m', mfilename('fullpath'));
copyfile(orig_path, script_path);

[tseries,opt_x] = niak_simus_scenario (opt_s);

% Get a mask for the neighbourhood
mask = true(k);
neigh = niak_build_neighbour(mask, 6);
out = struct;
out.neigh = neigh;
out_neigh = [path_simu 'neigh.mat'];
save(out_neigh, '-struct', 'out');

out = struct;
out.data = tseries;
data_name = sprintf('%s.mat', simu_name);
data_path = [path_simu data_name];
save(data_path, '-struct', 'out');

copyfile(data_path, [opt.folder_out '/' data_name]);

% Set up the input file
in.data = data_path;
in.neigh = out_neigh;

opt_p.path_logs = [opt.folder_out filesep 'logs'];
opt_p.flag_pause = false;
% Call the pipeline
pipe = niak_pipeline_stability_surf(in,opt);

