% Sebastian (sebastian (dot) urchs (at) gmail (dot) com)
% Run this a couple of times
%% Now iterate across a number of combinations of sampling parameters and save the output
% 6 steps each
clear;
out_path = '/data1/scores/visualization_dump';
range_fwhm = 1:6;
range_variance = 0.05:0.05:0.3;
iter = 100;

edge = 32;
opt_s.type = 'checkerboard';
opt_s.t = 100;
opt_s.n = edge*edge;
opt_s.nb_clusters = [4 16];

% Prepare a matrix to store the output so for visualization we can load it
% with something useful
sil_mat_mean = zeros([edge, edge, 36]);
stab_mat_mean = zeros([edge, edge, 36]);
sil_mat_std = zeros([edge, edge, 36]);
stab_mat_std = zeros([edge, edge, 36]);
R_mat = zeros([opt_s.n, opt_s.n, 36]);

count = 1;
for f_id = 1:6
    fprintf('fwhm sim %d\n', f_id);
    tmp_fwhm = range_fwhm(f_id);
    for v_id = 1:6
        fprintf('    var sim %d\n', v_id);
        m_sil_mat = zeros([edge, edge, iter]);
        m_stab_mat = zeros([edge, edge, iter]);
        for it = 1:iter
            tmp_var = range_variance(v_id);
            opt_s.fwhm = tmp_fwhm;
            opt_s.variance = tmp_var;

            [tseries,opt_mplm] = niak_simus_scenario(opt_s);

            part = opt_mplm.space.mpart{2};
            opt_scores.sampling.type = 'scenario';
            opt_scores.sampling.opt = opt_s;
            opt_scores.sampling.opt.t = ceil(0.6*opt_s.t);
            opt_scores.flag_verbose = false;
            res = niak_stability_cores(tseries,part,opt_scores);
            m_sil_mat(:,:,it) = reshape(res.stab_contrast(:, 1), [32 32]);
            m_stab_mat(:,:,it) = reshape(res.stab_maps(:, 3), [32 32]);
            
        end
    R = niak_build_correlation(tseries);
    hier = niak_hierarchical_clustering(R);
    order = niak_hier2order(hier);
    R_mat(:,:,count) = R(order, order);
    sil_mat_mean(:,:,count) = mean(m_sil_mat, 3);
    stab_mat_mean(:,:,count) = mean(m_stab_mat, 3);
    sil_mat_std(:,:,count) = std(m_sil_mat, [], 3);
    stab_mat_std(:,:,count) = std(m_stab_mat, [], 3);
    count = count + 1;
    end
end

% Save the output
save([out_path filesep 'true_mean_stab.m'], 'stab_mat_mean');
save([out_path filesep 'true_mean_sil.m'], 'sil_mat_mean');
save([out_path filesep 'true_std_stab.m'], 'stab_mat_std');
save([out_path filesep 'true_std_sil.m'], 'sil_mat_std');
save([out_path filesep 'true_sim_sil.m'], 'sil_mat');
save([out_path filesep 'sim_R.m'], 'R_mat');

%% Now do this again, but this time with limited data. If only I could parallelize this...
range_fwhm = 1:6;
range_variance = 0.05:0.05:0.3;

edge = 32;
opt_s.type = 'checkerboard';
opt_s.t = 100;
opt_s.n = edge*edge;
opt_s.nb_clusters = [4 16];

% Prepare a matrix to store the output so for visualization we can load it
% with something useful
sil_mat_mean = zeros([edge, edge, 36]);
stab_mat_mean = zeros([edge, edge, 36]);
sil_mat_std = zeros([edge, edge, 36]);
stab_mat_std = zeros([edge, edge, 36]);
R_mat = zeros([opt_s.n, opt_s.n, 36]);

count = 1;
for f_id = 1:6
    fprintf('fwhm est %d\n', f_id);
    tmp_fwhm = range_fwhm(f_id);
    for v_id = 1:6
        fprintf('    var est %d\n', v_id);
        m_sil_mat = zeros([edge, edge, iter]);
        m_stab_mat = zeros([edge, edge, iter]);
        for it = 1:iter
            tmp_var = range_variance(v_id);
            opt_s.fwhm = tmp_fwhm;
            opt_s.variance = tmp_var;

            [tseries,opt_mplm] = niak_simus_scenario(opt_s);

            part = opt_mplm.space.mpart{2};
            opt_scores.sampling.type = 'bootstrap';
            opt_scores.sampling.opt = opt_s;
            opt_scores.flag_verbose = false;
            res = niak_stability_cores(tseries,part,opt_scores);
            m_sil_mat(:,:,it) = reshape(res.stab_contrast(:, 1), [32 32]);
            m_stab_mat(:,:,it) = reshape(res.stab_maps(:, 3), [32 32]);
            
        end
    sil_mat_mean(:,:,count) = mean(m_sil_mat, 3);
    stab_mat_mean(:,:,count) = mean(m_stab_mat, 3);
    sil_mat_std(:,:,count) = std(m_sil_mat, [], 3);
    stab_mat_std(:,:,count) = std(m_stab_mat, [], 3);
    count = count + 1;
    end
end

% Save the output
save([out_path filesep 'est_mean_stab.m'], 'stab_mat_mean');
save([out_path filesep 'est_mean_sil.m'], 'sil_mat_mean');
save([out_path filesep 'est_std_stab.m'], 'stab_mat_std');
save([out_path filesep 'est_std_sil.m'], 'sil_mat_std');
save([out_path filesep 'est_sim_stab.m'], 'stab_mat');
save([out_path filesep 'est_sim_sil.m'], 'sil_mat');