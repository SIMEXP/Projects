%% Compute the ICC and generate the ICC maps for the NYU TRT data generated with 
% the new scores method
% The ICC will be calculated for each voxel across all subjects, with the
% different sessions as 'raters' or 'ratings'. Thus, the temporary storage
% must be a matrix of the form clusters x subjects x sessions x voxels. I
% will then iterate across the clusters and voxels.
%
% Of interest, the sessions are like this:
% 1. the first resting-state scan in a scan session
% 2. 5-11 months after the first resting-state scan
% 3. about 30 (< 45) minutes after 2.
% Therefore, based on Zuo2010, I will make the following comparisons:
%   - 1 v 2&3 (between sessions)
%   - 2 v 3 (within sessions)
% ______________________________________________________________________________
clear all; close all;
%% Set up paths
scales = [7];
num_scale = length(scales);
metrics = {'dual_regression', 'rmap_part', 'stability_maps'};
num_metric = length(metrics);
in_temp = '/data1/scores/retest/out_nii/sc%02d/target/';
mask_temp = '/data1/cambridge/template/template_cambridge_basc_multiscale_sym_scale%03d.nii.gz';
out_temp = '/data1/scores/retest/icc_maps/test07_2';
%% Get the files
for met_id = 1:num_metric
    metric = metrics{met_id};
    fprintf('Running %s\n', metric);
    for scale_id = 1:num_scale
        scale = scales(scale_id);
        fprintf('    @ scale %d\n', scale);
        % Set up the output path
        out_dir = sprintf(out_temp, scale, metric);
        psom_mkdir(out_dir);
        out_fig = [out_dir filesep 'figures'];
        psom_mkdir(out_fig);
        out_mat = [out_dir filesep 'matrices'];
        psom_mkdir(out_mat);
        out_vol = [out_dir filesep 'volumes'];
        psom_mkdir(out_vol);
        out_clu = [out_dir filesep 'cluster'];
        psom_mkdir(out_clu);
        % Get mask
        mask_path = sprintf(mask_temp, scale);
        [~,~,ext] = niak_fileparts(mask_path);
        [m_hdr, m_vol] = niak_read_vol(mask_path);
        mask = logical(m_vol);
        num_vox = sum(mask(:));
        % Get input dir
        in_dir = sprintf(in_temp, scale);
        in = [in_dir filesep metric];
        f = dir(in);
        in_strings = {f.name};
        in_struct = struct();
        f_count = 0;
        % Find the files
        for f_id = 1:numel(in_strings)
            in_string = in_strings{f_id};
            % Get anything with a nii.gz in the end
            [start, stop] = regexp(in_string, '\w*.nii.gz');
            [sub_start, sub_stop] = regexp(in_string, 'sub[0-9]*');
            [ses_start, ses_stop] = regexp(in_string, 'session[0-9]+');
            if ~isempty(start) && ~isempty(stop)
                f_count = f_count + 1;
                file_name = in_string(start:stop);
                sub_name = in_string(sub_start:sub_stop);
                ses_name = in_string(ses_start:ses_stop);
                in_files{f_count} = [in filesep in_string];
                in_struct.(sub_name).(ses_name) = [in filesep in_string];
            end
        end
        sub_names = fieldnames(in_struct);
        num_sub = length(sub_names);
        % Prepare storage variable
        mat = zeros(scale, num_sub, 3, num_vox);
        % Load the individual files and compute the ICC across sessions
        fprintf('      Loading files now\n');
        for sub_id = 1:num_sub
            sub_name = sub_names{sub_id};
            ses_names = fieldnames(in_struct.(sub_name));
            for ses_id = 1:3
                ses_name = ses_names{ses_id};
                path = in_struct.(sub_name).(ses_name);
                [ref_hd, vol] = niak_read_vol(path);
                for clust = 1:scale
                    net = vol(:,:,:,clust);
                    net_vec = net(mask);
                    mat(clust, sub_id, ses_id, :) = net_vec;
                end
            end   
        end
        % Now that we have them all together for one metric, run the ICC across
        % voxels for each cluster and each pair of sessions
        fprintf('      Computing ICC\n');
        icc_mat = zeros(scale, 2, num_vox);
        for clust = 1:scale
            % This is going to be hellishly slow...
            for vox_id = 1:num_vox
                session1 = squeeze(mat(clust, :, 1, vox_id))';
                within23 = squeeze(mat(clust, :, [2 3], vox_id));
                avg23 = mean(within23, 2);
                between = [session1, avg23];
                icc_within = IPN_icc(within23, 2, 'single');
                icc_between = IPN_icc(between, 2, 'single');
                icc_mat(clust, 1, vox_id) = icc_within;
                icc_mat(clust, 2, vox_id) = icc_between;
            end
        end
        % Go through the results again and bring them back into volume form and
        % save them to disk. Also make a quick montage of them and save that as
        % well.
        % Make an empty volume to store the maps in
        fprintf('       Generating Outputs\n');
        out_mat = zeros([size(mask) scale*2]);
        vol_pos = 1:2:scale*2;
        for clust = 1:scale
            pos = vol_pos(clust);
            vol_within = niak_part2vol(icc_mat(clust,1,:), mask);
            vol_between = niak_part2vol(icc_mat(clust,2,:), mask);
            % Store this in the output file
            out_mat(:,:,:,pos+0) = vol_within;
            out_mat(:,:,:,pos+1) = vol_between;
            % Make a quick montage and save this to disk
            img_name = sprintf('icc_%d_of_%d_within_%s.png', clust, scale, metric);
            img_path = [out_fig filesep img_name];
            img_opt.type_color = 'hot_cold';
            img_opt.vol_limits = [-1 1];
            clf;
            niak_montage(vol_within, img_opt);
            title(sprintf('ICC map within: net %d, scale %d, metric %s', clust, scale, metric));
            print(gcf, '-dpng', img_path);

            img_name = sprintf('icc_%d_of_%d_between_%s.png', clust, scale, metric);
            img_path = [out_fig filesep img_name];
            img_opt.type_color = 'hot_cold';
            img_opt.vol_limits = [-1 1];
            clf;
            niak_montage(vol_between, img_opt);
            title(sprintf('ICC map between: net %d, scale %d, metric %s', clust, scale, metric));
            print(gcf, '-dpng', img_path);
        end
        % Save the 4D file 
        icc_name = sprintf('zuo_icc_map_%d_sc_%d_%s%s', clust, scale, metric, ext);
        icc_path = [out_vol filesep icc_name];
        % Work around the 3D to 4D header conversion issue
        icc_hdr = ref_hd;
        icc_hdr.file_name = icc_path;
        niak_write_vol(icc_hdr, out_mat);
    end
end