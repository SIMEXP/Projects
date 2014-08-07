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
out_dir = '/data1/scores/output';
psom_mkdir(out_dir);
out_fig = [out_dir filesep 'figures'];
psom_mkdir(out_fig);
out_mat = [out_dir filesep 'matrices'];
psom_mkdir(out_mat);
out_vol = [out_dir filesep 'volumes'];
psom_mkdir(out_vol);

mask_template = '/data1/scores/mask/part_sc10_resampled.nii.gz';
[~,~,ext] = niak_fileparts(mask_template);
[m_hdr, m_vol] = niak_read_vol(mask_template);
mask = logical(m_vol);
% clusters = [10, 50, 100];
clusters = [50, 100];
% For each cluster, go and pick up all the files
% Search for the files we need and build the structure
for nclust_id = 1:length(clusters)
    num_clust = clusters(nclust_id);
    
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
    for t_id = 1:num_templates
        t_name = t_names{t_id};
        fprintf('Running %s at scale %d now...\n', t_name, num_clust);
        name_subs = fieldnames(in_struct.(t_name));
        num_subs = length(name_subs);
        full_mat = [];
        icc_mat = zeros(num_clust, num_subs);
        for clust_id = 1:num_clust
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
                    net_map = v_in(:,:,:,clust_id);
                    net_masked = net_map(mask);
                    net_vec = net_masked(:);
                    clust_mat(sub_id, ses_id,:) = net_vec;
                end
            end
            % Get the number of datapoints per subject and session
            [n_sub, n_ses, n_data] = size(clust_mat);
            icc_vec = zeros(1,n_data);
            % Iterate over each data point
            for d_id = 1:n_data
                in_mat = clust_mat(:, :, d_id);
                icc = IPN_icc(in_mat, 3, 'single');
                if isnan(icc)
                    icc = 0;
                end
                icc_vec(d_id) = icc;
            end
            % Return the ICC vector to volume dimensions and save it
            icc_vol = niak_part2vol(icc_vec, mask);
            icc_name = sprintf('icc_map_net_%d_sc_%d_%s%s', clust_id, num_clust, t_name, ext);
            icc_path = [out_vol filesep icc_name];
            icc_hdr = m_hdr;
            icc_hdr.file_name = icc_path;
            niak_write_vol(icc_hdr, icc_vol);
            % Also make a montage out of the thing
            img_name = sprintf('icc_map_net_%d_sc_%d_%s.png', clust_id, num_clust, t_name);
            img_path = [out_fig filesep img_name];
            img_opt.type_color = 'hot_cold';
            clf;
            niak_montage(icc_vol, img_opt);
            title(sprintf('ICC map: net %d, scale %d, metric %s', clust_id, num_clust, t_name));
            print(gcf, '-dpng', img_path);
            
            % Also save it into the full matrix
            full_mat(clust_id, :) = icc_vec;
        end
        % Save the full matrix to disk so we can determine what to do with
        % it later
        mat_name = sprintf('full_mat_sc_%d_%s.mat', num_clust, t_name);
        mat_path = [out_mat filesep mat_name];
        save(mat_path, 'full_mat');
    end
end