clear all; close all;
%% Make the signal for smooth and shifted prior
fig_path = '/home/surchs/Code/Projects/Scores/Simulation/figures/shifted_right';
psom_mkdir(fig_path);

edge = 64;
n_edge = edge/4;
corner_net = 1;
border_net = 6;
ref_net1 = 2;
ref_net2 = 5;
networks = [1 2 5 6];
n_nets = length(networks);
net_names = {'corner', 'reference1', 'reference2', 'border'};

n_perm = 100;
% Define the shifts
shifts = [0 2 4 6 8 10];
n_shifts = length(shifts);
shift_labels = cell(n_shifts,1);
for s_id = 1:n_shifts
    shift = shifts(s_id);
    shift_labels{s_id} = sprintf('%.2f%%', (100*shift)/n_edge);
end

opt_s.type = 'checkerboard';
opt_s.t = 100;
opt_s.n = edge*edge;
opt_s.nb_clusters = [4 16];
opt_s.fwhm = 4;
opt_s.variance = 0.05;

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
    prior_shift = circshift(prior_true, [0 shift]);
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

set(f_priors,'PaperPositionMode','auto');
print(f_priors, [fig_path filesep 'overview_priors.png'], '-dpng');

%% 2. Plot the average maps across shifts and methods
pos_mat = reshape(1:18, [3, 6])';
opt_v.limits = [-1 1];
opt_v.color_map = niak_hot_cold;

for net_id = 1:n_nets
    network_id = networks(net_id);
    net_name = net_names{net_id};
    % Generate the figure
    f_map = figure('position',[0 0 1500 2400]);
    % Generate the 2D label for an overlay
    label_mask = prior_true==network_id;
    [x, y] = find(label_mask);
    pos_vec = [min(y), min(x), n_edge, n_edge];
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
    set(f_map,'PaperPositionMode','auto');
    print(f_map, [fig_path filesep sprintf('average_map_%s_network.png', net_name)], '-dpng');
end

%% 3. ROC Plot
f_roc = figure('position',[0 0 1500 2400]);
pos_mat = reshape(1:12, [3, 4])';
cc=jet(n_shifts);
% Iterate over networks
for net_id = 1:n_nets
    network_id = networks(net_id);
    net_name = net_names{net_id};
    % Get the TPR values for this network and the different shifts
    scores = squeeze(mean(squeeze(scores_roc(:, 1, :, net_id, :)),2));
    seed = squeeze(mean(squeeze(seed_roc(:, 1, :, net_id, :)),2));
    dureg = squeeze(mean(squeeze(dureg_roc(:, 1, :, net_id, :)),2));
    % Make the labels (with the AUC)
    
    scores_labels = cell(n_shifts+1,1);
    seed_labels = cell(n_shifts+1,1);
    dureg_labels = cell(n_shifts+1,1);
    for s_id = 1:n_shifts
        shift = shifts(s_id);
        perc_shift = (shift*100)/16;
        % AUC
        tmp_scores_auc = mean(scores_auc(:, net_id, s_id),1);
        tmp_seed_auc = mean(seed_auc(:, net_id, s_id),1);
        tmp_dureg_auc = mean(dureg_auc(:, net_id, s_id),1);
        
        scores_labels{s_id} = sprintf('%.2f%% (%.3f)', perc_shift, tmp_scores_auc);
        seed_labels{s_id} = sprintf('%.2f%% (%.3f)', perc_shift, tmp_seed_auc);
        dureg_labels{s_id} = sprintf('%.2f%% (%.3f)', perc_shift, tmp_dureg_auc);
    end
    scores_labels{end} = 'chance';
    seed_labels{end} = 'chance';
    dureg_labels{end} = 'chance';
        
    % Scores
    subplot(4,3,pos_mat(net_id, 1));
    hold on;
    plot(ref_fpr, scores);
    colormap(cc);
    plot(ref_fpr, ref_fpr, 'k');
    hold off;
    legend(scores_labels, 'Location', 'southeast');
    if net_id == 1
        title('Scores');
    end
    ylabel(sprintf('%s network', net_name));
    
    % Seed
    subplot(4,3,pos_mat(net_id, 2));
    hold on;
    plot(ref_fpr, seed);
    colormap(cc);
    plot(ref_fpr, ref_fpr, 'k');
    hold off;
    legend(seed_labels, 'Location', 'southeast');
    if net_id == 1
        title('Seed');
    end
    
    % Dureg
    subplot(4,3,pos_mat(net_id, 3));
    hold on;
    plot(ref_fpr, dureg);
    colormap(cc);
    plot(ref_fpr, ref_fpr, 'k');
    hold off;
    legend(dureg_labels, 'Location', 'southeast');
    if net_id == 1
        title('Dual Regression');
    end
end
set(f_roc,'PaperPositionMode','auto');
print(f_roc, [fig_path filesep 'roc_overview.png'], '-dpng');

%% 4. AUC plot
% 4. Two AUC plot in one figure, one for each network

f_auc = figure('position',[0 0 1500 2400]);
for net_id = 1:n_nets
    network_id = networks(net_id);
    net_name = net_names{net_id};
    % Get the average AUC values
    auc_all = [squeeze(mean(scores_auc(:, net_id, :),1)), squeeze(mean(seed_auc(:, net_id, :),1)), squeeze(mean(dureg_auc(:, net_id, :),1))];
    std_all = [squeeze(std(scores_auc(:, net_id, :),[],1)), squeeze(std(seed_auc(:, net_id, :),[],1)), squeeze(std(dureg_auc(:, net_id, :),[],1))];
    
    subplot(4,1,net_id)
    % Combine them all into one big plot
    barwitherr(std_all, auc_all);
    legend({'scores', 'seed', 'dual regression'}, 'Location', 'eastoutside');
    title(sprintf('AUC for %s network', net_name));
    set(gca,'xlim',[0 n_shifts+1],'ylim', [0.3 1], 'XTickLabel', shift_labels);
    xlabel('shift');
    ylabel('AUC');
end
set(f_auc,'PaperPositionMode','auto');
print(f_auc, [fig_path filesep 'auc_overview.png'], '-dpng');

%% 5. Separation Plot

pos_mat = reshape(1:18, [3, 6])';
opt_v.limits = [-1 1];
opt_v.color_map = niak_hot_cold;
for net_id = 1:n_nets
    network_id = networks(net_id);
    net_name = net_names{net_id};
    % Generate the figure
    f_sep = figure('position',[0 0 1500 2400]);
    % Generate the 2D label for an overlay
    label_mask = prior_true==network_id;
    [x, y] = find(label_mask);
    pos_vec = [min(x), min(y), n_edge, n_edge];
    % Iterate over the shift levels
    for s_id = 1:n_shifts
        shift = shifts(s_id);
        perc_shift = (shift*100)/16;
        % Get the average map across permutations
        scores_tprt = mean(squeeze(scores_roc(:, 2, :, net_id, s_id)),2);
        scores_fprt = mean(squeeze(scores_roc(:, 3, :, net_id, s_id)),2);
        scores_ab = (trapz(ref_thr, scores_tprt) - trapz(ref_thr, scores_fprt))/2;
        
        seed_tprt = mean(squeeze(seed_roc(:, 2, :, net_id, s_id)),2);
        seed_fprt = mean(squeeze(seed_roc(:, 3, :, net_id, s_id)),2);
        seed_ab = (trapz(ref_thr, seed_tprt) - trapz(ref_thr, seed_fprt))/2;
        
        dureg_tprt = mean(squeeze(dureg_roc(:, 2, :, net_id, s_id)),2);
        dureg_fprt = mean(squeeze(dureg_roc(:, 3, :, net_id, s_id)),2);
        dureg_ab = (trapz(ref_thr, dureg_tprt) - trapz(ref_thr, dureg_fprt))/2;
        
        % Plot them
        % Scores
        subplot(6, 3, pos_mat(s_id, 1));
        hold on;
        % Generate filled area
        X = [ref_thr, fliplr(ref_thr)];
        Y = [scores_fprt', fliplr(scores_tprt')];
        h = fill(X, Y, 'b');
        %set(h,'facealpha',.1);
        plot(ref_thr, scores_tprt, 'g');
        plot(ref_thr, scores_fprt, 'r');
        hold off;
        legend({sprintf('TPR-FPR (%.3f)', scores_ab), 'TPR', 'FPR'}, 'Location', 'southwest');
        if s_id == 1
            title('Scores');
        end
        ylabel(sprintf('Shift %.2f%%', perc_shift));
        
        % Seed
        subplot(6, 3, pos_mat(s_id, 2));
        hold on;
        % Generate filled area
        X = [ref_thr, fliplr(ref_thr)];
        Y = [seed_fprt', fliplr(seed_tprt')];
        h = fill(X, Y, 'b');
        %set(h,'facealpha',.1);
        plot(ref_thr, seed_tprt, 'g');
        plot(ref_thr, seed_fprt, 'r');
        hold off;
        legend({sprintf('TPR-FPR (%.3f)', seed_ab), 'TPR', 'FPR'}, 'Location', 'southwest');
        if s_id == 1
            title('Seed');
        end
        
        % Dureg
        subplot(6, 3, pos_mat(s_id, 3));
        hold on;
        % Generate filled area
        X = [ref_thr, fliplr(ref_thr)];
        Y = [dureg_fprt', fliplr(dureg_tprt')];
        h = fill(X, Y, 'b');
        %set(h,'facealpha',.1);
        plot(ref_thr, dureg_tprt, 'g');
        plot(ref_thr, dureg_fprt, 'r');
        hold off;
        legend({sprintf('TPR-FPR (%.3f)', dureg_ab), 'TPR', 'FPR'}, 'Location', 'southwest');
        if s_id == 1
            title('Dual Regression');
        end
    end
    set(f_sep,'PaperPositionMode','auto');
    print(f_sep, [fig_path filesep sprintf('separation_%s_network.png', net_name)], '-dpng');
end

%% Mass-Univariate Ttest of AUC
% Make a storage for the values
% 1 - types of values (8 t, p, mean, std, df, pooled_std, cohensd, bonferroni)
% 2 - values (n_shifts)
% 3 - tests (3: scores/seed, scores/dureg, seed/dureg)
% 4 - networks
t_auc_store = zeros(7, n_shifts, 3, n_nets);
q = 0.01;
for net_id = 1:n_nets
    network_id = networks(net_id);
    net_name = net_names{net_id};
    % Get the average AUC values
    tmp_scores_auc = squeeze(scores_auc(:, net_id, :));
    tmp_seed_auc = squeeze(seed_auc(:, net_id, :));
    tmp_dureg_auc = squeeze(dureg_auc(:, net_id, :));
    % Run the t-test
    % 1 scores-seed
    [t1, p1, m1, s1, d1] = niak_ttest(tmp_scores_auc, tmp_seed_auc, true);
    % 2 scores-dureg
    [t2, p2, m2, s2, d2] = niak_ttest(tmp_scores_auc, tmp_dureg_auc, true);
    % 3 seed-dureg
    [t3, p3, m3, s3, d3] = niak_ttest(tmp_seed_auc, tmp_dureg_auc, true);
    % Store the stuff
    t_auc_store(1:5, :, 1, net_id) = [t1; p1; m1; s1; d1];
    t_auc_store(1:5, :, 2, net_id) = [t2; p2; m2; s2; d2];
    t_auc_store(1:5, :, 3, net_id) = [t3; p3; m3; s3; d3];
    % Add the pooled variance
    t_auc_store(6, :, 1, net_id) = ( (( n_perm - 1) .* std(tmp_scores_auc)) + (( n_perm - 1) .* std(tmp_seed_auc))) / (n_perm + n_perm -2);
    t_auc_store(6, :, 2, net_id) = ( (( n_perm - 1) .* std(tmp_scores_auc)) + (( n_perm - 1) .* std(tmp_dureg_auc))) / (n_perm + n_perm -2);
    t_auc_store(6, :, 3, net_id) = ( (( n_perm - 1) .* std(tmp_seed_auc)) + (( n_perm - 1) .* std(tmp_dureg_auc))) / (n_perm + n_perm -2);
    % Compute Cohensd
    t_auc_store(7, :, 1, net_id) = t_auc_store(3, :, 1, net_id) ./ t_auc_store(6, :, 1, net_id);
    t_auc_store(7, :, 2, net_id) = t_auc_store(3, :, 2, net_id) ./ t_auc_store(6, :, 2, net_id);
    t_auc_store(7, :, 3, net_id) = t_auc_store(3, :, 3, net_id) ./ t_auc_store(6, :, 3, net_id);
end
% Do the bonferroni correction
p = squeeze(t_auc_store(2, :, :, :));
p_mask = p < q/numel(p);
t_auc_store(8, :, :, :) = p_mask;
save([fig_path filesep 'ttest_results_auc.mat'], 't_auc_store');

%% Generate some tables
%load([fig_path filesep 'ttest_results_auc.mat']);
for net_id = 1:n_nets
    network_id = networks(net_id);
    net_name = net_names{net_id};
    fprintf('%s network\n', net_name);
    test_name = {'scores vs seed', 'scores vs dureg', 'seed vs dureg'};
    for t_id = 1:3
        fprintf('    %s\n', test_name{t_id});
        pval = t_auc_store(2, :, t_id, net_id)';
        bonf =  t_auc_store(8, :, t_id, net_id)';
        pval(~bonf) = 1;
        effect =  t_auc_store(7, :, t_id, net_id)';
        tval =  t_auc_store(1, :, t_id, net_id)';
        df =  t_auc_store(5, :, t_id, net_id)';
        T = table(bonf, pval, tval, df, effect, 'RowNames', cellstr(num2str(shifts')))
    end
end