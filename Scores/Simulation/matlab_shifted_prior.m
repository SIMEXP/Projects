clear all; close all;
%% Make the signal for smooth and shifted prior
out_file = 'matlab_noisy_store_bootstrap.mat';

edge = 64;
shifts = 0:9;
n_shifts = length(shifts);
n_edge = edge/4;
shift = 6;
corner_net = 1;
border_net = 6;

opt_s.type = 'checkerboard';
opt_s.t = 100;
opt_s.n = edge*edge;
opt_s.nb_clusters = [4 16];
opt_s.variance = 3;
opt_s.fwhm = 2;
[tseries,opt_mplm] = niak_simus_scenario(opt_s);

tpr_cell = {n_shifts,3};
fpr_cell = {n_shifts,3};

n_perm = 10;
ref_x = linspace(0,1,opt_s.n+1);

%% Make the priors
prior_regular_vec = opt_mplm.space.mpart{2};
prior_regular = reshape(prior_regular_vec, [edge, edge]);

%% Make the labels for ROC
corner_regular_labels = prior_regular==corner_net;
corner_regular_labels = corner_regular_labels(:);

border_regular_labels = prior_regular==border_net;
border_regular_labels = border_regular_labels(:);

%% Prepare storage
% Shifts, voxels, methods, border/corner
tpr_store = zeros(n_shifts, opt_s.n+1, 4, 2);
map_store = zeros(n_shifts, opt_s.n, 4, 2);
% Shifts, AUC/STD, methods, border/corner
auc_store = zeros(n_shifts, 2, 4, 2);

if n_perm < 2
    error('Using less than 2 repetitions is pointless and breaks things!');
end

for s_id = 1:n_shifts
    fprintf('Iterating through number %d\n', s_id);
    shift = shifts(s_id);
    
    %% Make the priors
    prior_shift = circshift(prior_regular, [shift shift]);
    prior_shift_vec = reshape(prior_shift, [dot(edge, edge), 1]);
    
    tpr_temp = zeros(n_perm, opt_s.n+1, 4, 2);
    map_temp = zeros(n_perm, opt_s.n, 4, 2);
    auc_temp = zeros(n_perm, 4, 2);
    
    for p_id = 1:n_perm
        fprintf('   perm %d\n', p_id);
        %% Run the analysis
        [tseries,~] = niak_simus_scenario(opt_s);
        %% Scores
        opt_scores.sampling.type = 'bootstrap';
        opt_scores.sampling.opt = opt_s;
        opt_scores.flag_verbose = false;
        opt_scores.flag_target = true;
        target_prior = repmat(prior_shift_vec, 1,2);
        %Scores with bad prior
        res_scores_target = niak_stability_cores(tseries,target_prior,opt_scores);
        scores_corner_target = reshape(res_scores_target.stab_maps(:, corner_net), [edge, edge]);
        scores_border_target = reshape(res_scores_target.stab_maps(:, border_net), [edge, edge]);
        
        opt_scores.flag_target = false;
        res_scores_time = niak_stability_cores(tseries,prior_shift_vec,opt_scores);
        scores_corner_time = reshape(res_scores_time.stab_maps(:, corner_net), [edge, edge]);
        scores_border_time = reshape(res_scores_time.stab_maps(:, border_net), [edge, edge]);
        
        %% Seed
        opt_t.type_center = 'mean';
        opt_t.correction = 'mean_var';
        % Seed with bad prior
        tseed = niak_build_tseries(tseries,prior_shift_vec,opt_t);
        seed_tmp = niak_fisher(corr(tseries,tseed))';
        seed_corner = reshape(seed_tmp(corner_net, :), [edge, edge]);
        seed_border = reshape(seed_tmp(border_net, :), [edge, edge]);
        
        %% Dual Regression
        opt_t.type_center = 'mean';
        opt_t.correction = 'mean_var';
        % Dureg with bad prior
        tseed = niak_build_tseries(tseries,prior_shift_vec,opt_t);
        tseed = niak_normalize_tseries(tseed);
        tseries_dual = niak_normalize_tseries(tseries);
        beta = niak_lse(tseries_dual,tseed);
        dureg_corner = reshape(beta(corner_net, :), [edge, edge]);
        dureg_border = reshape(beta(border_net, :), [edge, edge]);
        
        %% ROC analysis and clean up duplicates
        % Border
        [fpr_scores_b_target, tpr_scores_b_target] = local_roc(border_regular_labels, scores_border_target(:), true);
        [fpr_scores_b_target, tpr_scores_b_target] = clean_dupl(fpr_scores_b_target, tpr_scores_b_target); 
        
        [fpr_scores_b_time, tpr_scores_b_time] = local_roc(border_regular_labels, scores_border_time(:), true);
        [fpr_scores_b_time, tpr_scores_b_time] = clean_dupl(fpr_scores_b_time, tpr_scores_b_time); 
        
        [fpr_seed_b, tpr_seed_b] = local_roc(border_regular_labels, seed_border(:), true);
        [fpr_seed_b, tpr_seed_b] = clean_dupl(fpr_seed_b, tpr_seed_b); 
        
        [fpr_dureg_b, tpr_dureg_b] = local_roc(border_regular_labels, dureg_border(:), true);
        [fpr_dureg_b, tpr_dureg_b] = clean_dupl(fpr_dureg_b, tpr_dureg_b); 
        % Corner
        [fpr_scores_c_target, tpr_scores_c_target] = local_roc(corner_regular_labels, scores_corner_target(:), true);
        [fpr_scores_c_target, tpr_scores_c_target] = clean_dupl(fpr_scores_c_target, tpr_scores_c_target); 
        
        [fpr_scores_c_time, tpr_scores_c_time] = local_roc(corner_regular_labels, scores_corner_time(:), true);
        [fpr_scores_c_time, tpr_scores_c_time] = clean_dupl(fpr_scores_c_time, tpr_scores_c_time); 
        
        [fpr_seed_c, tpr_seed_c] = local_roc(corner_regular_labels, seed_corner(:), true);
        [fpr_seed_c, tpr_seed_c] = clean_dupl(fpr_seed_c, tpr_seed_c); 
        
        [fpr_dureg_c, tpr_dureg_c] = local_roc(corner_regular_labels, dureg_corner(:), true);
        [fpr_dureg_c, tpr_dureg_c] = clean_dupl(fpr_dureg_c, tpr_dureg_c); 
        %% Interpolate
        % There may be warnings because of multiple overlapping fpr values
        tpr_scores_int_b_target = interp1(fpr_scores_b_target, tpr_scores_b_target, ref_x);
        tpr_scores_int_b_time = interp1(fpr_scores_b_time, tpr_scores_b_time, ref_x);
        
        tpr_seed_int_b = interp1(fpr_seed_b, tpr_seed_b, ref_x);
        tpr_dureg_int_b = interp1(fpr_dureg_b, tpr_dureg_b, ref_x);
        
        tpr_scores_int_c_target = interp1(fpr_scores_c_target, tpr_scores_c_target, ref_x);
        tpr_scores_int_c_time = interp1(fpr_scores_c_time, tpr_scores_c_time, ref_x);
        
        tpr_seed_int_c = interp1(fpr_seed_c, tpr_seed_c, ref_x);
        tpr_dureg_int_c = interp1(fpr_dureg_c, tpr_dureg_c, ref_x);
        
        %% Save it
        tpr_temp(p_id, :, 1, 1) = tpr_scores_int_b_target;
        tpr_temp(p_id, :, 2, 1) = tpr_scores_int_b_time;
        tpr_temp(p_id, :, 3, 1) = tpr_seed_int_b;
        tpr_temp(p_id, :, 4, 1) = tpr_dureg_int_b;
        
        tpr_temp(p_id, :, 1, 2) = tpr_scores_int_c_target;
        tpr_temp(p_id, :, 2, 2) = tpr_scores_int_c_time;
        tpr_temp(p_id, :, 3, 2) = tpr_seed_int_c;
        tpr_temp(p_id, :, 4, 2) = tpr_dureg_int_c;
        % And the maps too
        map_temp(p_id, :, 1, 1) = scores_border_target(:);
        map_temp(p_id, :, 2, 1) = scores_border_time(:);
        map_temp(p_id, :, 3, 1) = seed_border(:);
        map_temp(p_id, :, 4, 1) = dureg_border(:);
        
        map_temp(p_id, :, 1, 2) = scores_corner_target(:);
        map_temp(p_id, :, 2, 2) = scores_corner_time(:);
        map_temp(p_id, :, 3, 2) = seed_corner(:);
        map_temp(p_id, :, 4, 2) = dureg_corner(:);
        % And the AUC
        auc_temp(p_id, 1, 1) = trapz(ref_x,tpr_scores_int_b_target);
        auc_temp(p_id, 2, 1) = trapz(ref_x,tpr_scores_int_b_time);
        auc_temp(p_id, 3, 1) = trapz(ref_x,tpr_seed_int_b);
        auc_temp(p_id, 4, 1) = trapz(ref_x,tpr_dureg_int_b);
        
        auc_temp(p_id, 1, 2) = trapz(ref_x,tpr_scores_int_c_target);
        auc_temp(p_id, 2, 2) = trapz(ref_x,tpr_scores_int_c_time);
        auc_temp(p_id, 3, 2) = trapz(ref_x,tpr_seed_int_c);
        auc_temp(p_id, 4, 2) = trapz(ref_x,tpr_dureg_int_c);
     end
     
     %% Average across permutations
     tpr_store(s_id, :, :, :) = squeeze(mean(tpr_temp,1));
     map_store(s_id, :, :, :) = squeeze(mean(map_temp,1));
     auc_store(s_id, 1, :, :) = squeeze(mean(auc_temp, 1));
     auc_store(s_id, 2, :, :) = squeeze(std(auc_temp, 1));
end
save(out_file, 'map_store', 'auc_store', 'tpr_store', 'ref_x', 'shifts', 'n_shifts', 'n_edge');

%% Visualize
cc=jet(n_shifts);
names = {'scores (target)', 'scores (time)', 'seed', 'dual regression'};

%% The ROC curves
% Border
f1 = figure('position',[0 0 1800 600]);
for m_id = 1:4
    labels = cell(n_shifts,1);
    subplot(1,4,m_id);
    hold on;
    for s_id = 1:n_shifts
        plot(ref_x, tpr_store(s_id, :,m_id, 1), 'color', cc(s_id,:));
        labels{s_id} = sprintf('%.1f %% (%.2f)', (shifts(s_id)'*100)/n_edge, auc_store(s_id, 1, m_id, 1));
    end
    labels{end+1} = 'chance';
    plot(ref_x, ref_x, 'k');
    title(names{m_id});
    legend(labels, 'Location', 'southeast');
    hold off;
end
set(f1,'PaperPositionMode','auto');
print(f1, 'roc_curves_noisy_border.png', '-dpng');

% Corner
f2 = figure('position',[0 0 1800 600]);
for m_id = 1:4
    labels = cell(n_shifts,1);
    subplot(1,4,m_id);
    hold on;
    for s_id = 1:n_shifts
        plot(ref_x, tpr_store(s_id, :,m_id, 2), 'color', cc(s_id,:));
        labels{s_id} = sprintf('%.1f %% (%.2f)', (shifts(s_id)'*100)/n_edge, auc_store(s_id, 1, m_id, 2));
    end
    labels{end+1} = 'chance';
    plot(ref_x, ref_x, 'k');
    title(names{m_id});
    legend(labels, 'Location', 'southeast');
    hold off;
end
set(f2,'PaperPositionMode','auto');
print(f2, 'roc_curves_noisy_corner.png', '-dpng');

%% The volume maps
% Border
f3 = figure('position',[0 0 1400 n_shifts*300]);
count = 1;
for s_id = 1:n_shifts
  for m_id = 1:4
    opt.limits = [-1 1];
    subplot(n_shifts, 4, count);
    count = count + 1;
    range = max(abs(map_store(s_id, :, m_id, 1)));
    imagesc(reshape(map_store(s_id, :, m_id, 1), [edge edge]), [-range range]);
    colormap(niak_hot_cold)
    colorbar;
    grid on;
    title(sprintf('%s %.2f%%', names{m_id}, (shifts(s_id)*100)/n_edge));
  end
end
legend(labels, 'Location', 'southeast');
suptitle('Border networks');
set(f3,'PaperPositionMode','auto');
print(f3, 'maps_permuation_border.png', '-dpng');

% Corner
f4 = figure('position',[0 0 1400 n_shifts*300]);
count = 1;
for s_id = 1:n_shifts
  for m_id = 1:4
    opt.limits = [-1 1];
    subplot(n_shifts, 4, count);
    count = count + 1;
    range = max(abs(map_store(s_id, :, m_id, 2)));
    imagesc(reshape(map_store(s_id, :, m_id, 2), [edge edge]), [-range range]);
    colormap(niak_hot_cold)
    colorbar;
    grid on;
    title(sprintf('%s %.2f%%', names{m_id}, (shifts(s_id)*100)/n_edge));
  end
end
legend(labels, 'Location', 'southeast');
suptitle('Corner networks');
set(f4,'PaperPositionMode','auto');
print(f4, 'maps_permuation_corner.png', '-dpng');

%% The AUC bars
f5 = figure('position',[0 0 1200 600]);

subplot(2,1,1);
barwitherr(squeeze(auc_store(:,2,:,1)), squeeze(auc_store(:,1,:,1)))

set(gca,'xlim',[0 n_shifts+1],'ylim', [0.5 1], 'XTickLabel',cellstr(num2str((shifts'*100)/n_edge, '%.2f%%')));
ylabel('AUC');
xlabel('Shifts');
legend(names, 'Location', 'eastoutside');
title('Border network');

subplot(2,1,2);
barwitherr(squeeze(auc_store(:,2,:,2)), squeeze(auc_store(:,1,:,2)))

set(gca,'xlim',[0 n_shifts+1],'ylim', [0.5 1], 'XTickLabel',cellstr(num2str((shifts'*100)/n_edge, '%.2f%%')));
ylabel('AUC');
xlabel('Shifts');
legend(names, 'Location', 'eastoutside');
title('Corner network');
suptitle('Noisy Data');

set(f5,'PaperPositionMode','auto');
print(f5, 'AUC__noisy_data.png', '-dpng');