% Sebastian (sebastian (dot) urchs (at) gmail (dot) com)

% This experiment is to determine whether the simulation works well
% Test the simulation with the new scores implementation
% The goal is to 
%   first run the 'true' stability maps
%   second run the 'estimated' stability maps
%% Let's go
clear;

out_path = '/home/surchs/Projects/Scores_TRT/visualization_dump';
psom_set_rand_seed(0);

edge = 32; % Number of voxels along one side of the checkerboard

opt_s.type = 'checkerboard'; % Checkerboard simulations

opt_s.n = edge*edge; 
opt_s.nb_clusters = [4 16];
opt_s.fwhm = 5;
opt_s.variance = 0.001;
%% Call the scores function and ask it to keep sampling with the above options

% Run the first with 100 timepoints
opt_s.t = 100; 
[tseries_cent,opt_mplm_cent] = niak_simus_scenario(opt_s);
% Run the estimation
part_cent = opt_mplm_cent.space.mpart{2};
opt_scores.sampling.type = 'scenario';
opt_scores.sampling.opt = opt_s;
res_cent = niak_stability_cores(tseries_cent,part_cent,opt_scores);

% Visualize this stuff
cent = figure;
stab_cent = reshape(res_cent.stab_maps(:, 3), [32 32]); % Get the stability map of one network
niak_visu_matrix(stab_cent);
title('Simulated Stab @ 1e3 timepoints');
print(cent, '-dpng', [out_path filesep 'cent.png']);

% Run the first with 1000 timepoints
opt_s.t = 1000; 
[tseries_mill,opt_mplm_mill] = niak_simus_scenario(opt_s);
% Run the estimation
part_mill = opt_mplm_mill.space.mpart{2};
opt_scores.sampling.type = 'scenario';
opt_scores.sampling.opt = opt_s;
res_mill = niak_stability_cores(tseries_mill,part_mill,opt_scores);

% Visualize this stuff
mill = figure;
stab_mill = reshape(res_mill.stab_maps(:, 3), [32 32]); % Get the stability map of one network
niak_visu_matrix(stab_mill);
title('Simulated Stab @ 1e4 timepoints');
print(mill, '-dpng', [out_path filesep 'mill.png']);
