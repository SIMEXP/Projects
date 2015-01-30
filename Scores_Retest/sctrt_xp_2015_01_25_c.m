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
%% Show us the Estrid method
figure;
sil_m = reshape(res_est.stab_contrast(:, 1), [32 32]); % Get the silhouette map
niak_visu_matrix(sil_m);
title('Silhouette of Estrid method');
movegui('southeast');
figure;
stab_m = reshape(res_est.stab_maps(:, 3), [32 32]); % Get the stability map of one network
niak_visu_matrix(stab_m);
title('Stability map of net#3 of Estrid method');
movegui('southwest');
%% Show us the target, just for comparison
show_tar = reshape(target, [32 32]);
figure;
niak_visu_matrix(show_tar);
title('This is the target for the Estrid method');
%% Now do this again, but this time show all networks at once. side by side
%% Visualize stability maps for all networks at once. side by side for both methods
%% Now do this a couple of times and see what the mean looks like
edge = 32;

opt_s.type = 'checkerboard'; 
opt_s.t = 100; 
opt_s.n = edge*edge; 
opt_s.nb_clusters = [4 16]; 
opt_s.fwhm = 1; 
opt_s.variance = 0.05; 

iter = 100;
mat_reg = zeros(32, 32, iter);
mat_est = zeros(32, 32, iter);

for i = 1:iter
    fprintf('this is iter %d\n', i);
    [tseries,opt_mplm] = niak_simus_scenario(opt_s);
    part = opt_mplm.space.mpart{2};
    target = opt_mplm.space.mpart{1} == 1;
    partition = [part, target];
    opt_scores.sampling.type = 'scenario';
    opt_scores.sampling.opt = opt_s;
    opt_scores.flag_verbose = false;
    opt_scores.sampling.opt.t = ceil(0.6*opt_s.t);
    % Regular
    opt_scores.flag_target = false;
    res_reg = niak_stability_cores(tseries,part,opt_scores);
    m_reg = reshape(res_reg.stab_maps(:, 4), [32 32]);
    % Estrid
    opt_scores.flag_target = true;
    res_est = niak_stability_cores(tseries,partition,opt_scores);
    m_est = reshape(res_est.stab_maps(:, 4), [32 32]);
    % Save it
    mat_reg(:,:,i) = m_reg;
    mat_est(:,:,i) = m_est;
end
%% Get the average and std of these
mean_reg = mean(mat_reg,3);
mean_est = mean(mat_est,3);
std_reg = std(mat_reg,[],3);
std_est = std(mat_est,[],3);
%% And visualize
figure;
niak_visu_matrix(mean_reg);
title('Mean stability of  net#3 of regular method');
movegui('northwest');
figure;
niak_visu_matrix(std_reg);
title('std of  net#3 of regular method');
movegui('northeast');
figure;
niak_visu_matrix(mean_est);
title('Mean stability of  net#3 of Estrid method');
movegui('southwest');
figure;
niak_visu_matrix(std_est);
title('std of  net#3 of Estrid method');
movegui('southwest');
