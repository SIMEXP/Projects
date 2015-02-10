% Sebastian (sebastian (dot) urchs (at) gmail (dot) com)
% Test the simulation with the new scores implementation
% The goal is to 
%   first run the 'true' stability maps
%   second run the 'estimated' stability maps
%% Let's go
clear;

out_path = '/data1/scores/visualization_dump';
psom_set_rand_seed(0);

edge = 32; % Number of voxels along one side of the checkerboard

%% Now iterate across a number of combinations of sampling parameters and save the output
% 6 steps each
range_fwhm = 1:6;
range_variance = 0.05:0.05:0.3;

edge = 32;
opt_s.type = 'checkerboard';
opt_s.t = 100;
opt_s.n = edge*edge;
opt_s.nb_clusters = [4 16];

% Prepare a matrix to store the output so for visualization we can load it
% with something useful
sil_mat = zeros([edge, edge, 36]);
stab_mat = zeros([edge, edge, 36]);
R_mat = zeros([opt_s.n, opt_s.n, 36]);

count = 1;
for f_id = 1:6
    tmp_fwhm = range_fwhm(f_id);
    for v_id = 1:6
        tmp_var = range_variance(v_id);
        opt_s.fwhm = tmp_fwhm;
        opt_s.variance = tmp_var;
        
        [tseries,opt_mplm] = niak_simus_scenario(opt_s);
        
        R = niak_build_correlation(tseries);
        hier = niak_hierarchical_clustering(R);
        order = niak_hier2order(hier);

        part = opt_mplm.space.mpart{2};
        opt_scores.sampling.type = 'scenario';
        opt_scores.sampling.opt = opt_s;
        res = niak_stability_cores(tseries,part,opt_scores);
        sil_mat(:,:,count) = reshape(res.stab_contrast(:, 1), [32 32]);
        stab_mat(:,:,count) = reshape(res.stab_maps(:, 3), [32 32]);
        R_mat(:,:,count) = R(order, order);
        count = count + 1;
    end
end

% Save the output
save([out_path filesep 'true_sim_stab.m'], 'stab_mat');
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
sil_mat = zeros([edge, edge, 36]);
stab_mat = zeros([edge, edge, 36]);

count = 1;
for f_id = 1:6
    tmp_fwhm = range_fwhm(f_id);
    for v_id = 1:6
        tmp_var = range_variance(v_id);
        opt_s.fwhm = tmp_fwhm;
        opt_s.variance = tmp_var;
        
        [tseries,opt_mplm] = niak_simus_scenario(opt_s);

        part = opt_mplm.space.mpart{2};
        opt_scores.sampling.type = 'bootstrap';
        res = niak_stability_cores(tseries,part,opt_scores);
        sil_mat(:,:,count) = reshape(res.stab_contrast(:, 1), [32 32]);
        stab_mat(:,:,count) = reshape(res.stab_maps(:, 3), [32 32]);
        count = count + 1; 
    end
end

% Save the output
save([out_path filesep 'est_sim_stab.m'], 'stab_mat');
save([out_path filesep 'est_sim_sil.m'], 'sil_mat');
