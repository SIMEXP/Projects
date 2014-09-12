% Here are the things this should do:
% Run a pipeline for each of the following outputs
%   - CBB
%   - Sliding Window (length 40, 50, 60)
%   - Dual Regression
% At each of the following scales:
%   - Cambridge 10
%   - Cambridge 50
%   - Cambridge 100
% The entire thing should be able to run in one go.

%% Input
in_data = '/home/surchs/Projects/stability_abstract/data/trt';
out_data = '/home/surchs/Projects/stability_abstract/test_dump';
psom_mkdir(out_data);
in_cluster = '/home/surchs/Projects/stability_abstract/mask/';
cluster_temp = 'part_sc%d_resampled.nii.gz';
clusters = [10, 50, 100];
windows = [40, 50, 60];

% Assemble the input structure for the pipeline
f = dir(in_data);
in_strings = {f.name};
in_files.fmri = struct;
for f_id = 1:numel(in_strings)
    in_string = in_strings{f_id};
    [start, stop] = regexp(in_string, 'sub[0-9]*_session[0-9]+');
    if ~isempty(start) && ~isempty(stop)
        sub_name = in_string(start:stop);
        in_files.fmri.(sub_name) = [in_data filesep in_string];
    end
end
%% Generate the pipeline
meta_pipe = struct;
meta_opt.max_queued = 6;
meta_opt.path_logs = [out_data filesep 'logs'];
meta_opt.flag_pause = false;

%% Iterate the cluster levels
for clust_id = 1:length(clusters)
    clust_num = clusters(clust_id);
    clust_name = sprintf(cluster_temp, clust_num);
    clust_path = [in_cluster filesep clust_name];

    %% CBB
    cbb_out = sprintf('cbb_%d', clust_num);
    cbb_folder = [out_data filesep cbb_out];
    psom_mkdir(cbb_folder);
    
    cbb_in.fmri = in_files.fmri;
    cbb_in.part = clust_path;

    cbb_opt.folder_out = cbb_folder;
    cbb_opt.flag_test = true;
    cbb_opt.scores.sampling.type = 'CBB';
    cbb_opt.scores.sampling.opt = struct;
    cbb_opt.scores.type_center = 'median';
    
    cbb_pipe = niak_pipeline_stability_scores(cbb_in, cbb_opt);
    
    % Add CBB to pipeline
    meta_pipe = psom_merge_pipeline(meta_pipe, cbb_pipe, [cbb_out '_']);
    
    %% Sliding Window
    for win_id = 1:length(windows);
        win = windows(win_id);
        
        sld_out = sprintf('sld_clust_%d_win_%d', clust_num, win);
        sld_folder = [out_data filesep sld_out];
        psom_mkdir(sld_folder);

        sld_in.fmri = in_files.fmri;
        sld_in.part = clust_path;
        
        sld_opt.folder_out = sld_folder;
        sld_opt.flag_test = true;
        % No need to generate these files again, we have them from CBB
        sld_opt.files_out.dual_regression = false;
        sld_opt.files_out.rmap_part = false;
        sld_opt.scores.sampling.type = 'window';
        sld_opt.scores.sampling.opt.length = win;
        sld_opt.scores.type_center = 'median';
        
        sld_pipe = niak_pipeline_stability_scores(sld_in, sld_opt);
        
        % Add sliding window to pipeline
        meta_pipe = psom_merge_pipeline(meta_pipe, sld_pipe, [sld_out '_']);
        
    end
end
disp('I am done here');