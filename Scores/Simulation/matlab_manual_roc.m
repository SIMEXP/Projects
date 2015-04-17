%% All about MATLAB
clear all; close all;
%% Make the signal for smooth and shifted prior
edge = 64;
shifts = 3:10;
n_shifts = length(shifts);
n_edge = edge/4;
corner_net = 1;
border_net = 6;

opt_s.type = 'checkerboard';
opt_s.t = 100;
opt_s.n = edge*edge;
opt_s.nb_clusters = [4 16];
opt_s.variance = 0.5;
opt_s.fwhm = 5;
[tseries_smooth,opt_mplm] = niak_simus_scenario(opt_s);

tpr_cell = {n_shifts,3};
fpr_cell = {n_shifts,3};
for s_id = 1:n_shifts
    fprintf('Iterating through number %d\n', s_id);
    shift = shifts(s_id);
    %% Make the priors
    prior_regular_vec = opt_mplm.space.mpart{2};
    prior_regular = reshape(prior_regular_vec, [edge, edge]);
    
    prior_shift = circshift(prior_regular, shift, 1);
    prior_shift = circshift(prior_shift, shift, 2);
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
    opt_scores.flag_verbose = false;
    %# Scores with correct prior
    res_scores_reg = niak_stability_cores(tseries_smooth,prior_regular_vec,opt_scores);
    scores_reg_corner = reshape(res_scores_reg.stab_maps(:, corner_net), [edge, edge]);
    scores_reg_border = reshape(res_scores_reg.stab_maps(:, border_net), [edge, edge]);
    %# Scores with bad prior
    res_scores_shift = niak_stability_cores(tseries_smooth,prior_shift_vec,opt_scores);
    scores_shift_corner = reshape(res_scores_shift.stab_maps(:, corner_net), [edge, edge]);
    scores_shift_border = reshape(res_scores_shift.stab_maps(:, border_net), [edge, edge]);
    
    %% Seed
    opt_t.type_center = 'mean';
    opt_t.correction = 'mean_var';
    tseed_reg = niak_build_tseries(tseries_smooth,prior_regular_vec,opt_t);
    seed_tmp_reg = niak_fisher(corr(tseries_smooth,tseed_reg))';
    seed_reg_corner = reshape(seed_tmp_reg(corner_net, :), [edge, edge]);
    seed_reg_border = reshape(seed_tmp_reg(border_net, :), [edge, edge]);
    
    
    tseed_shift = niak_build_tseries(tseries_smooth,prior_shift_vec,opt_t);
    seed_tmp_shift = niak_fisher(corr(tseries_smooth,tseed_shift))';
    seed_shift_corner = reshape(seed_tmp_shift(corner_net, :), [edge, edge]);
    seed_shift_border = reshape(seed_tmp_shift(border_net, :), [edge, edge]);
    %% Dual Regression
    opt_t.type_center = 'mean';
    opt_t.correction = 'mean_var';
    tseed_reg = niak_build_tseries(tseries_smooth,prior_regular_vec,opt_t);
    tseed_reg = niak_normalize_tseries(tseed_reg);
    tseries_dual = niak_normalize_tseries(tseries_smooth);
    beta_reg = niak_lse(tseries_dual,tseed_reg);
    dureg_reg_corner = reshape(beta_reg(corner_net, :), [edge, edge]);
    dureg_reg_border = reshape(beta_reg(border_net, :), [edge, edge]);
    
    tseed_shift = niak_build_tseries(tseries_smooth,prior_shift_vec,opt_t);
    tseed_shift = niak_normalize_tseries(tseed_shift);
    tseries_dual = niak_normalize_tseries(tseries_smooth);
    beta_shift = niak_lse(tseries_dual,tseed_shift);
    dureg_shift_corner = reshape(beta_shift(corner_net, :), [edge, edge]);
    dureg_shift_border = reshape(beta_shift(border_net, :), [edge, edge]);
    
    %% Run the matlab ROC analysis
    %% Shifted Prior
    [X_scores_b_shift, roc_scores_b_shift, ~, AUC_scores_b_shift] = perfcurve(border_regular_labels, scores_shift_border(:), true);
    [X_seed_b_shift, roc_seed_b_shift, ~, AUC_seed_b_shift] = perfcurve(border_regular_labels, seed_shift_border(:), true);
    [X_dureg_b_shift, roc_dureg_b_shift, ~, AUC_dureg_b_shift] = perfcurve(border_regular_labels, dureg_shift_border(:), true);
    
    [X_scores_c_shift, roc_scores_c_shift, ~, AUC_scores_c_shift] = perfcurve(corner_regular_labels, scores_shift_corner(:), true);
    [X_seed_c_shift, roc_seed_c_shift, ~, AUC_seed_c_shift] = perfcurve(corner_regular_labels, seed_shift_corner(:), true);
    [X_dureg_c_shift, roc_dureg_c_shift, ~, AUC_dureg_c_shift] = perfcurve(corner_regular_labels, dureg_shift_corner(:), true);
    
    fpr_cell{s_id,1} = X_scores_b_shift;
    tpr_cell{s_id,1} = roc_scores_b_shift;
    
    fpr_cell{s_id,2} = X_seed_b_shift;
    tpr_cell{s_id,2} = roc_seed_b_shift;
    
    fpr_cell{s_id,3} = X_dureg_b_shift;
    tpr_cell{s_id,3} = roc_dureg_b_shift;
    %% Run a manual ROC analysis
    vec = scores_shift_border(:);
    u_val = unique(vec);
    n_val = length(u_val);
    
    true_pos = zeros(n_val+1, 1);
    false_pos = zeros(n_val+1, 1);
    P = sum(border_regular_labels);
    N = sum(~border_regular_labels);
    
    for v_id = 2:n_val
        thresh = u_val(v_id);
        pass_thr = vec > thresh;
        TP = sum(pass_thr(border_regular_labels));
        FP = sum(pass_thr(~border_regular_labels));
        tpr = TP / P;
        fpr = FP / N;
        true_pos(v_id) = tpr;
        false_pos(v_id) = fpr;
    end
    true_pos(1) = 1;
    tpr_cell{s_id,1} = true_pos;
    false_pos(1) = 1;
    fpr_cell{s_id,1} = false_pos;
    
end

cc=jet(n_shifts);
labels = cellstr(num2str((shifts'*100)/n_edge, 'shift by %.1f %%'));
labels{end+1} = 'chance';
% Show ROC
f1 = figure('position',[0 0 1200 600]);
subplot(1,2,1);
hold on;
for s_id = 1:n_shifts
    plot(fpr_cell{s_id,1}, tpr_cell{s_id,1}, 'color', cc(s_id,:));
end
plot(linspace(0,1,10), linspace(0,1,10), 'color', 'k');
hold off;
title('manual');
legend(labels, 'Location', 'southeast');
axis([0 1 0 1]);

subplot(1,2,2);
hold on;
for s_id = 1:n_shifts
    plot(fpr_cell{s_id,2}, tpr_cell{s_id,2}, 'color',cc(s_id,:));
end
plot(linspace(0,1,10), linspace(0,1,10),'color', 'k');
hold off;
title('matlab');
legend(labels, 'Location', 'southeast');
set(f1,'PaperPositionMode','auto');
print(f1, sprintf('roc_dureg_comparison_edge_%d.png', edge), '-dpng');

% Show maps
% f2 = figure('position',[0 0 1200 400]);
% subplot(1,3,1);
% imagesc(scores_shift_border);
% grid on;
% set(gca,'XTick',linspace(0,edge,5), 'YTick', linspace(0,edge,5));
% title('scores');
% colormap('cool')
% 
% subplot(1,3,2);
% imagesc(dureg_shift_border);
% grid on;
% set(gca,'XTick',linspace(0,edge,5), 'YTick', linspace(0,edge,5));
% title('dual regression');
% colormap('cool')
% 
% subplot(1,3,3);
% imagesc(reshape(border_regular_labels, [edge, edge]));
% grid on;
% set(gca,'XTick',linspace(0,edge,5), 'YTick', linspace(0,edge,5));
% title('true signal');
% colormap('cool')
% set(f2,'PaperPositionMode','auto');
% print(f2, sprintf('map_dureg_comparison_edge_%d.png', edge), '-dpng');