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
out_dir = '/data1/scores/test_output_3';
psom_mkdir(out_dir);
out_fig = [out_dir filesep 'figures'];
psom_mkdir(out_fig);
out_mat = [out_dir filesep 'matrices'];
psom_mkdir(out_mat);
out_vol = [out_dir filesep 'volumes'];
psom_mkdir(out_vol);
out_clu = [out_dir filesep 'cluster'];
psom_mkdir(out_clu);
out_net = [out_dir filesep 'network'];
psom_mkdir(out_net);

mask_template = '/data1/scores/mask/part_sc10_resampled.nii.gz';
[~,~,ext] = niak_fileparts(mask_template);
[m_hdr, m_vol] = niak_read_vol(mask_template);
mask = logical(m_vol);
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
    acc_mat = [];
    tpr_mat = [];
    spc_mat = [];
    for t_id = 1:num_templates
        t_name = t_names{t_id};
        fprintf('Running %s at scale %d now...\n', t_name, num_clust);
        name_subs = fieldnames(in_struct.(t_name));
        num_subs = length(name_subs);
        full_mat = [];
        icc_mat = zeros(num_clust, num_subs);
        for clust_id = 1:num_clust
            sort_mat = [];
            clust_mat = [];
            for sub_id = 1:num_subs
                sub_name = name_subs{sub_id};
                sub_struct = in_struct.(t_name).(sub_name);
                name_ses = fieldnames(sub_struct);
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
                    sort_mat(sub_id, ses_id,:) = net_vec;
                    clust_mat(:, end+1) = net_vec;
                end
            end
            % Get the number of datapoints per subject and session
            [n_sub, n_ses, n_data] = size(sort_mat);
            % Set up a matrix with vectors for all three combinations of
            % sessions
            icc_mat = zeros(n_data, 3);
            % Iterate over each data point
            for d_id = 1:n_data
                in_mat = sort_mat(:, :, d_id);
                % Session 1 + Session 2
                ses_mat = in_mat(:, [1 2]);
                icc_mat(d_id, 1) = niak_build_correlation(in_mat(:, [1 2]), true);
                icc_mat(d_id, 2) = niak_build_correlation(in_mat(:, [1 3]), true);
                icc_mat(d_id, 3) = niak_build_correlation(in_mat(:, [2 3]), true);
            end
            % Calculate the average stability map
            avg_map = mean(clust_mat, 2);
            std_map = std(clust_mat, 0, 2);
            % Return all the ICC vectors to volume dimensions and save it
            icc_vol12 = niak_part2vol(icc_mat(:,1), mask);
            icc_vol13 = niak_part2vol(icc_mat(:,2), mask);
            icc_vol23 = niak_part2vol(icc_mat(:,3), mask);
            % Do the same for the average maps
            avg_vol = niak_part2vol(avg_map, mask);            
            std_vol = niak_part2vol(std_map, mask);
            % Prepare a folder to keep these things in
            dump_folder = [out_net filesep sprintf('scale_%d', num_clust) filesep sprintf('netw_%d', clust_id)];
            psom_mkdir(dump_folder);
            % Also make a montage out of the things
            img_name = sprintf('avg_map_%s.png', t_name);
            img_path = [dump_folder filesep img_name];
            img_opt.type_color = 'hot_cold';
            clf;
            niak_montage(avg_vol, img_opt);
            title(sprintf('AVG map: metric %s', t_name));
            print(gcf, '-dpng', img_path);
            
            img_name = sprintf('std_map_%s.png', t_name);
            img_path = [dump_folder filesep img_name];
            img_opt.type_color = 'hot_cold';
            clf;
            niak_montage(std_vol, img_opt);
            title(sprintf('STD map: metric %s', t_name));
            print(gcf, '-dpng', img_path);
            
            img_name = sprintf('icc_map_12_%s.png', t_name);
            img_path = [dump_folder filesep img_name];
            img_opt.type_color = 'hot_cold';
            clf;
            niak_montage(icc_vol12, img_opt);
            title(sprintf('ICC map 12: metric %s', t_name));
            print(gcf, '-dpng', img_path);
            
            img_name = sprintf('icc_map_13_%s.png', t_name);
            img_path = [dump_folder filesep img_name];
            img_opt.type_color = 'hot_cold';
            clf;
            niak_montage(icc_vol13, img_opt);
            title(sprintf('ICC map 13: metric %s', t_name));
            print(gcf, '-dpng', img_path);
            
            img_name = sprintf('icc_map_23_%s.png', t_name);
            img_path = [dump_folder filesep img_name];
            img_opt.type_color = 'hot_cold';
            clf;
            niak_montage(icc_vol23, img_opt);
            title(sprintf('ICC map 23: metric %s', t_name));
            print(gcf, '-dpng', img_path);
            
            % Also take the data point by subject map and build a
            % similarity and a distance matrix from it
            mat_sim = niak_build_correlation(clust_mat);
            mat_dis = niak_build_distance(clust_mat);
            % Calculate the ratio of within vs between similarity for each
            % subject. We need these plots:
            %   - are subjects worse for certain metrics? -> average across
            %   all networks per subject over subjects, different colors
            %   for metric
            %   - are subjects worse for certain networks? -> average
            %   across all subjects across networks, different colors for
            %   metric
            for m_id = [1:3:3*num_subs]
                % Take a slice of the matrix
                sub_sim = mat_sim(:,m_id:m_id+2);
                within = sub_sim(m_id:m_id+2,:);
                % Mask it
                within = within(logical(tril(ones(3),-1)));
                between = sub_sim([1:m_id-1 m_id+3:end]);
                between = between(:);
                ratio = mean(within)/mean(between);
            end
            
            
            % Count how many scans were successfully computed per subject.
            % Here we are looking for the specificity, sensitivity and
            % accuracy:
            %   - TPR = TP/(TP+FN)
            %   - SPC = TN/(FP+TN)
            %   - ACC = (TP + TN)/(P + N)
            % Again, we can report these values in the same way as the
            % ratios
            
            
            % Cluster the subjects based on these two matrices
            hier_sim = niak_hierarchical_clustering(mat_sim);
            hier_dis = niak_hierarchical_clustering(-mat_dis);
            opt.thresh = 25;
            part_sim = niak_threshold_hierarchy(hier_sim, opt);
            part_dis = niak_threshold_hierarchy(hier_dis, opt);
            % Visualize the clustering
            clust_sim = niak_part2mat(part_sim);
            clust_dis = niak_part2mat(part_dis);
            
            img_name = sprintf('clust_map_net_%d_sc_%d_%s.png', clust_id, num_clust, t_name);
            img_path = [dump_folder filesep img_name];
            clf;
            vopt.color_map = niak_hot_cold();
            subplot(2,2,1), niak_visu_matrix(mat_sim, vopt);
            subplot(2,2,2), niak_visu_matrix(mat_dis, vopt);
            subplot(2,2,3), niak_visu_matrix(clust_sim);
            subplot(2,2,4), niak_visu_matrix(clust_dis);
            
            suptitle(sprintf('Clustering of Network %d at scale %d with %s', clust_id, num_clust, t_name));
            print(gcf, '-dpng', img_path);
        end
    end
end