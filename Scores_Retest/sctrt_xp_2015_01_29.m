%% Sebastian (sebastian (dot) urchs (at) gmail (dot) com)
% This experiment is going to test the effect of noise on the scores and
% correlation maps
%% Setup
clear all;
close all;
%% First step: Get correlation maps from the simulation
out_path = '/data1/scores/visualization_dump';
edge = 32;

opt_s.type = 'checkerboard'; 
opt_s.t = 100; 
opt_s.n = edge*edge; 
opt_s.nb_clusters = [4 16]; 
opt_s.fwhm = 1; 
opt_s.variance = 0.05;
% Simulate the time series
[tseries,opt_mplm] = niak_simus_scenario(opt_s);
part = opt_mplm.space.mpart{2};
%% pick a target
target_net = 3;
target_part = part == target_net;
part = opt_mplm.space.mpart{2};
target = opt_mplm.space.mpart{1};
opt_scores.sampling.type = 'bootstrap';
opt_scores.sampling.opt = opt_s;
opt_scores.sampling.opt.t = ceil(0.6*opt_s.t);
% Scores
res_reg = niak_stability_cores(tseries,part,opt_scores);
scores_map = reshape(res_reg.stab_maps(:, target_net), [32 32]);
% Correlation Map
seed_sig = mean(tseries(:,target_part),2);
seed_vec = corr(seed_sig, tseries);
seed_map = reshape(seed_vec, [32 32]);
%%
figure;
subplot(1,2,1);
niak_visu_matrix(scores_map);
subplot(1,2,2);
niak_visu_matrix(seed_map);
%%
[rr cc] = meshgrid(1:32);
%C = sqrt((rr-16).^2+(cc-16).^2)<=10;
x = 16
y = 16;
left_ear = sqrt((rr-8).^2+(cc-8).^2)<=7;
right_ear = sqrt((rr-24).^2+(cc-8).^2)<=7;
face = sqrt((rr-16).^2+(cc-20).^2)<=10;
left_eye = sqrt((rr-12).^2+(cc-16).^2)<=2;
right_eye = sqrt((rr-20).^2+(cc-16).^2)<=2;
mouth = zeros(32,32);
mouth(24:25,12:20) = 1;
mousy = logical(left_ear + right_ear + face) - left_eye - right_eye - mouth;
%C = logical(C);
mouse_mask = logical(mousy);
niak_visu_matrix(mouse_mask);
mask_voxels = sum(mouse_mask(:));
%% Generate noise
noise = randn(mask_voxels,opt_s.t ).*3;
% mask the noise
long_mask = repmat(mouse_mask, [1,1, opt_s.t ]);
noise_mat = zeros(32,32,opt_s.t );
noise_mat(long_mask == 1) = noise;
noise_series = reshape(noise_mat, [1024, opt_s.t ]);
% Add the noise to the signal
t_noise = tseries' + noise_series;
t_noise = t_noise';
%% Generate uniform noise time series - every voxel get's the same
noise = randn(opt_s.t,1).*0.5;
% Repeat the noise for each mask voxel
noise_mask = repmat(noise, [1, mask_voxels]);
% Expand the mask to the length of the timeseries
mask_series = repmat(reshape(mouse_mask, [1, 1024]), [opt_s.t, 1]);
% Prepare an empty matrix of the same size as the time series
noise_series = zeros(opt_s.t, 1024);
% Mask this and add the noise
noise_series(mask_series == 1) = noise_mask;
% Add the noise to the real time series
t_noise = tseries + noise_series;
%% Now run the analysis again and show me the results
opt_scores.sampling.type = 'bootstrap';
opt_scores.sampling.opt = opt_s;
opt_scores.sampling.opt.t = ceil(0.6*opt_s.t);
res_reg = niak_stability_cores(t_noise,part,opt_scores);
scores_map = reshape(res_reg.stab_maps(:, target_net), [32 32]);
% Correlation Map
seed_sig = mean(t_noise(:,target_part),2);
seed_vec = corr(seed_sig, t_noise);
seed_map = reshape(seed_vec, [32 32]);
%% Show some results
stabi = niak_visu_matrix(scores_map);
title(sprintf('Stability Map of network %d', target_net));
saveas(stabi, [out_path filesep 'stab_map.png'],'png');

scary = niak_visu_matrix(seed_map);
title(sprintf('Seed Map of network %d', target_net));
saveas(scary, [out_path filesep 'horror_bunny_from_hell.png'],'png');