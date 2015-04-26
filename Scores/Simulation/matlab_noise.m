clear all; close all;
%% Set the settings
fig_path = '/home/surchs/Code/Projects/Scores/Simulation/figures/noise';
psom_mkdir(fig_path);

edge = 64;
n_edge = edge/4;
corner_net = 1;
border_net = 6;
ref_net1 = 2;
ref_net2 = 5;
n_perm = 100;

noise_levels = [0.1, 0.05, 0.001];

opt_s.type = 'checkerboard';
opt_s.t = 100;
opt_s.n = edge*edge;
opt_s.nb_clusters = [4 16];
opt_s.fwhm = 4;

opt_scores.sampling.type = 'bootstrap';
opt_scores.sampling.opt = opt_s;

n_ref = 100;
ref_fpr = linspace(0,1,n_ref);
ref_thr = linspace(-1,1,n_ref);

%% Dry run to get the priors
[tseries,opt_mplm] = niak_simus_scenario(opt_s);
% Get the priors
prior_true_vec = opt_mplm.space.mpart{2};
prior_true = reshape(prior_true_vec, [edge, edge]);

corner_true_labels = prior_true==corner_net;
corner_true_labels = corner_true_labels(:);

border_true_labels = prior_true==border_net;
border_true_labels = border_true_labels(:);

opt_scores.flag_verbose = false;

%% Prepare the storage
% For the maps
scores_clean = zeros(edge*edge, 3, n_perm);
seed_clean = zeros(edge*edge, 3, n_perm);
dureg_clean = zeros(edge*edge, 3, n_perm);

scores_tpr_store = zeros(n_ref, 3, n_perm);
scores_thr_store = zeros(n_ref, 2, 3, n_perm);
scores_auc_store = zeros(3, n_perm);

seed_tpr_store = zeros(n_ref, 3, n_perm);
seed_thr_store = zeros(n_ref, 2, 3, n_perm);
seed_auc_store = zeros(3, n_perm);

dureg_tpr_store = zeros(n_ref, 3, n_perm);
dureg_thr_store = zeros(n_ref, 2, 3, n_perm);
dureg_auc_store = zeros(3, n_perm);

%% Iterate
for n_id = 1:3
    % Noise
    noise = noise_levels(n_id);
    
    opt_s.variance = noise;
    fprintf('Running noise %.3f \n', noise);
    
    for i_id = 1:n_perm
        fprintf('    permutation %d\n', i_id);
        %% Now generate the simulated signal
        [tseries,opt_mplm] = niak_simus_scenario(opt_s);
        
        %% Run methods without the noise
        %% Scores
        opt_scores.flag_target = false;
        res_scores = niak_stability_cores(tseries,prior_true_vec,opt_scores);
        scores_corner = res_scores.stab_maps(:, corner_net);
        [scores_fpr, scores_tpr, scores_thr, scores_auc] = perfcurve(corner_true_labels, scores_corner, true);
        % Append -1 and 1 to the threshold and fix the fpr and tpr
        % values so the interpolation doesn't fuck it up
        scores_thr = [1; scores_thr; -1];
        scores_fpr = [0; scores_fpr; 1];
        scores_tpr = [0; scores_tpr; 1];
        % Interpolate thr
        [~, scores_tpr_t] = clean_dupl(scores_thr, scores_tpr);
        [scores_thr_t, scores_fpr_t] = clean_dupl(scores_thr, scores_fpr);
        scores_tpr_tint = interp1(scores_thr_t, scores_tpr_t, ref_thr, 'linear', 'extrap');
        scores_fpr_tint = interp1(scores_thr_t, scores_fpr_t, ref_thr, 'linear', 'extrap');
        % Clean up duplicates and interpolate fpr
        [scores_fpr, scores_tpr] = clean_dupl(scores_fpr, scores_tpr);
        scores_tpr_fint = interp1(scores_fpr, scores_tpr, ref_fpr);
        % Store the results
        scores_tpr_store(:, n_id, i_id) = scores_tpr_fint;
        scores_thr_store(:, 1, n_id, i_id) = scores_tpr_tint;
        scores_thr_store(:, 2, n_id, i_id) = scores_fpr_tint;
        scores_auc_store(n_id, i_id) = scores_auc;
        % Store the maps also
        scores_clean(:,n_id) = scores_clean(:,n_id) + scores_corner;
        %% Seed
        opt_t.type_center = 'mean';
        opt_t.correction = 'mean_var';
        tseed = niak_build_tseries(tseries,prior_true_vec,opt_t);
        seed_tmp = niak_fisher(corr(tseries,tseed))';
        seed_map = seed_tmp(corner_net, :);
        [seed_fpr, seed_tpr, seed_thr, seed_auc] = perfcurve(corner_true_labels, seed_map, true);
        % Append -1 and 1 to the threshold and fix the fpr and tpr
        % values so the interpolation doesn't fuck it up
        seed_thr = [1; seed_thr; -1];
        seed_fpr = [0; seed_fpr; 1];
        seed_tpr = [0; seed_tpr; 1];
        % Interpolate thr
        [~, seed_tpr_t] = clean_dupl(seed_thr, seed_tpr);
        [seed_thr_t, seed_fpr_t] = clean_dupl(seed_thr, seed_fpr);
        seed_tpr_tint = interp1(seed_thr_t, seed_tpr_t, ref_thr, 'linear', 'extrap');
        seed_fpr_tint = interp1(seed_thr_t, seed_fpr_t, ref_thr, 'linear', 'extrap');
        % Interpolate fpr
        [seed_fpr, seed_tpr] = clean_dupl(seed_fpr, seed_tpr);
        seed_tpr_fint = interp1(seed_fpr, seed_tpr, ref_fpr);
        % Store the results
        seed_tpr_store(:, n_id, i_id) = seed_tpr_fint;
        seed_thr_store(:, 1, n_id, i_id) = seed_tpr_tint;
        seed_thr_store(:, 2, n_id, i_id) = seed_fpr_tint;
        seed_auc_store(n_id, i_id) = seed_auc;
        % Store the maps also
        seed_clean(:,n_id) = seed_clean(:,n_id) + seed_map';
        %% Dual Regression
        opt_t.type_center = 'mean';
        opt_t.correction = 'mean_var';
        tseed = niak_build_tseries(tseries,prior_true_vec,opt_t);
        tseed = niak_normalize_tseries(tseed);
        tseries_dual = niak_normalize_tseries(tseries);
        beta = niak_lse(tseries_dual,tseed);
        % Get corner for ROC
        dureg_corner = beta(corner_net, :);
        [dureg_fpr, dureg_tpr, dureg_thr, dureg_auc] = perfcurve(corner_true_labels, dureg_corner, true);
        % Append -1 and 1 to the threshold and fix the fpr and tpr
        % values so the interpolation doesn't fuck it up
        dureg_thr = [1; dureg_thr; -1];
        dureg_fpr = [0; dureg_fpr; 1];
        dureg_tpr = [0; dureg_tpr; 1];
        % Interpolate thr
        [~, dureg_tpr_t] = clean_dupl(dureg_thr, dureg_tpr);
        [dureg_thr_t, dureg_fpr_t] = clean_dupl(dureg_thr, dureg_fpr);
        dureg_tpr_tint = interp1(dureg_thr_t, dureg_tpr_t, ref_thr, 'linear', 'extrap');
        dureg_fpr_tint = interp1(dureg_thr_t, dureg_fpr_t, ref_thr, 'linear', 'extrap');
        % Interpolate fpr
        [dureg_fpr, dureg_tpr] = clean_dupl(dureg_fpr, dureg_tpr);
        dureg_tpr_fint = interp1(dureg_fpr, dureg_tpr, ref_fpr);
        % Store the results
        dureg_tpr_store(:, n_id, i_id) = dureg_tpr_fint;
        dureg_thr_store(:, 1, n_id, i_id) = dureg_tpr_tint;
        dureg_thr_store(:, 2, n_id, i_id) = dureg_fpr_tint;
        dureg_auc_store(n_id, i_id) = dureg_auc;
        % Store the maps also
        dureg_clean(:,n_id) = dureg_clean(:,n_id) + dureg_corner';
    end
end
stab_clean_avg = scores_clean/n_perm;
seed_clean_avg = seed_clean/n_perm;
dureg_clean_avg = dureg_clean/n_perm;

save([fig_path filesep 'auc_store.mat'], 'scores_auc_store', 'seed_auc_store', 'dureg_auc_store');

%% Plot the ROC curves as a function of noise levels
f_roc = figure('position',[0 0 1000 400]);
for n_id = 1:3
    noise = noise_levels(n_id);
    subplot(1,3,n_id);
    hold on;
    % scores
    plot(ref_fpr, mean(squeeze(scores_tpr_store(:, n_id, :)),2), 'g');
    scores_auc = mean(scores_auc_store(n_id, :));
    if n_id == 1
        ylabel('TPR');
    end
    xlabel('FPR');
    % seed
    plot(ref_fpr, mean(squeeze(seed_tpr_store(:, n_id, :)),2), 'r');
    seed_auc = mean(seed_auc_store(n_id, :));
    xlabel('FPR');
    % dureg
    plot(ref_fpr, mean(squeeze(dureg_tpr_store(:, n_id, :)),2), 'b');
    dureg_auc = mean(dureg_auc_store(n_id, :));
    xlabel('FPR');
    % labels
    labels = {sprintf('scores (%.3f)', scores_auc), sprintf('seed (%.3f)', seed_auc), sprintf('dual regression (%.3f)', dureg_auc)};
    title(sprintf('SNR %.3f', noise));
    legend(labels, 'Location', 'southeast');
end

set(f_roc, 'PaperPositionMode','auto');
print(f_roc, [fig_path filesep 'roc_overview.png'], '-dpng');

%% Plot the AUC bars with standard deviation
% Combine them all into one big plot
f_auc = figure('position',[0 0 1000 400]);
auc_all = [mean(scores_auc_store, 2), mean(seed_auc_store, 2), mean(dureg_auc_store, 2)];
std_all = [std(scores_auc_store,[], 2), std(seed_auc_store,[], 2), std(dureg_auc_store,[], 2)];
barwitherr(std_all, auc_all);
legend({'scores', 'seed', 'dual regression'}, 'Location', 'eastoutside');
title('AUC over different SNR levels');
set(gca,'xlim',[0 4],'ylim', [0.5 1], 'XTickLabel', cellstr(num2str(noise_levels')));
xlabel('SNR');
ylabel('AUC');

set(f_auc, 'PaperPositionMode','auto');
print(f_auc, [fig_path filesep 'auc_overview.png'], '-dpng');

%% Mass-Univariate Ttest of AUC
[t1, p1, m1, s1, d1] = niak_ttest(scores_auc_store', seed_auc_store', true);
% 2 scores-dureg
[t2, p2, m2, s2, d2] = niak_ttest(scores_auc_store', dureg_auc_store', true);
% 3 seed-dureg
[t3, p3, m3, s3, d3] = niak_ttest(seed_auc_store', dureg_auc_store', true);

% Add the pooled variance
sp1 = ( (( n_perm - 1) .* std(scores_auc_store,[],2)) + (( n_perm - 1) .* std(seed_auc_store,[],2))) / (n_perm + n_perm -2);
sp2 = ( (( n_perm - 1) .* std(scores_auc_store,[],2)) + (( n_perm - 1) .* std(dureg_auc_store,[],2))) / (n_perm + n_perm -2);
sp3 = ( (( n_perm - 1) .* std(seed_auc_store,[],2)) + (( n_perm - 1) .* std(dureg_auc_store,[],2))) / (n_perm + n_perm -2);
% Compute Cohensd
chd1 = m1 ./ sp1;
chd2 = m2 ./ sp2;
chd3 = m3 ./ sp3;

% Bonferroni correction
q = 0.01;
p = [p1; p2; p3];
p_mask = p < q/numel(p);
ch = [chd1; chd2; chd3];
% The organization of these things is tests in rows and noise in columns


%% Show the maps for the different methods and noise levels
f_maps = figure('position',[0 0 1000 800]);

opt_v.limits = [-1 1];
opt_v.color_map = niak_hot_cold;
pos_mat = reshape(1:9, [3 3]);

% Generate the 2D label for an overlay
label_mask = prior_true==1;
[x, y] = find(label_mask);
pos_vec = [min(y), min(x), n_edge, n_edge];
for n_id = 1:3
    noise = noise_levels(n_id);
    % Get the values
    % Scores
    scores_map = reshape(stab_clean_avg(:, n_id), [edge, edge]);
    % Seed
    seed_map = reshape(seed_clean_avg(:, n_id), [edge, edge]);
    % Dual Regression
    dureg_map = reshape(dureg_clean_avg(:, n_id), [edge, edge]);
    
    % Plot things
    % Scores
    pos = pos_mat(1, n_id);
    subplot(3,3, pos);
    niak_visu_matrix(scores_map, opt_v);
    rectangle('Position', pos_vec, 'EdgeColor','w','LineWidth',1);
    set(gca,'XTickLabel', [], 'YTickLabel', []);
    ylabel(sprintf('SNR %.3f', noise));
    if n_id == 1
        title('Scores');
    end
    
    % Seed
    pos = pos_mat(2, n_id);
    subplot(3,3, pos);
    niak_visu_matrix(seed_map, opt_v);
    rectangle('Position', pos_vec, 'EdgeColor','w','LineWidth',1);
    set(gca,'XTickLabel', [], 'YTickLabel', []);
    if n_id == 1
        title('Seed');
    end
    
    % Dureg
    pos = pos_mat(3, n_id);
    subplot(3,3, pos);
    niak_visu_matrix(dureg_map, opt_v);
    rectangle('Position', pos_vec, 'EdgeColor','w','LineWidth',1);
    set(gca,'XTickLabel', [], 'YTickLabel', []);
    if n_id == 1
        title('Dual Regression');
    end
end
suptitle('Corner network maps across different SNR levels');

set(f_maps, 'PaperPositionMode','auto');
print(f_maps, [fig_path filesep 'average_maps.png'], '-dpng');

%% Plot the FPR and TPR curves over the thresholds
f_thr = figure('position',[0 0 1500 1000]);
pos_mat = reshape(1:9, [3 3]);

for n_id = 1:3
    noise = noise_levels(n_id);
    
    % Get the values
    % scores
    scores_tpr = mean(squeeze(scores_thr_store(:, 1, n_id, :)),2);
    scores_fpr = mean(squeeze(scores_thr_store(:, 2, n_id, :)),2);
    scores_ab = (trapz(ref_thr, scores_tpr) - trapz(ref_thr, scores_fpr))/2;
    % seed
    seed_tpr = mean(squeeze(seed_thr_store(:, 1, n_id, :)),2);
    seed_fpr = mean(squeeze(seed_thr_store(:, 2, n_id, :)),2);
    seed_ab = (trapz(ref_thr, seed_tpr) - trapz(ref_thr, seed_fpr))/2;
    % dureg
    dureg_tpr = mean(squeeze(dureg_thr_store(:, 1, n_id, :)),2);
    dureg_fpr = mean(squeeze(dureg_thr_store(:, 2, n_id, :)),2);
    dureg_ab = (trapz(ref_thr, dureg_tpr) - trapz(ref_thr, dureg_fpr))/2;
            
    % Plot things
    % Scores
    pos = pos_mat(1, n_id);
    subplot(3,3, pos);
    hold on;
    % Generate filled area
    X = [ref_thr, fliplr(ref_thr)];
    Y = [scores_fpr', fliplr(scores_tpr')];
    h = fill(X, Y, 'b');
    plot(ref_thr, scores_tpr, 'g');
    plot(ref_thr, scores_fpr, 'r');
    hold off;
    legend({'TPR', 'FPR', sprintf('TPR-FPR (%.3f)', scores_ab)}, 'Location', 'southwest');
    if n_id == 1
        title('Scores');
    elseif n_id == 3
        xlabel('threshold');
    end
    ylabel(sprintf('SNR %.3f', noise));
    
    % Seed
    pos = pos_mat(2, n_id);
    subplot(3,3, pos);
    hold on;
    % Generate filled area
    X = [ref_thr, fliplr(ref_thr)];
    Y = [seed_fpr', fliplr(seed_tpr')];
    h = fill(X, Y, 'b');
    plot(ref_thr, seed_tpr, 'g');
    plot(ref_thr, seed_fpr, 'r');
    hold off;
    legend({'TPR', 'FPR', sprintf('TPR-FPR (%.3f)', seed_ab)}, 'Location', 'southwest');
    if n_id == 1
        title('Seed');
    elseif n_id == 3
        xlabel('threshold');
    end
    
    % Dual Regression
    pos = pos_mat(3, n_id);
    subplot(3,3, pos);
    hold on;
    % Generate filled area
    X = [ref_thr, fliplr(ref_thr)];
    Y = [dureg_fpr', fliplr(dureg_tpr')];
    h = fill(X, Y, 'b');
    plot(ref_thr, dureg_tpr, 'g');
    plot(ref_thr, dureg_fpr, 'r');
    hold off;
    legend({'TPR', 'FPR', sprintf('TPR-FPR (%.3f)', dureg_ab)}, 'Location', 'southwest');
    if n_id == 1
        title('Dual Regression');
    elseif n_id == 3
        xlabel('threshold');
    end
end

set(f_thr, 'PaperPositionMode','auto');
print(f_thr, [fig_path filesep 'tprfpr_surface.png'], '-dpng');