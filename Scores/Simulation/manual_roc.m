%% Make the signal for smooth and shifted prior
edge = 32;
corner_net = 1;
border_net = 6;

opt_s.type = 'checkerboard'; 
opt_s.t = 100; 
opt_s.n = edge*edge; 
opt_s.nb_clusters = [4 16]; 
opt_s.variance = 0.5;
opt_s.fwhm = 5; 
[tseries_smooth,~] = niak_simus_scenario(opt_s);

%% Make the priors
prior_regular_vec = opt_mplm.space.mpart{2};
prior_regular = reshape(prior_regular_vec, [edge, edge]);

prior_shift = circshift(prior_regular, 3, 1);
prior_shift = circshift(prior_shift, 3, 2);
prior_shift_vec = reshape(prior_shift, [dot(edge, edge), 1]);

%% Make the labels for ROC
corner_regular_labels = prior_regular==corner_net;
corner_regular_labels = corner_regular_labels(:);

border_regular_labels = prior_regular==border_net;
border_regular_labels = border_regular_labels(:);

%% Run the analysis
%% Scores
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

%% Run the matlab ROC analysis
%% Shifted Prior
[X_scores_b_shift, roc_scores_b_shift, ~, AUC_scores_b_shift] = perfcurve(border_regular_labels, scores_shift_border(:), true);
[X_seed_b_shift, roc_seed_b_shift, ~, AUC_seed_b_shift] = perfcurve(border_regular_labels, seed_shift_border(:), true);
[X_dureg_b_shift, roc_dureg_b_shift, ~, AUC_dureg_b_shift] = perfcurve(border_regular_labels, dureg_shift_border(:), true);

[X_scores_c_shift, roc_scores_c_shift, ~, AUC_scores_c_shift] = perfcurve(corner_regular_labels, scores_shift_corner(:), true);
[X_seed_c_shift, roc_seed_c_shift, ~, AUC_seed_c_shift] = perfcurve(corner_regular_labels, seed_shift_corner(:), true);
[X_dureg_c_shift, roc_dureg_c_shift, ~, AUC_dureg_c_shift] = perfcurve(corner_regular_labels, dureg_shift_corner(:), true);

%% Run a manual ROC analysis
scores_vec = scores_shift_border(:);
u_val = unique(scores_vec);
n_val = length(u_val);

true_pos = zeros(n_val+1, 1);
false_pos = zeros(n_val+1, 1);
P = sum(border_regular_labels);
N = sum(~border_regular_labels);

for v_id = 2:n_val
    thresh = u_val(v_id);
    pass_thr = scores_vec > thresh;
    TP = sum(pass_thr(border_regular_labels));
    FP = sum(pass_thr(~border_regular_labels));
    tpr = TP / P;
    fpr = FP / N;
    true_pos(v_id) = tpr;
    false_pos(v_id) = fpr;
end
true_pos(1) = 1;
false_pos(1) = 1;
% Show ROC
f1 = figure;
subplot(1,2,1);
plot(false_pos, true_pos);
title('manual');
axis([0 1 0 1]);

subplot(1,2,2);
plot(X_scores_b_shift, roc_scores_b_shift);
title('matlab');

% Show maps
f2 = figure;
subplot(1,2,1);
imagesc(scores_shift_border);
grid on;
title('scores');
colormap('cool')

subplot(1,2,2);
imagesc(reshape(border_regular_labels, [32 32]));
grid on;
title('true signal');
colormap('cool')



