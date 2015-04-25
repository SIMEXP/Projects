clear all; close all;
%% Make signal
edge = 64;
corner_net = 1;
border_net = 6;
legends = {'scores', 'seed', 'dual regression'};
fig_path = '/home/surchs/Code/Projects/Scores/Simulation/figures';

opt_s.type = 'checkerboard'; 
opt_s.t = 100; 
opt_s.n = edge*edge; 
opt_s.nb_clusters = [4 16]; 
opt_s.fwhm = 1; 
opt_s.variance = 0.05;

[tseries_noise,opt_mplm] = niak_simus_scenario(opt_s);
opt_s.variance = 0.5;
[tseries_clean,~] = niak_simus_scenario(opt_s);
opt_s.fwhm = 4; 
opt_s.variance = 0.05;
[tseries_smooth,~] = niak_simus_scenario(opt_s);

%% Show the priors
prior_low_vec = opt_mplm.space.mpart{2};
prior_low = reshape(prior_low_vec, [edge, edge]);

prior_high_vec = opt_mplm.space.mpart{1};
prior_high = reshape(prior_high_vec, [edge, edge]);
fig = figure('position',[0 0 1200 600]);
subplot(121);
imagesc(prior_low);
set(gca,'XTick', 1:edge, 'XTickLabel', [], 'YTickLabel', 1:edge, 'YTick', []);
grid on;

subplot(122);
imagesc(prior_high);
set(gca,'XTick', 1:edge, 'XTickLabel', [], 'YTickLabel', [], 'YTick', 1:edge);
grid on;

set(fig,'PaperPositionMode','auto');
print(fig, [fig_path filesep 'priors.png'], '-dpng');
%% Show noise signal
fig = figure('position',[0 0 600 600]);

R_noise = corr(tseries_noise);
hier_noise = niak_hierarchical_clustering(R_noise);
order_noise = niak_hier2order(hier_noise);
niak_visu_matrix(R_noise(order_noise, order_noise));
title('Noisy Signal');

set(fig,'PaperPositionMode','auto');
print(fig, [fig_path filesep 'noisy_signal.png'], '-dpng');
%% Show clean signal
fig = figure('position',[0 0 600 600]);

R_clean = corr(tseries_clean);
hier_clean = niak_hierarchical_clustering(R_clean);
order_clean = niak_hier2order(hier_clean);
niak_visu_matrix(R_clean(order_clean, order_clean));
title('Clean Signal');

set(fig,'PaperPositionMode','auto');
print(fig, [fig_path filesep 'clean_signal.png'], '-dpng');
%% Show smooth signal
fig = figure('position',[0 0 600 600]);

R_smooth = corr(tseries_smooth);
hier_smooth = niak_hierarchical_clustering(R_smooth);
order_smooth = niak_hier2order(hier_smooth);
niak_visu_matrix(R_smooth(order_smooth, order_smooth));
title('Smooth Signal');

set(fig,'PaperPositionMode','auto');
print(fig, [fig_path filesep 'smooth_signal.png'], '-dpng');