%% Make signal
edge = 32;
corner_net = 2;
corner_net = 1;
border_net = 6;

opt_s.type = 'checkerboard'; 
opt_s.t = 100; 
opt_s.n = edge*edge; 
opt_s.nb_clusters = [4 16]; 
opt_s.fwhm = 1; 
opt_s.variance = 0.05;

[tseries_noise,opt_mplm] = niak_simus_scenario(opt_s);
opt_s.variance = 0.5;
[tseries_clean,opt_mplm] = niak_simus_scenario(opt_s);
opt_s.fwhm = 5; 
[tseries_smooth,opt_mplm] = niak_simus_scenario(opt_s);
opt_s.fwhm = 1; 
opt_s.t = 1000;
[tseries_long,opt_mplm] = niak_simus_scenario(opt_s);

%% Show thing
R_noise = corr(tseries_noise);
hier_noise = niak_hierarchical_clustering(R_noise);
order_noise = niak_hier2order(hier_noise);
niak_visu_matrix(R_noise(order_noise, order_noise));

%% Make priors
prior_regular_vec = opt_mplm.space.mpart{2};
prior_regular = reshape(prior_regular_vec, [edge, edge]);

figure;
niak_visu_matrix(prior_regular);

prior_shift = circshift(prior_regular, 3, 1);
prior_shift = circshift(prior_shift, 3, 2);
prior_shift_vec = reshape(prior_shift, [dot(edge, edge), 1]);

figure;
niak_visu_matrix(prior_shift);
%% Scores
%# Run scores
opt_scores.sampling.type = 'bootstrap';
opt_scores.sampling.opt = opt_s;
%# Scores with correct prior
res_scores_reg = niak_stability_cores(tseries_noise,prior_regular_vec,opt_scores);
scores_reg_corner = reshape(res_scores_reg.stab_maps(:, corner_net), [32 32]);
scores_reg_border = reshape(res_scores_reg.stab_maps(:, border_net), [32 32]);
%# Scores with bad prior
res_scores_shift = niak_stability_cores(tseries_noise,prior_shift_vec,opt_scores);
scores_shift_corner = reshape(res_scores_shift.stab_maps(:, corner_net), [32 32]);
scores_shift_border = reshape(res_scores_shift.stab_maps(:, border_net), [32 32]);

%% Seed
opt_t.type_center = 'mean';
opt_t.correction = 'mean_var';
tseed_reg = niak_build_tseries(tseries_noise,prior_regular_vec,opt_t);
seed_tmp_reg = niak_fisher(corr(tseries_noise,tseed_reg))';
seed_reg_corner = reshape(seed_tmp_reg(corner_net, :), [32 32]);
seed_reg_border = reshape(seed_tmp_reg(border_net, :), [32 32]);


tseed_shift = niak_build_tseries(tseries_noise,prior_shift_vec,opt_t);
seed_tmp_shift = niak_fisher(corr(tseries_noise,tseed_shift))';
seed_shift_corner = reshape(seed_tmp_shift(corner_net, :), [32 32]);
seed_shift_border = reshape(seed_tmp_shift(border_net, :), [32 32]);
%% Dual Regression
opt_t.type_center = 'mean';
opt_t.correction = 'mean_var';
tseed_reg = niak_build_tseries(tseries_noise,prior_regular_vec,opt_t);
tseed_reg = niak_normalize_tseries(tseed_reg);
tseries_dual = niak_normalize_tseries(tseries_noise);
beta_reg = niak_lse(tseries_dual,tseed_reg);
dureg_reg_corner = reshape(beta_reg(corner_net, :), [32 32]);
dureg_reg_border = reshape(beta_reg(border_net, :), [32 32]);

tseed_shift = niak_build_tseries(tseries_noise,prior_shift_vec,opt_t);
tseed_shift = niak_normalize_tseries(tseed_shift);
tseries_dual = niak_normalize_tseries(tseries_noise);
beta_shift = niak_lse(tseries_dual,tseed_shift);
dureg_shift_corner = reshape(beta_shift(corner_net, :), [32 32]);
dureg_shift_border = reshape(beta_shift(border_net, :), [32 32]);

%% Visualize these things for the noisy signal
%%matlab
fig = figure('position',[0 0 1000 650]);
opt.limits = [-1 1];
opt.color_map = 'hot_cold';

subaxis(2,3,1, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(scores_reg_corner, opt);
title('corner scores');
axis tight
axis off

subaxis(2,3,2, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(seed_reg_corner, opt);
title('corner seed');
axis tight
axis off

subaxis(2,3,3, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(dureg_reg_corner, opt);
title('corner dual regression');
axis tight
axis off

subaxis(2,3,4, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(scores_reg_border, opt);
title('border scores');
axis tight
axis off

subaxis(2,3,5, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(seed_reg_border, opt);
title('border seed');
axis tight
axis off

subaxis(2,3,6, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(dureg_reg_border, opt);
title('border dual regression');

suptitle('Regular prior, noisy signal');
%% Now do the same thing but with the shifted prior
%%matlab
fig = figure('position',[0 0 1000 650]);
opt.limits = [0 1];
opt.color_map = 'hot_cold';

subaxis(2,3,1, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(scores_shift_corner, opt);
title('corner scores');
axis tight
axis off

subaxis(2,3,2, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(seed_shift_corner, opt);
title('corner seed');
axis tight
axis off

subaxis(2,3,3, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(dureg_shift_corner, opt);
title('corner dual regression');
axis tight
axis off

subaxis(2,3,4, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(scores_shift_border, opt);
title('border scores');
axis tight
axis off

subaxis(2,3,5, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(seed_shift_border, opt);
title('border seed');
axis tight
axis off

subaxis(2,3,6, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(dureg_shift_border, opt);
title('border dual regression');

suptitle('Shifted prior, noisy signal');

%% Same thing again, but now with the clean signal
%% Scores
%# Run scores
opt_scores.sampling.type = 'bootstrap';
opt_scores.sampling.opt = opt_s;
%# Scores with correct prior
res_scores_reg = niak_stability_cores(tseries_clean,prior_regular_vec,opt_scores);
scores_reg_corner = reshape(res_scores_reg.stab_maps(:, corner_net), [32 32]);
scores_reg_border = reshape(res_scores_reg.stab_maps(:, border_net), [32 32]);
%# Scores with bad prior
res_scores_shift = niak_stability_cores(tseries_clean,prior_shift_vec,opt_scores);
scores_shift_corner = reshape(res_scores_shift.stab_maps(:, corner_net), [32 32]);
scores_shift_border = reshape(res_scores_shift.stab_maps(:, border_net), [32 32]);

%% Seed
opt_t.type_center = 'mean';
opt_t.correction = 'mean_var';
tseed_reg = niak_build_tseries(tseries_clean,prior_regular_vec,opt_t);
seed_tmp_reg = niak_fisher(corr(tseries_clean,tseed_reg))';
seed_reg_corner = reshape(seed_tmp_reg(corner_net, :), [32 32]);
seed_reg_border = reshape(seed_tmp_reg(border_net, :), [32 32]);


tseed_shift = niak_build_tseries(tseries_clean,prior_shift_vec,opt_t);
seed_tmp_shift = niak_fisher(corr(tseries_clean,tseed_shift))';
seed_shift_corner = reshape(seed_tmp_shift(corner_net, :), [32 32]);
seed_shift_border = reshape(seed_tmp_shift(border_net, :), [32 32]);
%% Dual Regression
opt_t.type_center = 'mean';
opt_t.correction = 'mean_var';
tseed_reg = niak_build_tseries(tseries_clean,prior_regular_vec,opt_t);
tseed_reg = niak_normalize_tseries(tseed_reg);
tseries_dual = niak_normalize_tseries(tseries_clean);
beta_reg = niak_lse(tseries_dual,tseed_reg);
dureg_reg_corner = reshape(beta_reg(corner_net, :), [32 32]);
dureg_reg_border = reshape(beta_reg(border_net, :), [32 32]);

tseed_shift = niak_build_tseries(tseries_clean,prior_shift_vec,opt_t);
tseed_shift = niak_normalize_tseries(tseed_shift);
tseries_dual = niak_normalize_tseries(tseries_clean);
beta_shift = niak_lse(tseries_dual,tseed_shift);
dureg_shift_corner = reshape(beta_shift(corner_net, :), [32 32]);
dureg_shift_border = reshape(beta_shift(border_net, :), [32 32]);

%% Visualize these things for the clean signal
%%matlab
fig = figure('position',[0 0 1000 650]);
opt.limits = [-1 1];
opt.color_map = 'hot_cold';

subaxis(2,3,1, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(scores_reg_corner, opt);
title('corner scores');
axis tight
axis off

subaxis(2,3,2, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(seed_reg_corner, opt);
title('corner seed');
axis tight
axis off

subaxis(2,3,3, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(dureg_reg_corner, opt);
title('corner dual regression');
axis tight
axis off

subaxis(2,3,4, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(scores_reg_border, opt);
title('border scores');
axis tight
axis off

subaxis(2,3,5, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(seed_reg_border, opt);
title('border seed');
axis tight
axis off

subaxis(2,3,6, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(dureg_reg_border, opt);
title('border dual regression');

suptitle('Regular prior, clean signal');
%% Now do the same thing but with the shifted prior
%%matlab
fig = figure('position',[0 0 1000 650]);
opt.limits = [0 1];
opt.color_map = 'hot_cold';

subaxis(2,3,1, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(scores_shift_corner, opt);
title('corner scores');
axis tight
axis off

subaxis(2,3,2, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(seed_shift_corner, opt);
title('corner seed');
axis tight
axis off

subaxis(2,3,3, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(dureg_shift_corner, opt);
title('corner dual regression');
axis tight
axis off

subaxis(2,3,4, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(scores_shift_border, opt);
title('border scores');
axis tight
axis off

subaxis(2,3,5, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(seed_shift_border, opt);
title('border seed');
axis tight
axis off

subaxis(2,3,6, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(dureg_shift_border, opt);
title('border dual regression');

suptitle('Shifted prior, clean signal');

%% Smoothed time series
%% Scores
%# Run scores
opt_scores.sampling.type = 'bootstrap';
opt_scores.sampling.opt = opt_s;
%# Scores with correct prior
res_scores_reg = niak_stability_cores(tseries_smooth,prior_regular_vec,opt_scores);
scores_reg_corner = reshape(res_scores_reg.stab_maps(:, corner_net), [32 32]);
scores_reg_border = reshape(res_scores_reg.stab_maps(:, border_net), [32 32]);
%# Scores with bad prior
res_scores_shift = niak_stability_cores(tseries_smooth,prior_shift_vec,opt_scores);
scores_shift_corner = reshape(res_scores_shift.stab_maps(:, corner_net), [32 32]);
scores_shift_border = reshape(res_scores_shift.stab_maps(:, border_net), [32 32]);

%% Seed
opt_t.type_center = 'mean';
opt_t.correction = 'mean_var';
tseed_reg = niak_build_tseries(tseries_smooth,prior_regular_vec,opt_t);
seed_tmp_reg = niak_fisher(corr(tseries_smooth,tseed_reg))';
seed_reg_corner = reshape(seed_tmp_reg(corner_net, :), [32 32]);
seed_reg_border = reshape(seed_tmp_reg(border_net, :), [32 32]);


tseed_shift = niak_build_tseries(tseries_smooth,prior_shift_vec,opt_t);
seed_tmp_shift = niak_fisher(corr(tseries_smooth,tseed_shift))';
seed_shift_corner = reshape(seed_tmp_shift(corner_net, :), [32 32]);
seed_shift_border = reshape(seed_tmp_shift(border_net, :), [32 32]);
%% Dual Regression
opt_t.type_center = 'mean';
opt_t.correction = 'mean_var';
tseed_reg = niak_build_tseries(tseries_smooth,prior_regular_vec,opt_t);
tseed_reg = niak_normalize_tseries(tseed_reg);
tseries_dual = niak_normalize_tseries(tseries_smooth);
beta_reg = niak_lse(tseries_dual,tseed_reg);
dureg_reg_corner = reshape(beta_reg(corner_net, :), [32 32]);
dureg_reg_border = reshape(beta_reg(border_net, :), [32 32]);

tseed_shift = niak_build_tseries(tseries_smooth,prior_shift_vec,opt_t);
tseed_shift = niak_normalize_tseries(tseed_shift);
tseries_dual = niak_normalize_tseries(tseries_smooth);
beta_shift = niak_lse(tseries_dual,tseed_shift);
dureg_shift_corner = reshape(beta_shift(corner_net, :), [32 32]);
dureg_shift_border = reshape(beta_shift(border_net, :), [32 32]);

%% Visualize these things for the clean signal
%%matlab
fig = figure('position',[0 0 1000 650]);
opt.limits = [-1 1];
opt.color_map = 'hot_cold';

subaxis(2,3,1, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(scores_reg_corner, opt);
title('corner scores');
axis tight
axis off

subaxis(2,3,2, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(seed_reg_corner, opt);
title('corner seed');
axis tight
axis off

subaxis(2,3,3, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(dureg_reg_corner, opt);
title('corner dual regression');
axis tight
axis off

subaxis(2,3,4, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(scores_reg_border, opt);
title('border scores');
axis tight
axis off

subaxis(2,3,5, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(seed_reg_border, opt);
title('border seed');
axis tight
axis off

subaxis(2,3,6, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(dureg_reg_border, opt);
title('border dual regression');

suptitle('Regular prior, smoothed signal');
%% Now do the same thing but with the shifted prior
%%matlab
fig = figure('position',[0 0 1000 650]);
opt.limits = [0 1];
opt.color_map = 'hot_cold';

subaxis(2,3,1, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(scores_shift_corner, opt);
title('corner scores');
axis tight
axis off

subaxis(2,3,2, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(seed_shift_corner, opt);
title('corner seed');
axis tight
axis off

subaxis(2,3,3, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(dureg_shift_corner, opt);
title('corner dual regression');
axis tight
axis off

subaxis(2,3,4, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(scores_shift_border, opt);
title('border scores');
axis tight
axis off

subaxis(2,3,5, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(seed_shift_border, opt);
title('border seed');
axis tight
axis off

subaxis(2,3,6, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
niak_visu_matrix(dureg_shift_border, opt);
title('border dual regression');

suptitle('Shifted prior, smoothed signal');