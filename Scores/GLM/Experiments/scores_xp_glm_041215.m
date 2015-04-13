%% The purpose of this script is to run a GLM on the preprocessed files of the 
% Scores pipeline using the Abide dataset. This is still an evaluation of
% the scores method and therefore belongs here and not in the Abide
% project.
clear all; close all;
%% Define the paths
use = 'time';

show = false;
store = true;
sub_list = '/data1/abide/Pheno/subjects.csv';
f_seed_path = sprintf('/data1/scores/glm/abide/seed_paths_%s.csv', use);
f_scores_path = sprintf('/data1/scores/glm/abide/scores_paths_%s.csv', use);
f_dual_path = sprintf('/data1/scores/glm/abide/dual_paths_%s.csv', use);
mask_path = '/data1/cambridge/template/template_mask.nii.gz';
glm_path = '/data1/scores/glm/abide/glm_abide.mat';
project_path = '/data1/scores/glm/abide';
fig_path = [project_path filesep 'figures'];
psom_mkdir(fig_path);
vol_path = [project_path filesep 'volumes'];
psom_mkdir(vol_path);

scale = 7;
%% Load the things
% Load the subject list
subjects = niak_string2lines(fread(fopen(sub_list), Inf, 'uint8=>char')');
seed_paths = niak_string2lines(fread(fopen(f_seed_path), Inf, 'uint8=>char')');
scores_paths = niak_string2lines(fread(fopen(f_scores_path), Inf, 'uint8=>char')');
dual_paths = niak_string2lines(fread(fopen(f_dual_path), Inf, 'uint8=>char')');
n_subs = length(subjects);
% Load the mask
[mhdr, mask] = niak_read_vol(mask_path);
n_voxl = sum(mask(:));
long_mask = repmat(mask, 1,1,1, scale);
% Load the glm model
tmp = load(glm_path, 'glm');
X = tmp.glm;
%% Now get the subjects and run (away)
y_seed_name = sprintf('abide_y_seed_%s_scale_%d.mat', use, scale);
y_seed_path = [project_path filesep y_seed_name];

y_scores_name = sprintf('abide_y_scores_%s_scale_%d.mat', use, scale);
y_scores_path = [project_path filesep y_scores_name];

y_dual_name = sprintf('abide_y_dual_%s_scale_%d.mat', use, scale);
y_dual_path = [project_path filesep y_dual_name];
if ~exist(y_seed_path, 'file') || ~exist(y_scores_path, 'file') || ~exist(y_dual_path, 'file')
    fprintf('I need to generate \n');
    % Build the samples for the three metrics
    Y_seed = zeros(n_subs, n_voxl, scale);
    Y_scores = zeros(n_subs, n_voxl, scale);
    Y_dual = zeros(n_subs, n_voxl, scale);
    for sid = 1:n_subs
        path_seed = seed_paths{sid};
        path_scores = scores_paths{sid};
        path_dual = dual_paths{sid};
        sub = subjects{sid};
        % Get the volume
        [~, seed] = niak_read_vol(path_seed);
        [~, scores] = niak_read_vol(path_scores);
        [~, dual] = niak_read_vol(path_dual);
        % Mask the volume
        vec_seed = seed(logical(long_mask));
        vec_scores = scores(logical(long_mask));
        vec_dual = dual(logical(long_mask));
        % Reshape that long nothing into something
        vec_res_seed = reshape(vec_seed, n_voxl, scale);
        vec_res_scores = reshape(vec_scores, n_voxl, scale);
        vec_res_dual = reshape(vec_dual, n_voxl, scale);
        % Store it in the Y
        Y_seed(sid, :, :) = vec_res_seed;
        Y_scores(sid, :, :) = vec_res_scores;
        Y_dual(sid, :, :) = vec_res_dual;
    end
    % Now save that gargantuan thing
    save(y_seed_path, 'Y_seed', '-v7.3');
    save(y_scores_path, 'Y_scores', '-v7.3');
    save(y_dual_path, 'Y_dual', '-v7.3');
else
    % It's already there, just pick it up
    fprintf('Already there, I am loading it\n');
    load(y_seed_path);
    load(y_scores_path);
    load(y_dual_path);
end
%% Now run a number of models and see where this gets us
names = {
        'intercept',...
        'sex',...
        'diag',...
        'age',...
        'mean_fd',...
        'MAX_MUN',...
        'UCLA_2',...
        'SBL',...
        'PITT',...
        'UCLA_1',...
        'CMU',...
        'NYU',...
        'SDSU',...
        'KKI',...
        'USM',...
        'OLIN',...
        'LEUVEN_2',...
        'OHSU',...
        'STANFORD',...
        'CALTECH'
        };
for network = 1:7
    fprintf('Running Network %d F-Test now\n', network);
    con = zeros(19,1);
    con(5:end) = 1;
    q = 0.01;
    opt_v.vol_limits = [0 10];

    glm_seed.x = X;
    glm_seed.y = Y_seed(:,:,network);
    glm_seed.c = con;

    glm_scores.x = X;
    glm_scores.y = Y_scores(:,:,network);
    glm_scores.c = con;

    glm_dual.x = X;
    glm_dual.y = Y_dual(:,:,network);
    glm_dual.c = con;

    opt.test = 'ttest';
    opt.flag_beta = true;

    results_seed = niak_glm(glm_seed, opt);
    results_scores = niak_glm(glm_scores, opt);
    results_dual = niak_glm(glm_dual, opt);

    % Do FDR correction on the p-values
    [~, test_seed] = niak_fdr(results_seed.pce, 'BH', q);
    [~, test_dual] = niak_fdr(results_dual.pce, 'BH', q);
    [~, test_scores] = niak_fdr(results_scores.pce, 'BH', q);

    % take -log10 of the pvalues (independent of FDR)
    lp_seed = -log10(results_seed.pce);
    lp_scores = -log10(results_scores.pce);
    lp_dual = -log10(results_dual.pce);
    lp_seed(isnan(lp_seed)) = 0;
    lp_seed(isinf(lp_seed)) = 0;
    
    lp_scores(isnan(lp_scores)) = 0;
    lp_scores(isinf(lp_scores)) = 0;
    
    lp_dual(isnan(lp_dual)) = 0;
    lp_dual(isinf(lp_dual)) = 0;

    % Make the maps and add the p-values where appropriate
    map_seed = zeros(size(mask));
    map_scores = zeros(size(mask));
    map_dual = zeros(size(mask));

    map_seed(logical(mask)) = test_seed;
    map_scores(logical(mask)) = test_scores;
    map_dual(logical(mask)) = test_dual;

    map_seed(map_seed == 1) = lp_seed(logical(test_seed));
    map_scores(map_scores == 1) = lp_scores(logical(test_scores));
    map_dual(map_dual == 1) = lp_dual(logical(test_dual));
    
    if store
        thdr = mhdr;
        
        m1_name = sprintf('f_test_n_%d_seed_%s.mat', network, use);
        n1_name = sprintf('f_test_n_%d_seed_%s.nii.gz', network, use);
        m1_path = [vol_path filesep m1_name];
        n1_path = [vol_path filesep n1_name];
        
        thdr.file_name = n1_path;
        niak_write_vol(thdr, map_seed);
        save(m1_path, 'map_seed');
        
        m2_name = sprintf('f_test_n_%d_scores_%s.mat', network, use);
        n2_name = sprintf('f_test_n_%d_scores_%s.nii.gz', network, use);
        m2_path = [vol_path filesep m2_name];
        n2_path = [vol_path filesep n2_name];
        
        thdr.file_name = n2_path;
        niak_write_vol(thdr, map_scores);
        save(m2_path, 'map_scores');
        
        m3_name = sprintf('f_test_n_%d_dual_%s.mat', network, use);
        n3_name = sprintf('f_test_n_%d_dual_%s.nii.gz', network, use);
        m3_path = [vol_path filesep m3_name];
        n3_path = [vol_path filesep n3_name];
        
        thdr.file_name = n3_path;
        niak_write_vol(thdr, map_dual);
        save(m3_path, 'map_dual');
        
    end

    if show
        f1 = figure(1);
        niak_montage(map_seed);
        title(sprintf('Network %d: seed (%s) F-Test', network, use));
        f1_name = sprintf('f_test_n_%d_seed_%s.png', network, use);
        f1_path = [fig_path filesep f1_name];
        print(f1, f1_path, '-dpng');
        
        f2 = figure(2);
        niak_montage(map_scores);
        title(sprintf('Network %d: scores (%s) F-Test', network, use));
        f2_name = sprintf('f_test_n_%d_scores_%s.png', network, use);
        f2_path = [fig_path filesep f2_name];
        print(f2, f2_path, '-dpng');
        
        f3 = figure(3);
        niak_montage(map_dual);
        title(sprintf('Network %d: dual regression (%s) F-Test', network, use));
        f3_name = sprintf('f_test_n_%d_dual_%s.png', network, use);
        f3_path = [fig_path filesep f3_name];
        print(f3, f3_path, '-dpng');
    end
end
