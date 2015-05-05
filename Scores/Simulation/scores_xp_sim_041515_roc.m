%% Just the ROC analysis
clear all; close all;
%% Make signal
fig_path = '/home/surchs/Code/Projects/Scores/Simulation/figures';
n_rep = 100;
edge = 32;
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
[tseries_clean,~] = niak_simus_scenario(opt_s);
opt_s.fwhm = 5;
[tseries_smooth,~] = niak_simus_scenario(opt_s);
opt_s.fwhm = 1;
opt_s.t = 1000;
[tseries_long,~] = niak_simus_scenario(opt_s);

%% Make priors
prior_regular_vec = opt_mplm.space.mpart{2};
prior_regular = reshape(prior_regular_vec, [edge, edge]);

prior_shift = circshift(prior_regular, 3, 1);
prior_shift = circshift(prior_shift, 3, 2);
prior_shift_vec = reshape(prior_shift, [dot(edge, edge), 1]);

%% Make the labels for the ROC analysis
corner_regular_labels = prior_regular==corner_net;
corner_regular_labels = corner_regular_labels(:);

border_regular_labels = prior_regular==border_net;
border_regular_labels = border_regular_labels(:);

sig_names = {'noisy', 'clean', 'smooth'};
sig_tseries = {tseries_noise, tseries_clean, tseries_smooth};

%% Prepare storage for permuation test:
common_x = linspace(0,1,1025);
% 1: reps
% 2: voxels / methods
% 3: methods / signals
% 4: signals
roc_storage = zeros(n_rep, 1025, 3, 3);
auc_storage = zeros(n_rep, 3, 3);
for perm_id = 1:n_rep
    edge = 32;
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
    [tseries_clean,~] = niak_simus_scenario(opt_s);
    opt_s.fwhm = 5;
    [tseries_smooth,~] = niak_simus_scenario(opt_s);
    opt_s.fwhm = 1;
    opt_s.t = 1000;
    [tseries_long,~] = niak_simus_scenario(opt_s);
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
    end
end