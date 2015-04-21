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
n_perm = 2;

noise_levels = [0.01, 0.1, 1];
smooth_levels = [4, 8, 16];

opt_s.type = 'checkerboard';
opt_s.t = 100;
opt_s.n = edge*edge;
opt_s.nb_clusters = [4 16];
opt_s.variance = 0.1;
opt_s.fwhm = 2;

opt_scores.sampling.type = 'bootstrap';
opt_scores.sampling.opt = opt_s;

n_ref = 100;
ref_fpr = linspace(-1,1,n_ref);
ref_thr = linspace(-1,1,n_ref);

%% Dry run to get the priors
[tseries,opt_mplm] = niak_simus_scenario(opt_s);
% Get the priors
prior_regular_vec = opt_mplm.space.mpart{2};
prior_regular = reshape(prior_regular_vec, [edge, edge]);

corner_regular_labels = prior_regular==corner_net;
corner_regular_labels = corner_regular_labels(:);

border_regular_labels = prior_regular==border_net;
border_regular_labels = border_regular_labels(:);

opt_scores.flag_verbose = false;

%% Prepare the storage
% For the maps
scores_clean = zeros(edge*edge, 3, 3, n_perm);
seed_clean = zeros(edge*edge, 3, 3, n_perm);
dureg_clean = zeros(edge*edge, 3, 3, n_perm);

scores_tpr_store = zeros(n_ref, 3, 3, n_perm);
scores_thr_store = zeros(n_ref, 2, 3, 3, n_perm);
scores_auc_store = zeros(3, 3, n_perm);

seed_tpr_store = zeros(n_ref, 3, 3, n_perm);
seed_thr_store = zeros(n_ref, 2, 3, 3, n_perm);
seed_auc_store = zeros(3, 3, n_perm);

dureg_tpr_store = zeros(n_ref, 3, 3, n_perm);
dureg_thr_store = zeros(n_ref, 2, 3, 3, n_perm);
dureg_auc_store = zeros(3, 3, n_perm);

%% Iterate
for n_id = 1:3
    % Noise
    noise = noise_levels(n_id);
    for s_id = 1:3
        % Smoothing
        smooth = smooth_levels(s_id);
        opt_s.variance = noise;
        opt_s.fwhm = smooth;
        fprintf('Running noise %.3f smoothing %d\n', noise, smooth);
        
        for i_id = 1:n_perm
            fprintf('    permutation %d\n', i_id);
            %% Now generate the simulated signal
            [tseries,opt_mplm] = niak_simus_scenario(opt_s);

            %% Run methods without the noise
            %% Scores
            opt_scores.flag_target = false;
            res_scores = niak_stability_cores(tseries,prior_regular_vec,opt_scores);
            scores_corner = res_scores.stab_maps(:, corner_net);
            [scores_fpr, scores_tpr, scores_thr, scores_auc] = perfcurve(corner_regular_labels, scores_corner, true);
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
            scores_tpr_store(:, n_id, s_id, i_id) = scores_tpr_fint;
            scores_thr_store(:, 1, n_id, s_id, i_id) = scores_tpr_tint;
            scores_thr_store(:, 2, n_id, s_id, i_id) = scores_fpr_tint;
            scores_auc_store(n_id, s_id, i_id) = scores_auc;
            % Store the maps also
            scores_clean(:,n_id, s_id) = scores_clean(:,n_id, s_id) + scores_corner;
            %% Seed
            opt_t.type_center = 'mean';
            opt_t.correction = 'mean_var';
            tseed = niak_build_tseries(tseries,prior_regular_vec,opt_t);
            seed_tmp = niak_fisher(corr(tseries,tseed))';
            seed_corner = seed_tmp(corner_net, :);
            [seed_fpr, seed_tpr, seed_thr, seed_auc] = perfcurve(corner_regular_labels, seed_corner, true);
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
            seed_tpr_store(:, n_id, s_id, i_id) = seed_tpr_fint;
            seed_thr_store(:, 1, n_id, s_id, i_id) = seed_tpr_tint;
            seed_thr_store(:, 2, n_id, s_id, i_id) = seed_fpr_tint;
            seed_auc_store(n_id, s_id, i_id) = seed_auc;
            % Store the maps also
            seed_clean(:,n_id, s_id) = seed_clean(:,n_id, s_id) + seed_corner';
            %% Dual Regression
            opt_t.type_center = 'mean';
            opt_t.correction = 'mean_var';
            tseed = niak_build_tseries(tseries,prior_regular_vec,opt_t);
            tseed = niak_normalize_tseries(tseed);
            tseries_dual = niak_normalize_tseries(tseries);
            beta = niak_lse(tseries_dual,tseed);
            % Get corner for ROC
            dureg_corner = beta(corner_net, :);
            [dureg_fpr, dureg_tpr, dureg_thr, dureg_auc] = perfcurve(corner_regular_labels, dureg_corner, true);
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
            dureg_tpr_store(:, n_id, s_id, i_id) = dureg_tpr_fint;
            dureg_thr_store(:, 1, n_id, s_id, i_id) = dureg_tpr_tint;
            dureg_thr_store(:, 2, n_id, s_id, i_id) = dureg_fpr_tint;
            dureg_auc_store(n_id, s_id, i_id) = dureg_auc;
            % Store the maps also
            dureg_clean(:,n_id, s_id) = dureg_clean(:,n_id, s_id) + dureg_corner';
        end
    end
end
stab_clean_avg = scores_clean/n_perm;
seed_clean_avg = seed_clean/n_perm;
dureg_clean_avg = dureg_clean/n_perm;

%% Visualize the findings separately for the different methods
%% Get the results out
f_scores = figure(1);
f_seed = figure(2);
f_dureg = figure(3);
pos_mat = reshape(1:9, [3 3])';

opt_v.limits = [-1 1];
opt_v.color_map = niak_hot_cold;
for n_id = 1:3
    for s_id = 1:3
        % Get the values
        % Scores
        scores_corner = reshape(stab_clean_avg(:, corner_net, n_id, s_id), [edge, edge]);
        scores_border = reshape(stab_clean_avg(:, border_net, n_id, s_id), [edge, edge]);
        scores_ref1 = reshape(stab_clean_avg(:, ref_net1, n_id, s_id), [edge, edge]);
        scores_ref2 = reshape(stab_clean_avg(:, ref_net2, n_id, s_id), [edge, edge]);
        
        % Seed
        seed_corner = reshape(seed_clean_avg(corner_net, :, n_id, s_id), [edge, edge]);
        seed_border = reshape(seed_clean_avg(border_net, :, n_id, s_id), [edge, edge]);
        seed_ref1 = reshape(seed_clean_avg(ref_net1, :, n_id, s_id), [edge, edge]);
        seed_ref2 = reshape(seed_clean_avg(ref_net2, :, n_id, s_id), [edge, edge]);
        
        % Dual Regression
        dureg_corner = reshape(dureg_clean_avg(corner_net, :, n_id, s_id), [edge, edge]);
        dureg_border = reshape(dureg_clean_avg(border_net, :, n_id, s_id), [edge, edge]);
        dureg_ref1 = reshape(dureg_clean_avg(ref_net1, :, n_id, s_id), [edge, edge]);
        dureg_ref2 = reshape(dureg_clean_avg(ref_net2, :, n_id, s_id), [edge, edge]);
        
        % Plot things
        % Scores
        figure(f_scores);
        pos = pos_mat(n_id, s_id);
        subplot(3,3,pos);
        niak_visu_matrix(scores_corner, opt_v);
        if s_id == 1
            ylabel(sprintf('noise %.3f', noise_levels(n_id)));
        end
        if n_id == 1
            title(sprintf('smooth %d', smooth_levels(s_id)));
        end
        
        % Seed
        figure(f_seed);
        pos = pos_mat(n_id, s_id);
        subplot(3,3,pos);
        niak_visu_matrix(seed_corner, opt_v);
        if s_id == 1
            ylabel(sprintf('noise %.3f', noise_levels(n_id)));
        end
        if n_id == 1
            title(sprintf('smooth %d', smooth_levels(s_id)));
        end
        
        % Dureg
        figure(f_dureg);
        pos = pos_mat(n_id, s_id);
        subplot(3,3,pos);
        niak_visu_matrix(dureg_corner, opt_v);
        if s_id == 1
            ylabel(sprintf('noise %.3f', noise_levels(n_id)));
        end
        if n_id == 1
            title(sprintf('smooth %d', smooth_levels(s_id)));
        end
        
    end
end
figure(f_scores);
suptitle('Scores');
figure(f_seed);
suptitle('Seed');
figure(f_dureg);
suptitle('Dual Regression');

%% Show it
% Show the effect of noise on 
f1 = figure('position',[0 0 1200 600]);
subplot(2,2,1);
niak_visu_matrix(scores_corner_d);
subplot(2,2,2);
niak_visu_matrix(scores_ref1_d);
subplot(2,2,3);
niak_visu_matrix(scores_ref2_d);
subplot(2,2,4);
niak_visu_matrix(scores_border_d);
print(f1, 'diagonal_noise_simulation.png', '-dpng');
set(f1,'PaperPositionMode','auto');
print(f1, [fig_path filesep 'clean.png'], '-dpng');

%% Plot a noise and non-noise network for the three methods
f2 = figure('position',[0 0 1200 600]);
opt_v = struct;
opt_v.limits = [-1 1];
subplot(2,3,1);
niak_visu_matrix(scores_corner_d, opt_v);
subplot(2,3,2);
niak_visu_matrix(seed_corner_d, opt_v);
subplot(2,3,3);
niak_visu_matrix(dureg_corner_d, opt_v);
subplot(2,3,4);
niak_visu_matrix(scores_ref2_d, opt_v);
subplot(2,3,5);
niak_visu_matrix(seed_ref2_d, opt_v);
subplot(2,3,6);
niak_visu_matrix(dureg_ref2_d, opt_v);
set(f2,'PaperPositionMode','auto');
print(f2, [fig_path filesep 'noise.png'], '-dpng');

%% Find out how the values inside and outside of the noise relate to each other
inside_mask = reshape(prior_regular_vec .* diag_mask(:) == corner_net, [edge, edge]);
outside_mask = reshape(prior_regular_vec .* ~diag_mask(:) == corner_net, [edge, edge]);

avg_in = mean(scores_corner_d(logical(inside_mask)));
avg_out = mean(scores_corner_d(logical(outside_mask)));
%% Show the differnces
f3 = figure('position',[0 0 1200 600]);
opt_v = struct;
opt_v.limits = [-1 1];
subplot(2,3,1);
niak_visu_matrix(scores_corner - scores_corner_d, opt_v);
subplot(2,3,2);
niak_visu_matrix(seed_corner - seed_corner_d, opt_v);
subplot(2,3,3);
niak_visu_matrix(dureg_corner - dureg_corner_d, opt_v);
subplot(2,3,4);
niak_visu_matrix(scores_ref2 - scores_ref2_d, opt_v);
subplot(2,3,5);
niak_visu_matrix(seed_ref2_d - seed_ref2_d, opt_v);
subplot(2,3,6);
niak_visu_matrix(dureg_ref2 - dureg_ref2_d, opt_v);
set(f3,'PaperPositionMode','auto');
print(f3, [fig_path filesep 'difference.png'], '-dpng');