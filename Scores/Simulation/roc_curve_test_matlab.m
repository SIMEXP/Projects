clear all; close all;
%% Test the goddamn ROC curve
edge = 64;
shifts = 3:8;
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

prior_regular_vec = opt_mplm.space.mpart{2};
prior_regular = reshape(prior_regular_vec, [edge, edge]);

corner_regular_labels = prior_regular==corner_net;
corner_regular_labels = corner_regular_labels(:);

border_regular_labels = prior_regular==border_net;
border_regular_labels = border_regular_labels(:);

tpr_cell = {n_shifts, 2};
fpr_cell = {n_shifts, 2};

for s_id = 1:n_shifts
    shift  = shifts(s_id);
    prior_shift = circshift(prior_regular, [shift shift]);
    prior_shift_vec = reshape(prior_shift, [dot(edge, edge), 1]);
    % Scores
    opt_scores.sampling.type = 'bootstrap';
    opt_scores.sampling.opt = opt_s;
    opt_scores.flag_verbose = false;
    
    res_scores_shift = niak_stability_cores(tseries_smooth,prior_shift_vec,opt_scores);
    scores_shift_corner = reshape(res_scores_shift.stab_maps(:, corner_net), [edge, edge]);
    scores_shift_border = reshape(res_scores_shift.stab_maps(:, border_net), [edge, edge]);
    
    % Matlab ROC
    [fpr_scores, tpr_scores, ~, auc_scores] = perfcurve(border_regular_labels, scores_shift_border(:), true);
    fpr_cell{s_id, 1} = fpr_scores;
    tpr_cell{s_id, 1} = tpr_scores;
    
    % Manual ROC
    [fpr_cell{s_id,2}, tpr_cell{s_id,2}] = roc(border_regular_labels, scores_shift_border(:), true);
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
