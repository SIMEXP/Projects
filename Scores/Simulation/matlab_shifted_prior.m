clear all; close all;
%% Make the signal for smooth and shifted prior
fig_path = '/home/surchs/Code/Projects/Scores/Simulation/figures/shifted';
psom_mkdir(fig_path);

edge = 64;
n_edge = edge/4;
corner_net = 1;
border_net = 6;
ref_net1 = 2;
ref_net2 = 5;
networks = [1 2 5 6];
n_nets = length(networks);

n_perm = 2;
% Define the shifts
shifts = [0 1 2 4 8 10];
n_shifts = length(shifts);

opt_s.type = 'checkerboard';
opt_s.t = 100;
opt_s.n = edge*edge;
opt_s.nb_clusters = [4 16];
opt_s.fwhm = 4;

% Scores options
opt_scores.sampling.type = 'bootstrap';
opt_scores.sampling.opt = opt_s;
opt_scores.flag_verbose = false;
opt_scores.flag_target = false;

% Seed and Dualreg options
opt_t.type_center = 'mean';
opt_t.correction = 'mean_var';

n_ref = 100;
ref_fpr = linspace(0,1,n_ref);
ref_thr = linspace(-1,1,n_ref);

% Check number of permutations
if n_perm < 2
    error('Using less than 2 repetitions is pointless and breaks things!');
end

%% Dry run to get the priors
[tseries,opt_mplm] = niak_simus_scenario(opt_s);
% Get the priors
prior_true_vec = opt_mplm.space.mpart{2};
prior_true = reshape(prior_true_vec, [edge, edge]);

% Keep them
prior_shift_vec_store = zeros(edge*edge, n_shifts);
prior_shift_store = zeros(edge, edge, n_shifts);

% Generate the shifted priors
for s_id = 1:n_shifts
    shift = shifts(s_id);
    %% Make the priors
    prior_shift = circshift(prior_true, [shift shift]);
    prior_shift_vec = reshape(prior_shift, [dot(edge, edge), 1]);
    prior_shift_vec_store(:, s_id) = prior_shift_vec;
    prior_shift_store(:, :, s_id) = prior_shift;
end

%% Prepare the storage
% We need:
%   - the maps for the different levels of shift and for each network
%   - the interpolated FPR (THR) and TPR (FPR and THR) for each network, 
%     shift and permutation (vector)
%   - the AUC for each network, shift and permutation (single value)

% Maps:
% 1 (voxels)
% 2 (permutations)
% 3 (networks)
% 4 (shift levels)
scores_map = zeros(edge*edge, n_perm, 16, n_shifts);
seed_map = zeros(edge*edge, n_perm, 16, n_shifts);
dureg_map = zeros(edge*edge, n_perm, 16, n_shifts);

% ROC
% 1 (FPR/THR values)
% 2 (TPR_F/TPR_T/FPR_T)
% 3 (permutations)
% 4 (networks of interest)
% 5 (shift levels)
scores_roc = zeros(n_ref, 3, n_perm, n_nets, n_shifts);
seed_roc = zeros(n_ref, 3, n_perm, n_nets, n_shifts);
dureg_roc = zeros(n_ref, 3, n_perm, n_nets, n_shifts);

% AUC
% 1 (permutations)
% 2 (networks of interest)
% 3 (shift levels)
scores_auc = zeros(n_perm, n_nets, n_shifts);
seed_auc = zeros(n_perm, n_nets, n_shifts);
dureg_auc = zeros(n_perm, n_nets, n_shifts);

%% Begin the permutation and iteration over shift levels
for p_id = 1:n_perm
    fprintf('Iterating through permutation %d\n', p_id);
    % Generate the time series
    [tseries,~] = niak_simus_scenario(opt_s);
    for s_id = 1:n_shifts
        shift = shifts(s_id);
        fprintf('   shift %d\n', shift);
        % Get the corresponding shifted prior
        prior_shift_vec = prior_shift_vec_store(:, s_id);
        %% Run the analyses
        
        % Scores
        res_scores = niak_stability_cores(tseries, prior_shift_vec, opt_scores);
        % Do nothing here, just save the maps
        scores_map(:, p_id, :, s_id) = res_scores.stab_maps;
        % Seed
        tseed = niak_build_tseries(tseries, prior_shift_vec,opt_t);
        seed_tmp = niak_fisher(corr(tseries,tseed))';
        % Do nothing here, just save the maps
        seed_map(:, p_id, :, s_id) = seed_tmp';
        
        % Dual Regression
        tseed = niak_build_tseries(tseries, prior_shift_vec,opt_t);
        tseed = niak_normalize_tseries(tseed);
        tseries_dual = niak_normalize_tseries(tseries);
        beta = niak_lse(tseries_dual,tseed);
        % Do nothing here, just save the maps
        dureg_map(:, p_id, :, s_id) = beta';        
        
    end
end

%% Run through the results to generate the ROC and other measures
% Iterate over the networks
for net_id = 1:n_nets
    % Get the network number
    network_id = networks(net_id);
    fprintf('Computing ROC and AUC for network %d\n', network_id);
    % Generate the label for the ROC analysis
    label_mask = prior_true_vec==network_id;
    % Iterate over shift levels
    for s_id = 1:n_shifts
        shift = shifts(s_id);
        fprintf('   shift %d\n', shift);
        % Iterate over networks    
        for p_id = 1:n_perm
            % Get the networks
            scores_net = scores_map(:, p_id, network_id, s_id);
            seed_net = seed_map(:, p_id, network_id, s_id);
            dureg_net = dureg_map(:, p_id, network_id, s_id);

            % Scores
            [scores_fpr, scores_tpr, scores_thr, scores_auc_tmp] = perfcurve(label_mask, scores_net, true);
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
            scores_roc(:, 1, p_id, net_id, s_id) = scores_tpr_fint;
            scores_roc(:, 2, p_id, net_id, s_id) = scores_tpr_tint;
            scores_roc(:, 3, p_id, net_id, s_id) = scores_fpr_tint;
            % AUC
            scores_auc(p_id, net_id, s_id) = scores_auc_tmp;
            
            % Seed
            [seed_fpr, seed_tpr, seed_thr, seed_auc_tmp] = perfcurve(label_mask, seed_net, true);
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
            seed_roc(:, 1, p_id, net_id, s_id) = seed_tpr_fint;
            seed_roc(:, 2, p_id, net_id, s_id) = seed_tpr_tint;
            seed_roc(:, 3, p_id, net_id, s_id) = seed_fpr_tint;
            % AUC
            seed_auc(p_id, net_id, s_id) = seed_auc_tmp;

            % Dual Regression
            [dureg_fpr, dureg_tpr, dureg_thr, dureg_auc_tmp] = perfcurve(label_mask, dureg_net, true);
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
            dureg_roc(:, 1, p_id, net_id, s_id) = dureg_tpr_fint;
            dureg_roc(:, 2, p_id, net_id, s_id) = dureg_tpr_tint;
            dureg_roc(:, 3, p_id, net_id, s_id) = dureg_fpr_tint;
            % AUC
            dureg_auc(p_id, net_id, s_id) = dureg_auc_tmp;
        end
    end
end

%% Start visualizing things
% Here are the figures that I want:
% 1. 2 by 3 plot of the shifted priors (with the 0 guy)
% 2. One plot each for the average corner and border network maps across
%    shifts. Columns are methods, rows are shifts. Maybe add the shifted
%    prior overview in the first column (4 x 6). Also add the grid of the
%    true signal over the maps
% 3. One 2x3 plot of ROC, all shifts in one plot, cols are methods, rows
%    networks
% 4. Two AUC plot in one figure, one for each network
% 5. Separation of FPR and TPR by shifts. One figure per network

%% 1. Show the priors
f_priors = figure('position',[0 0 1200 800]);

for s_id = 1:n_shifts
    shift = shifts(s_id);
    perc_shift = (shift*100)/16;
    % Get the prior
    prior = prior_shift_store(:, :, s_id);
    % Plot it
    subplot(2,3,s_id);
    imagesc(prior);
    title(sprintf('Shift %.2f%%', perc_shift));
    set(gca, 'XTick', linspace(16,edge,4), 'YTick', linspace(16,edge,4),...
        'XColor', [1 1 1], 'YColor', [1 1 1],...
        'XTickLabel', [], 'YTickLabel', []);
    grid on;
end
suptitle('Different levels of prior shift');

%% 2. Plot the average maps across shifts and methods
pos_mat = reshape(1:18, [3, 6])';
opt_v.limits = [-1 1];
opt_v.color_map = niak_hot_cold;

for net_id = 1:n_nets
    network_id = networks(net_id);
    % Generate the figure
    f_map = figure('position',[0 0 1500 2400]);
    % Generate the 2D label for an overlay
    label_mask = prior_true==network_id;
    [x, y] = find(label_mask);
    pos_vec = [min(x), min(y), n_edge, n_edge];
    % Iterate over the shift levels
    for s_id = 1:n_shifts
        shift = shifts(s_id);
        perc_shift = (shift*100)/16;
        % Get the average map across permutations
        scores = reshape(mean(scores_map(:, :, network_id, s_id),2), [edge edge]);
        seed = reshape(mean(seed_map(:, :, network_id, s_id),2), [edge edge]);
        dureg = reshape(mean(dureg_map(:, :, network_id, s_id),2), [edge edge]);
        
        % Plot them
        % Scores
        subplot(6, 3, pos_mat(s_id, 1));
        niak_visu_matrix(scores, opt_v);
        rectangle('Position', pos_vec, 'EdgeColor','w','LineWidth',2);
        set(gca,'XTickLabel', [], 'YTickLabel', []);
        ylabel(sprintf('Shift %.2f%%', perc_shift));
    
        if s_id == 1
            title('Scores');
        end
    
        % Seed
        subplot(6, 3, pos_mat(s_id, 2));
        niak_visu_matrix(seed, opt_v);
        rectangle('Position', pos_vec, 'EdgeColor','w','LineWidth',2);
        set(gca,'XTickLabel', [], 'YTickLabel', []);
        if s_id == 1
            title('Seed');
        end
    
        % Dual Regression
        subplot(6, 3, pos_mat(s_id, 3));
        niak_visu_matrix(dureg, opt_v);
        rectangle('Position', pos_vec, 'EdgeColor','w','LineWidth',2);
        set(gca,'XTickLabel', [], 'YTickLabel', []);
        if s_id == 1
            title('Dual Regression');
        end
    end
end
        