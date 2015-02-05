%% Sebastian (sebastian (dot) urchs (at) gmail (dot) com)
% The purpose of this experiment is to test the effect of misalgined priors
% on stability maps - and also on seed based correlation maps
%% Setup
clear all;
close all;
%% First step: Get correlation maps from the simulation
out_path = '/data1/scores/visualization_dump';
edge = 32;
target_net = 2;

opt_s.type = 'checkerboard'; 
opt_s.t = 100; 
opt_s.n = edge*edge; 
opt_s.nb_clusters = [4 16]; 
opt_s.fwhm = 1; 
opt_s.variance = 0.05;
% Simulate the time series
[tseries,opt_mplm] = niak_simus_scenario(opt_s);
prior = opt_mplm.space.mpart{2};
% Now mess up the prior by simply rolling it a couple of voxels to the
% right and down. First get it into 2D shape so we can roll along the axis
prior_2d = reshape(prior, [edge, edge]);
% Then actually roll the thing
shifted_prior_2d = circshift(prior_2d, 3, 1);
shifted_prior_2d = circshift(shifted_prior_2d, 3, 2);
% Bring it back into vector form to apply it to the tseries in scores
shifted_prior = reshape(shifted_prior_2d, [dot(edge, edge), 1]);
%% Quick look at what's going on - hellishly ugly montage
figure;
subplot(1,2,1);
title('good prior');
niak_visu_matrix(prior_2d);
subplot(1,2,2);
niak_visu_matrix(shifted_prior_2d);
title('shifted prior');
%% Now apply the distorted filter to the scores pipeline and look at the outputs
opt_scores.sampling.type = 'bootstrap';
opt_scores.sampling.opt = opt_s;
% Scores with bad prior
res_shift = niak_stability_cores(tseries,shifted_prior,opt_scores);
scores_shift = reshape(res_shift.stab_maps(:, target_net), [32 32]);
% Scores with correct prior
res_good = niak_stability_cores(tseries,prior,opt_scores);
scores_good = reshape(res_good.stab_maps(:, target_net), [32 32]);
%% Take a quick look again
figure;
subplot(1,2,1);
niak_visu_matrix(scores_good);
title('scores with good prior');
subplot(1,2,2);
niak_visu_matrix(scores_shift);
title('scores with shifted prior');
%% Now take a look at what seed maps look like
target_good = prior == target_net;
% With the good prior
seed_sig_good = mean(tseries(:,target_good),2);
seed_vec_good = corr(seed_sig_good, tseries);
seed_map_good = reshape(seed_vec_good, [32 32]);
%
target_shift = prior == target_net;
% With the shifted prior
seed_sig_shift = mean(tseries(:,target_shift),2);
seed_vec_shift = corr(seed_sig_shift, tseries);
seed_map_shift = reshape(seed_vec_shift, [32 32]);
%% And take a look at all of them - hooray for common color scale
figure;
subplot(2,2,1);
niak_visu_matrix(scores_good);
title('scores with good prior');
subplot(2,2,2);
niak_visu_matrix(scores_shift);
title('scores with shifted prior');

subplot(2,2,3);
niak_visu_matrix(seed_map_good);
title('seed with good prior');
subplot(2,2,4);
niak_visu_matrix(seed_map_shift);
title('seed with shifted prior');
%% Here seed seems to do better. Now let's try this with completely random priors
prior_rand = randi(opt_s.nb_clusters(1),dot(edge, edge),1);
%% Take a look at the prior
niak_visu_matrix(reshape(prior_rand, [edge, edge]));
%% And now compute again
opt_scores.sampling.type = 'bootstrap';
opt_scores.sampling.opt = opt_s;
% Scores with random prior
res_rand = niak_stability_cores(tseries,prior_rand,opt_scores);
scores_rand = reshape(res_rand.stab_maps(:, target_net), [32 32]);
% And also get the seed map with the random prior
target_rand = prior_rand == target_net;
% With the shifted prior
seed_sig_rand = mean(tseries(:,target_rand),2);
seed_vec_rand = corr(seed_sig_rand, tseries);
seed_map_rand = reshape(seed_vec_rand, [32 32]);
%% And show it again
figure;
subplot(2,2,1);
niak_visu_matrix(scores_good);
title('scores with good prior');
subplot(2,2,2);
niak_visu_matrix(scores_rand);
title('scores with random prior');

subplot(2,2,3);
niak_visu_matrix(seed_map_good);
title('seed with good prior');
subplot(2,2,4);
niak_visu_matrix(seed_map_rand);
title('seed with random prior');