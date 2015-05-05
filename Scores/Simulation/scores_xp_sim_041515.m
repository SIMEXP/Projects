clear all; close all;
%% Make signal
edge = 32;
corner_net = 1;
border_net = 6;
legends = {'scores', 'seed', 'dual regression'};
fig_path = '/home/surchs/Code/Projects/Scores/Simulation/figures';

opt_s.type = 'checkerboard';
opt_s.t = 100;
opt_s.n = edge*edge;
opt_s.nb_clusters = [4 16];
opt_s.fwhm = 1;
opt_s.variance = 0.05;

[tseries_noise,opt_mplm] = niak_simus_scenario(opt_s);
opt_s.variance = 0.5;
[tseries_clean,~] = niak_simus_scenario(opt_s);
opt_s.fwhm = 5;
[tseries_smooth,~] = niak_simus_scenario(opt_s);
opt_s.fwhm = 1;
opt_s.t = 1000;
[tseries_long,~] = niak_simus_scenario(opt_s);

%% Show noise signal
fig = figure('position',[0 0 400 400]);

R_noise = corr(tseries_noise);
hier_noise = niak_hierarchical_clustering(R_noise);
order_noise = niak_hier2order(hier_noise);
niak_visu_matrix(R_noise(order_noise, order_noise));
title('Noisy Signal');

set(fig,'PaperPositionMode','auto');
print(fig, [fig_path filesep 'noisy_signal.png'], '-dpng');
%% Show clean signal
fig = figure('position',[0 0 400 400]);

R_clean = corr(tseries_clean);
hier_clean = niak_hierarchical_clustering(R_clean);
order_clean = niak_hier2order(hier_clean);
niak_visu_matrix(R_clean(order_clean, order_clean));
title('Clean Signal');

set(fig,'PaperPositionMode','auto');
print(fig, [fig_path filesep 'clean_signal.png'], '-dpng');
%% Show smooth signal
fig = figure('position',[0 0 400 400]);

R_smooth = corr(tseries_smooth);
hier_smooth = niak_hierarchical_clustering(R_smooth);
order_smooth = niak_hier2order(hier_smooth);
niak_visu_matrix(R_smooth(order_smooth, order_smooth));
title('Smooth Signal');

set(fig,'PaperPositionMode','auto');
print(fig, [fig_path filesep 'smooth_signal.png'], '-dpng');
%% Make priors
prior_regular_vec = opt_mplm.space.mpart{2};
prior_regular = reshape(prior_regular_vec, [edge, edge]);

fig = figure('position',[0 0 650 650]);
niak_visu_matrix(prior_regular);
title('Regular Prior');
set(fig,'PaperPositionMode','auto');
print(fig, [fig_path filesep 'regular_prior.png'], '-dpng');


prior_shift = circshift(prior_regular, 3, 1);
prior_shift = circshift(prior_shift, 3, 2);
prior_shift_vec = reshape(prior_shift, [dot(edge, edge), 1]);

fig = figure('position',[0 0 650 650]);
niak_visu_matrix(prior_shift);
title('Shifted Prior');
set(fig,'PaperPositionMode','auto');
print(fig, [fig_path filesep 'shifted_prior.png'], '-dpng');
%% Make the labels for the ROC analysis
corner_regular_labels = prior_regular==corner_net;
corner_regular_labels = corner_regular_labels(:);

border_regular_labels = prior_regular==border_net;
border_regular_labels = border_regular_labels(:);

corner_shift_labels = prior_shift==corner_net;
corner_shift_labels = corner_shift_labels(:);

border_shift_labels = prior_shift==border_net;
border_shift_labels = border_shift_labels(:);

sig_names = {'noisy', 'clean', 'smooth'};
sig_tseries = {tseries_noise, tseries_clean, tseries_smooth};
%% Begin the loop over the three signals
for s_id = 1:3
    sig_name = sig_names{s_id};
    tseries = sig_tseries{s_id};
    %% Scores
    %# Run scores
    opt_scores.sampling.type = 'bootstrap';
    opt_scores.sampling.opt = opt_s;
    %# Scores with correct prior
    res_scores_reg = niak_stability_cores(tseries,prior_regular_vec,opt_scores);
    scores_reg_corner = reshape(res_scores_reg.stab_maps(:, corner_net), [32 32]);
    scores_reg_border = reshape(res_scores_reg.stab_maps(:, border_net), [32 32]);
    %# Scores with bad prior
    res_scores_shift = niak_stability_cores(tseries,prior_shift_vec,opt_scores);
    scores_shift_corner = reshape(res_scores_shift.stab_maps(:, corner_net), [32 32]);
    scores_shift_border = reshape(res_scores_shift.stab_maps(:, border_net), [32 32]);
    
    %% Seed
    opt_t.type_center = 'mean';
    opt_t.correction = 'mean_var';
    tseed_reg = niak_build_tseries(tseries,prior_regular_vec,opt_t);
    seed_tmp_reg = niak_fisher(corr(tseries,tseed_reg))';
    seed_reg_corner = reshape(seed_tmp_reg(corner_net, :), [32 32]);
    seed_reg_border = reshape(seed_tmp_reg(border_net, :), [32 32]);
    
    
    tseed_shift = niak_build_tseries(tseries,prior_shift_vec,opt_t);
    seed_tmp_shift = niak_fisher(corr(tseries,tseed_shift))';
    seed_shift_corner = reshape(seed_tmp_shift(corner_net, :), [32 32]);
    seed_shift_border = reshape(seed_tmp_shift(border_net, :), [32 32]);
    %% Dual Regression
    opt_t.type_center = 'mean';
    opt_t.correction = 'mean_var';
    tseed_reg = niak_build_tseries(tseries,prior_regular_vec,opt_t);
    tseed_reg = niak_normalize_tseries(tseed_reg);
    tseries_dual = niak_normalize_tseries(tseries);
    beta_reg = niak_lse(tseries_dual,tseed_reg);
    dureg_reg_corner = reshape(beta_reg(corner_net, :), [32 32]);
    dureg_reg_border = reshape(beta_reg(border_net, :), [32 32]);
    
    tseed_shift = niak_build_tseries(tseries,prior_shift_vec,opt_t);
    tseed_shift = niak_normalize_tseries(tseed_shift);
    tseries_dual = niak_normalize_tseries(tseries);
    beta_shift = niak_lse(tseries_dual,tseed_shift);
    dureg_shift_corner = reshape(beta_shift(corner_net, :), [32 32]);
    dureg_shift_border = reshape(beta_shift(border_net, :), [32 32]);
    
    %% Regular Prior NOISY ROC
    [X_scores_b_reg, roc_scores_b_reg, ~, AUC_scores_b_reg] = perfcurve(border_regular_labels, scores_reg_border(:), true);
    [X_seed_b_reg, roc_seed_b_reg, ~, AUC_seed_b_reg] = perfcurve(border_regular_labels, seed_reg_border(:), true);
    [X_dureg_b_reg, roc_dureg_b_reg, ~, AUC_dureg_b_reg] = perfcurve(border_regular_labels, dureg_reg_border(:), true);
    
    [X_scores_c_reg, roc_scores_c_reg, ~, AUC_scores_c_reg] = perfcurve(corner_regular_labels, scores_reg_corner(:), true);
    [X_seed_c_reg, roc_seed_c_reg, ~, AUC_seed_c_reg] = perfcurve(corner_regular_labels, seed_reg_corner(:), true);
    [X_dureg_c_reg, roc_dureg_c_reg, ~, AUC_dureg_c_reg] = perfcurve(corner_regular_labels, dureg_reg_corner(:), true);
    
    %% Shifted Prior NOISY ROC
    [X_scores_b_shift, roc_scores_b_shift, ~, AUC_scores_b_shift] = perfcurve(border_regular_labels, scores_shift_border(:), true);
    [X_seed_b_shift, roc_seed_b_shift, ~, AUC_seed_b_shift] = perfcurve(border_regular_labels, seed_shift_border(:), true);
    [X_dureg_b_shift, roc_dureg_b_shift, ~, AUC_dureg_b_shift] = perfcurve(border_regular_labels, dureg_shift_border(:), true);
    
    [X_scores_c_shift, roc_scores_c_shift, ~, AUC_scores_c_shift] = perfcurve(corner_regular_labels, scores_shift_corner(:), true);
    [X_seed_c_shift, roc_seed_c_shift, ~, AUC_seed_c_shift] = perfcurve(corner_regular_labels, seed_shift_corner(:), true);
    [X_dureg_c_shift, roc_dureg_c_shift, ~, AUC_dureg_c_shift] = perfcurve(corner_regular_labels, dureg_shift_corner(:), true);
    
    %% Visualize these things 
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
    
    suptitle(sprintf('Regular prior, %s signal', sig_name));
    set(fig,'PaperPositionMode','auto');
    print(fig, [fig_path filesep sprintf('reg_prior_%s_signal.png', sig_name)], '-dpng');
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
    
    suptitle(sprintf('Shifted prior, %s signal', sig_name));
    set(fig,'PaperPositionMode','auto');
    print(fig, [fig_path filesep sprintf('shift_prior_%s_signal.png', sig_name)], '-dpng');
    
    %% Plot the ROC analysis for smooth signal and regular prior
    fig = figure('position',[0 0 1000 650]);
    opt.limits = [-1 1];
    opt.color_map = 'hot_cold';
    
    ax1 = subplot(1,2,1);
    hold on;
    plot(X_scores_c_reg, roc_scores_c_reg, 'r');
    plot(X_seed_c_reg, roc_seed_c_reg, 'g');
    plot(X_dureg_c_reg, roc_dureg_c_reg, 'b');
    hold off;
    legends = {sprintf('scores (%.4f)',AUC_scores_c_reg),...
        sprintf('seed (%.4f)', AUC_seed_c_reg),...
        sprintf('dual regression (%.4f)', AUC_dureg_c_reg)};
    legend(ax1, legends, 'Location', 'southeast');
    title('ROC for corner prior');
    
    ax2 = subplot(1,2,2);
    hold on;
    plot(X_scores_b_reg, roc_scores_b_reg, 'r');
    plot(X_seed_b_reg, roc_seed_b_reg, 'g');
    plot(X_dureg_b_reg, roc_dureg_b_reg, 'b');
    hold off;
    legends = {sprintf('scores (%.4f)',AUC_scores_b_reg),...
        sprintf('seed (%.4f)', AUC_seed_b_reg),...
        sprintf('dual regression (%.4f)', AUC_dureg_b_reg)};
    legend(ax2, legends, 'Location', 'southeast');
    title('ROC for border prior');
    
    suptitle(sprintf('Regular prior, %s signal', sig_name));
    axes(legend)
    set(fig,'PaperPositionMode','auto');
    print(fig, [fig_path filesep sprintf('reg_prior_%s_signal_ROC.png', sig_name)], '-dpng');
    
    %% Plot the ROC analysis for smooth signal and shifted prior
    fig = figure('position',[0 0 1000 650]);
    opt.limits = [-1 1];
    opt.color_map = 'hot_cold';
    
    ax1 = subplot(1,2,1);
    hold on;
    plot(X_scores_c_shift, roc_scores_c_shift, 'r');
    plot(X_seed_c_shift, roc_seed_c_shift, 'g');
    plot(X_dureg_c_shift, roc_dureg_c_shift, 'b');
    hold off;
    legends = {sprintf('scores (%.4f)',AUC_scores_c_shift),...
        sprintf('seed (%.4f)', AUC_seed_c_shift),...
        sprintf('dual regression (%.4f)', AUC_dureg_c_shift)};
    legend(ax1, legends, 'Location', 'southeast');
    title('ROC for corner prior');
    
    ax2 = subplot(1,2,2);
    hold on;
    plot(X_scores_b_shift, roc_scores_b_shift, 'r');
    plot(X_seed_b_shift, roc_seed_b_shift, 'g');
    plot(X_dureg_b_shift, roc_dureg_b_shift, 'b');
    hold off;
    legends = {sprintf('scores (%.4f)',AUC_scores_b_shift),...
        sprintf('seed (%.4f)', AUC_seed_b_shift),...
        sprintf('dual regression (%.4f)', AUC_dureg_b_shift)};
    legend(ax2, legends, 'Location', 'southeast');
    title('ROC for border prior');
    
    suptitle(sprintf('Shifted prior, %s signal', sig_name));
    axes(legend)
    set(fig,'PaperPositionMode','auto');
    print(fig, [fig_path filesep sprintf('shift_prior_%s_signal_ROC.png', sig_name)], '-dpng');
    
end