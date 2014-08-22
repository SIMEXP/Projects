% Here are the things this should do
%   - go into an output directory and pick up a specific strategy
%   - pull all outputs of that strategy that it can (stability, seed and
%     dual regression
%   - pull them all together and then calculate the ICC per subject (based
%     on a vertex by session matrix)
%   - average the ICC across all subjects and also build a histogram
%   - generate the similarity/distance metric for each of them based on
%     spatial correlation / euclidean distance
%   - visualize these maps
%   - perform a hierarchical clustering based on these maps
%   - store all the results in a directory that has the same name as the
%     input but is located somewhere else
%% Clear
clear;
%% Define the input data
in_dir = '/data1/scores/all_out';
out_dir = '/data1/scores/test_output_6';
psom_mkdir(out_dir);
out_fig = [out_dir filesep 'figures'];
psom_mkdir(out_fig);

mask_template = '/data1/scores/mask/part_sc10_resampled.nii.gz';
[~,~,ext] = niak_fileparts(mask_template);
[m_hdr, m_vol] = niak_read_vol(mask_template);
mask = logical(m_vol);

target_subs = [8, 22];
% clusters = [10, 50, 100];
clusters = [10];
% For each cluster, go and pick up all the files
% Search for the files we need and build the structure
for nclust_id = 1:length(clusters)
    num_clust = clusters(nclust_id);

%                     {[in_dir filesep sprintf('cbb_%d', num_clust) filesep 'stability_contrast'], 'cbb_contrast'},...
%                     {[in_dir filesep sprintf('sld_clust_%d_win_40', num_clust) filesep 'stability_contrast'], 'sld40'},...
%                     {[in_dir filesep sprintf('sld_clust_%d_win_50', num_clust) filesep 'stability_contrast'], 'sld50'},...
%                     {[in_dir filesep sprintf('sld_clust_%d_win_60', num_clust) filesep 'stability_contrast'], 'sld60'},...
    
    in_templates = {{[in_dir filesep sprintf('cbb_%d', num_clust) filesep 'stability_maps'], 'cbb'},...
                    {[in_dir filesep sprintf('sld_clust_%d_win_40', num_clust) filesep 'stability_maps'], 'sld40'},...
                    {[in_dir filesep sprintf('sld_clust_%d_win_50', num_clust) filesep 'stability_maps'], 'sld50'},...
                    {[in_dir filesep sprintf('sld_clust_%d_win_60', num_clust) filesep 'stability_maps'], 'sld60'},...
                    {[in_dir filesep sprintf('cbb_%d', num_clust) filesep 'rmap_part'], 'seed'},...
                    {[in_dir filesep sprintf('cbb_%d', num_clust) filesep 'dual_regression'], 'dual'}};
    num_templates = length(in_templates);

    in_files = {};
    t_names = {};
    in_struct = struct;
    f_count = 1;
    
    % Go through the different inputs we are interested in
    for t_id = 1:num_templates
        t_temp = in_templates{t_id};
        t_path = t_temp{1};
        t_name = t_temp{2};
        t_names{end+1} = t_name;
        
        f = dir(t_path);
        in_strings = {f.name};
        for f_id = 1:numel(in_strings)
            in_string = in_strings{f_id};
            % Get anything with a nii.gz in the end
            [start, stop] = regexp(in_string, '\w*.nii.gz');
            [sub_start, sub_stop] = regexp(in_string, 'sub[0-9]*');
            [ses_start, ses_stop] = regexp(in_string, 'session[0-9]+');
            if ~isempty(start) && ~isempty(stop)
                file_name = in_string(start:stop);
                sub_name = in_string(sub_start:sub_stop);
                ses_name = in_string(ses_start:ses_stop);
                in_files{f_count} = [t_path filesep in_string];
                in_struct.(t_name).(sub_name).(ses_name) = [t_path filesep in_string];
                f_count = f_count + 1;
            end
        end
    end

    %% Generate the case by rater matrix for ICC
    % Loop through the different input files again
    [acc_sim_mat, tpr_sim_mat, spc_sim_mat] = deal([]);
    [acc_dis_mat, tpr_dis_mat, spc_dis_mat] = deal([]);
    [intra_sim_mat, inter_sim_mat, sim] = deal([]);
    [intra_dis_mat, inter_dis_mat, dis] = deal([]);
    for t_id = 1:num_templates
        t_name = t_names{t_id};
        fprintf('Running %s at scale %d now...\n', t_name, num_clust);
        name_subs = fieldnames(in_struct.(t_name));
        num_subs = length(name_subs);
        [acc_sim_tmp, tpr_sim_tmp, spc_sim_tmp] = deal(zeros(num_clust, num_subs));
        [acc_dis_tmp, tpr_dis_tmp, spc_dis_tmp] = deal(zeros(num_clust, num_subs));
        [intra_sim_tmp, inter_sim_tmp, sim_tmp] = deal([]);
        [intra_dis_tmp, inter_dis_tmp, dis_tmp] = deal([]);
        [icc_mat] = deal(zeros(num_clust, num_subs));
        
        for clust_id = 1:num_clust
            fprintf('   Running cluster %d with %s now\n', clust_id, t_name);
            comp_data = cell(2,3);
            hit = 1;
            for sub_id = 1:num_subs
                if any(sub_id == target_subs)
                    sub_name = name_subs{sub_id};
                    sub_struct = in_struct.(t_name).(sub_name);
                    name_ses = fieldnames(sub_struct);
                    ses_files = {};
                    for ses_id = 1:3
                        ses_name = name_ses{ses_id};
                        full_path = in_struct.(t_name).(sub_name).(ses_name);
                        % Get the file
                        [h_in, v_in] = niak_read_vol(full_path);
                        if size(v_in, 2) > 3
                            net_map = v_in(:,:,:,clust_id);
                        else
                            net_map = v_in;
                        end
                        net_masked = net_map(mask);
                        net_vec = net_masked(:);
                        comp_data{hit, ses_id} = net_vec;
                        hit = hit + 1;
                    end
                else
                    continue
                end
            end
            % Now we have the match of the current 
            disp(size(comp_data));
            data = reshape(comp_data', 1, 6);
            fig_path = [out_fig filesep sprintf('comp_%dv%d_net_%d_meth_%s_sc_%d.png', target_subs(1), target_subs(2), clust_id, t_name, num_clust)];
            clf;
            % Plot the montages
            for plot_id = 1:6
                subplot(2,3,plot_id);
                niak_montage(niak_part2vol(data{plot_id}), mask);
            end
            print(gcf, '-dpng', fig_path);
        end
    end
end
