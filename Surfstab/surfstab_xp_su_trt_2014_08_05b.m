% Here are the things this should do
%   - go into an output directory and pick up a specific strategy
%   - pull all outputs of that strategy that it can (stability, seed and
%     dual regression
%   - pull them all together and then calculate the ICC per subject (based
%     on a vertex by session matrix)
%   - average lthe ICC across all subjects and also build a histogram
%   - generate the similarity/distance metric for each of them based on
%     spatial correlation / euclidean distance
%   - visualize these maps
%   - perform a hierarchical clustering based on these maps
%   - store all the results in a directory that has the same name as the
%     input but is located somewhere else
%% Clear
clear;
%% Define the input data
in_dir = '/home/surchs/Projects/stability_abstract/full_run/data/sc10/stability_maps';
out_dir = '/home/surchs/Projects/stability_abstract/full_run/out';
psom_mkdir(out_dir);
clusters = [10, 50, 100];
% For each cluster, go and pick up all the files
% Search for the files we need and build the structure
for nclust_id = 1:length(clusters)
    num_clust = clusters(nclust_id);

    in_files = {};
    in_struct = struct;
    f_count = 1;

    % CBB
    in_path = [in_dir filesep sprintf('cbb_%d', num_clust) filesep 'stability_maps'];
    f = dir(in_path);
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
            in_files{f_count} = [in_path filesep in_string];
            in_struct.cbb.(sub_name).(ses_name) = [in_path filesep in_string];
            f_count = f_count + 1;
        end
    end

    % Sliding 40
    in_path = [in_dir filesep sprintf('sld_clust_%d_win_40', num_clust)];
    f = dir(in_path);
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
            in_files{f_count} = [in_path filesep in_string];
            in_struct.sld40.(sub_name).(ses_name) = [in_path filesep in_string];
            f_count = f_count + 1;
        end
    end

    % Sliding 50
    in_path = [in_dir filesep sprintf('sld_clust_%d_win_50', num_clust)];
    f = dir(in_path);
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
            in_files{f_count} = [in_path filesep in_string];
            in_struct.sld50.(sub_name).(ses_name) = [in_path filesep in_string];
            f_count = f_count + 1;
        end
    end

    % Sliding 60
    in_path = [in_dir filesep sprintf('sld_clust_%d_win_60', num_clust)];
    f = dir(in_path);
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
            in_files{f_count} = [in_path filesep in_string];
            in_struct.sld60.(sub_name).(ses_name) = [in_path filesep in_string];
            f_count = f_count + 1;
        end
    end

    % Seed Based
    in_path = [in_dir filesep sprintf('cbb_%d', num_clust) filesep 'rmap_part'];
    f = dir(in_path);
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
            in_files{f_count} = [in_path filesep in_string];
            in_struct.seed.(sub_name).(ses_name) = [in_path filesep in_string];
            f_count = f_count + 1;
        end
    end

    % Dual Regression
    in_path = [in_dir filesep sprintf('cbb_%d', num_clust) filesep 'dual_regression'];
    f = dir(in_path);
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
            in_files{f_count} = [in_path filesep in_string];
            in_struct.dual.(sub_name).(ses_name) = [in_path filesep in_string];
            f_count = f_count + 1;
        end
    end

%% Generate the case by rater matrix for ICC
    name_subs = fieldnames(in_struct);
    num_subs = length(name_subs);
    icc_mat = zeros(num_clust, num_subs);

    % CBB Stability
    for clust_id = 1:num_clust
        name_cond = 'cbb';
        for sub_id = 1:num_subs
            rate_mat = [];
            sub_name = name_subs{sub_id};
            sub_struct = in_struct.(name_cond).(sub_name);
            name_ses = fieldnames(sub_struct);
            for ses_id = 1:3
                ses_name = name_ses{ses_id};
                full_path = in_struct.(name_cond).(sub_name).(ses_name);
                % Get the file
                [h_in, v_in] = niak_read_vol(full_path);
                net_map = v_in(:,:,:,clust_id);
                net_vec = net_map(:);
                rate_mat = [rate_mat, net_vec];
            end
            % Generate the ICC for this subject
            icc = IPN_icc(rate_mat,1,'single');
            icc_mat(clust_id, sub_id) = icc;
        end
    end
    % Save the icc matrix
    mat_name = sprintf('icc_cbb_%d.png', num_clust);
    mat_path = [out_dir filesep mat_name];
    clf;
    niak_visu_matrix(icc_mat);
    title(sprintf('icc CBB @ scale %d', num_clust));
    print(gcf, '-dpng', mat_path);
    
    
    % Sliding Window Stability 40
    for clust_id = 1:num_clust
        name_cond = 'sld40';
        for sub_id = 1:num_subs
            rate_mat = [];
            sub_name = name_subs{sub_id};
            sub_struct = in_struct.(name_cond).(sub_name);
            name_ses = fieldnames(sub_struct);
            for ses_id = 1:3
                ses_name = name_ses{ses_id};
                full_path = in_struct.(name_cond).(sub_name).(ses_name);
                % Get the file
                [h_in, v_in] = niak_read_vol(full_path);
                net_map = v_in(:,:,:,clust_id);
                net_vec = net_map(:);
                rate_mat = [rate_mat, net_vec];
            end
            % Generate the ICC for this subject
            icc = IPN_icc(rate_mat,1,'single');
            icc_mat(clust_id, sub_id) = icc;
        end
    end
    % Save the icc matrix
    mat_name = sprintf('icc_sld40_%d.png', num_clust);
    mat_path = [out_dir filesep mat_name];
    clf;
    niak_visu_matrix(icc_mat);
    title(sprintf('icc Sliding Window 40 @ scale %d', num_clust));
    print(gcf, '-dpng', mat_path);
    
    % Sliding Window Stability 50
    for clust_id = 1:num_clust
        name_cond = 'sld50';
        for sub_id = 1:num_subs
            rate_mat = [];
            sub_name = name_subs{sub_id};
            sub_struct = in_struct.(name_cond).(sub_name);
            name_ses = fieldnames(sub_struct);
            for ses_id = 1:3
                ses_name = name_ses{ses_id};
                full_path = in_struct.(name_cond).(sub_name).(ses_name);
                % Get the file
                [h_in, v_in] = niak_read_vol(full_path);
                net_map = v_in(:,:,:,clust_id);
                net_vec = net_map(:);
                rate_mat = [rate_mat, net_vec];
            end
            % Generate the ICC for this subject
            icc = IPN_icc(rate_mat,1,'single');
            icc_mat(clust_id, sub_id) = icc;
        end
    end
    % Save the icc matrix
    mat_name = sprintf('icc_sld50_%d.png', num_clust);
    mat_path = [out_dir filesep mat_name];
    clf;
    niak_visu_matrix(icc_mat);
    title(sprintf('icc Sliding Window 50 @ scale %d', num_clust));
    print(gcf, '-dpng', mat_path);
    
    % Sliding Window Stability 60
    for clust_id = 1:num_clust
        name_cond = 'sld60';
        for sub_id = 1:num_subs
            rate_mat = [];
            sub_name = name_subs{sub_id};
            sub_struct = in_struct.(name_cond).(sub_name);
            name_ses = fieldnames(sub_struct);
            for ses_id = 1:3
                ses_name = name_ses{ses_id};
                full_path = in_struct.(name_cond).(sub_name).(ses_name);
                % Get the file
                [h_in, v_in] = niak_read_vol(full_path);
                net_map = v_in(:,:,:,clust_id);
                net_vec = net_map(:);
                rate_mat = [rate_mat, net_vec];
            end
            % Generate the ICC for this subject
            icc = IPN_icc(rate_mat,1,'single');
            icc_mat(clust_id, sub_id) = icc;
        end
    end
    % Save the icc matrix
    mat_name = sprintf('icc_sld60_%d.png', num_clust);
    mat_path = [out_dir filesep mat_name];
    clf;
    niak_visu_matrix(icc_mat);
    title(sprintf('icc Sliding Window 60 @ scale %d', num_clust));
    print(gcf, '-dpng', mat_path);
    
    % Seed Based
    for clust_id = 1:num_clust
        name_cond = 'seed';
        for sub_id = 1:num_subs
            rate_mat = [];
            sub_name = name_subs{sub_id};
            sub_struct = in_struct.(name_cond).(sub_name);
            name_ses = fieldnames(sub_struct);
            for ses_id = 1:3
                ses_name = name_ses{ses_id};
                full_path = in_struct.(name_cond).(sub_name).(ses_name);
                % Get the file
                [h_in, v_in] = niak_read_vol(full_path);
                net_map = v_in(:,:,:,clust_id);
                net_vec = net_map(:);
                rate_mat = [rate_mat, net_vec];
            end
            % Generate the ICC for this subject
            icc = IPN_icc(rate_mat,1,'single');
            icc_mat(clust_id, sub_id) = icc;
        end
    end
    % Save the icc matrix
    mat_name = sprintf('icc_seed_%d.png', num_clust);
    mat_path = [out_dir filesep mat_name];
    clf;
    niak_visu_matrix(icc_mat);
    title(sprintf('icc Seed @ scale %d', num_clust));
    print(gcf, '-dpng', mat_path);
    
    % Dual Regression
    for clust_id = 1:num_clust
        name_cond = 'dual';
        for sub_id = 1:num_subs
            rate_mat = [];
            sub_name = name_subs{sub_id};
            sub_struct = in_struct.(name_cond).(sub_name);
            name_ses = fieldnames(sub_struct);
            for ses_id = 1:3
                ses_name = name_ses{ses_id};
                full_path = in_struct.(name_cond).(sub_name).(ses_name);
                % Get the file
                [h_in, v_in] = niak_read_vol(full_path);
                net_map = v_in(:,:,:,clust_id);
                net_vec = net_map(:);
                rate_mat = [rate_mat, net_vec];
            end
            % Generate the ICC for this subject
            icc = IPN_icc(rate_mat,1,'single');
            icc_mat(clust_id, sub_id) = icc;
            
        end
    end
    % Save the icc matrix
    mat_name = sprintf('icc_dual_%d.png', num_clust);
    mat_path = [out_dir filesep mat_name];
    clf;
    niak_visu_matrix(icc_mat);
    title(sprintf('icc Dual Regression @ scale %d', num_clust));
    print(gcf, '-dpng', mat_path);
    
end