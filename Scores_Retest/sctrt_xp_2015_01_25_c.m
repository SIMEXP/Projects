clear;

out_path = '/data1/scores/visualization_dump';
psom_set_rand_seed(0);

edge = 32;

opt_s.type = 'checkerboard'; 
opt_s.t = 100; 
opt_s.n = edge*edge; 
opt_s.nb_clusters = [4 16]; 
opt_s.fwhm = 1; 
opt_s.variance = 0.05; 

%% Regular method
[tseries,opt_mplm] = niak_simus_scenario(opt_s);
part = opt_mplm.space.mpart{2};
opt_scores.sampling.type = 'scenario';
opt_scores.sampling.opt = opt_s;
opt_scores.sampling.opt.t = ceil(0.6*opt_s.t);
res_reg = niak_stability_cores(tseries,part,opt_scores);

%% Estrid method
part = opt_mplm.space.mpart{2};
target = opt_mplm.space.mpart{1};
partition = [part, target];
opt_scores.sampling.type = 'scenario';
opt_scores.sampling.opt = opt_s;
opt_scores.sampling.opt.t = ceil(0.6*opt_s.t);
opt_scores.flag_target = true;
res_est = niak_stability_cores(tseries,partition,opt_scores);

%% Visualize stability maps for all networks at once. side by side for both methods
stab_mat = zeros(16 * 32, 2 * 32);
for i = 1:16
    stab_est = reshape(res_est.stab_maps(:, i), [32 32]);
    stab_reg = reshape(res_reg.stab_maps(:, i), [32 32]);
    start = (i-1) * 32;
    stop = i * 32;
    stab_mat(start + 1:stop,1:32) = stab_reg;
    stab_mat(start + 1:stop,33:end) = stab_est;
end

h = figure;
set(h, 'PaperPosition', [32 1 8*32 1]);
niak_visu_matrix(stab_mat);
