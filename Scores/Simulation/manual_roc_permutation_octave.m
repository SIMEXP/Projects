clear all; close all;
%% Make the signal for smooth and shifted prior
edge = 64;
shifts = [4 8 16 20];
n_shifts = length(shifts);
n_edge = edge/4;
shift = 6;
corner_net = 1;
border_net = 6;

opt_s.type = 'checkerboard';
opt_s.t = 100;
opt_s.n = edge*edge;
opt_s.nb_clusters = [4 16];
opt_s.variance = 0.3;
opt_s.fwhm = 5;
[tseries_smooth,opt_mplm] = niak_simus_scenario(opt_s);
prior_regular_vec = opt_mplm.space.mpart{2};
prior_regular = reshape(prior_regular_vec, [edge, edge]);

n_perm = 2;
ref_x = linspace(0,1,opt_s.n+1);

%% Make the priors
prior_shift = circshift(prior_regular, [shift shift]);
prior_shift_vec = reshape(prior_shift, [dot(edge, edge), 1]);

%% Make the labels for ROC
corner_regular_labels = prior_regular==corner_net;
corner_regular_labels = corner_regular_labels(:);

border_regular_labels = prior_regular==border_net;
border_regular_labels = border_regular_labels(:);

tpr_cell = {n_shifts,3};
fpr_cell = {n_shifts,3};
for s_id = 1:n_shifts
    fprintf('Iterating through number %d\n', s_id);
    shift = shifts(s_id);
    
    tpr_temp = zeros(n_perm, opt_s.n+1, 3);
    fpr_temp = zeros(n_perm, opt_s.n+1, 3);
    for p_id = 1:n_perm
        fprintf('   perm %d\n', p_id);
        %% Run the analysis
        [tseries_smooth,~] = niak_simus_scenario(opt_s);
        %% Scores
        opt_scores.sampling.type = 'bootstrap';
        opt_scores.sampling.opt = opt_s;
        opt_scores.flag_verbose = false;
%         %# Scores with correct prior
%         res_scores_reg = niak_stability_cores(tseries_smooth,prior_regular_vec,opt_scores);
%         scores_reg_corner = reshape(res_scores_reg.stab_maps(:, corner_net), [edge, edge]);
%         scores_reg_border = reshape(res_scores_reg.stab_maps(:, border_net), [edge, edge]);
        %# Scores with bad prior
        res_scores_shift = niak_stability_cores(tseries_smooth,prior_shift_vec,opt_scores);
        scores_shift_corner = reshape(res_scores_shift.stab_maps(:, corner_net), [edge, edge]);
        scores_shift_border = reshape(res_scores_shift.stab_maps(:, border_net), [edge, edge]);

        %% Seed
        opt_t.type_center = 'mean';
        opt_t.correction = 'mean_var';
%         tseed_reg = niak_build_tseries(tseries_smooth,prior_regular_vec,opt_t);
%         seed_tmp_reg = niak_fisher(corr(tseries_smooth,tseed_reg))';
%         seed_reg_corner = reshape(seed_tmp_reg(corner_net, :), [edge, edge]);
%         seed_reg_border = reshape(seed_tmp_reg(border_net, :), [edge, edge]);


        tseed_shift = niak_build_tseries(tseries_smooth,prior_shift_vec,opt_t);
        seed_tmp_shift = niak_fisher(corr(tseries_smooth,tseed_shift))';
        seed_shift_corner = reshape(seed_tmp_shift(corner_net, :), [edge, edge]);
        seed_shift_border = reshape(seed_tmp_shift(border_net, :), [edge, edge]);
        %% Dual Regression
        opt_t.type_center = 'mean';
        opt_t.correction = 'mean_var';
%         tseed_reg = niak_build_tseries(tseries_smooth,prior_regular_vec,opt_t);
%         tseed_reg = niak_normalize_tseries(tseed_reg);
%         tseries_dual = niak_normalize_tseries(tseries_smooth);
%         beta_reg = niak_lse(tseries_dual,tseed_reg);
%         dureg_reg_corner = reshape(beta_reg(corner_net, :), [edge, edge]);
%         dureg_reg_border = reshape(beta_reg(border_net, :), [edge, edge]);

        tseed_shift = niak_build_tseries(tseries_smooth,prior_shift_vec,opt_t);
        tseed_shift = niak_normalize_tseries(tseed_shift);
        tseries_dual = niak_normalize_tseries(tseries_smooth);
        beta_shift = niak_lse(tseries_dual,tseed_shift);
        dureg_shift_corner = reshape(beta_shift(corner_net, :), [edge, edge]);
        dureg_shift_border = reshape(beta_shift(border_net, :), [edge, edge]);

        %% Run the matlab ROC analysis
        %% Shifted Prior
        [X_scores_b_shift, roc_scores_b_shift] = roc(border_regular_labels, scores_shift_border(:), true);
        [X_seed_b_shift, roc_seed_b_shift] = roc(border_regular_labels, seed_shift_border(:), true);
        [X_dureg_b_shift, roc_dureg_b_shift] = roc(border_regular_labels, dureg_shift_border(:), true);

%        [X_scores_c_shift, roc_scores_c_shift] = roc(corner_regular_labels, scores_shift_corner(:), true);
%        [X_seed_c_shift, roc_seed_c_shift] = roc(corner_regular_labels, seed_shift_corner(:), true);
%        [X_dureg_c_shift, roc_dureg_c_shift] = roc(corner_regular_labels, dureg_shift_corner(:), true);

        % Interpolate stuff into 1025
        % There may be warnings because of multiple overlapping fpr values
        y_scores = interp1(X_scores_b_shift, roc_scores_b_shift, ref_x);
        y_seed = interp1(X_seed_b_shift, roc_seed_b_shift, ref_x);
        y_dureg = interp1(X_dureg_b_shift, roc_dureg_b_shift, ref_x);
        
        tpr_tmp(p_id, :, 1) = y_scores;
        tpr_tmp(p_id, :, 2) = y_seed;
        tpr_tmp(p_id, :, 3) = y_dureg;
        
%        fpr_cell(p_id, :, 1) = X_scores_c_shift;
%        fpr_cell(p_id, :, 2) = X_seed_c_shift;
%        fpr_cell(p_id, :, 3) = X_dureg_c_shift;
    
    end
    tpr_cell{s_id,1} = mean(tpr_tmp(:,:,1), 1);
    tpr_cell{s_id,2} = mean(tpr_tmp(:,:,2), 1);
    tpr_cell{s_id,3} = mean(tpr_tmp(:,:,3), 1);
end

cc=jet(n_shifts);
labels = cellstr(num2str((shifts'*100)/n_edge, 'shift by %.1f %%'));
labels{end+1} = 'chance';
% Show ROC
f1 = figure('position',[0 0 1200 600]);
subplot(1,3,1);
hold on;
for s_id = 1:n_shifts
    plot(ref_x, tpr_cell{s_id,1}, 'color', cc(s_id,:));
end
plot(linspace(0,1,10), linspace(0,1,10), 'color', 'k');
hold off;
title('scores');
legend(labels, 'Location', 'southeast');
axis([0 1 0 1]);

subplot(1,3,2);
hold on;
for s_id = 1:n_shifts
    plot(ref_x, tpr_cell{s_id,2}, 'color',cc(s_id,:));
end
plot(linspace(0,1,10), linspace(0,1,10),'color', 'k');
hold off;
title('seed');
legend(labels, 'Location', 'southeast');
axis([0 1 0 1]);

subplot(1,3,3);
hold on;
for s_id = 1:n_shifts
    plot(ref_x, tpr_cell{s_id,3}, 'color',cc(s_id,:));
end
plot(linspace(0,1,10), linspace(0,1,10),'color', 'k');
hold off;
title('dual regression');
legend(labels, 'Location', 'southeast');
axis([0 1 0 1]);

set(f1,'PaperPositionMode','auto');
print(f1, sprintf('roc_comparison_edge_%d_all_perm.png', edge), '-dpng');