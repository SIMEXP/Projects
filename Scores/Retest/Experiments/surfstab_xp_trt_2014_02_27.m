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
in_dir = '/data1/scores/retest/out/sc07';
out_dir = '/data1/scores/retest/out/newtest/dual';
psom_mkdir(out_dir);
out_fig = [out_dir filesep 'figures'];
psom_mkdir(out_fig);
out_mat = [out_dir filesep 'matrices'];
psom_mkdir(out_mat);
out_vol = [out_dir filesep 'volumes'];
psom_mkdir(out_vol);
out_clu = [out_dir filesep 'cluster'];
psom_mkdir(out_clu);

mask_template = '/data1/cambridge/template/template_cambridge_basc_multiscale_sym_scale007.nii.gz';
[~,~,ext] = niak_fileparts(mask_template);
[m_hdr, m_vol] = niak_read_vol(mask_template);
mask = logical(m_vol);
% clusters = [10, 50, 100];
clusters = [7];
metric = 'dual_regression';
%% Alright, let's do this again clean
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
%% Now load all this and do the cluster and then show it to me
num_subs = length(fieldnames(in_struct));
num_vox = sum(mask(:));
all_arr = zeros(num_subs*3, num_vox, clusters);
for file_id = 1:f_count
    in_file = in_files{file_id};
    [~, vol] = niak_read_vol(in_file);
    for clust = 1:clusters
        net_map = vol(:,:,:,clust);
        net_mask = net_map(mask);
        all_arr(file_id,:,clust) = net_mask;
    end
end
% Cluster this stuff
for clust = 1:clusters
    mat_sim = niak_build_correlation(all_arr(:,:,clust)');
    mat_dis = niak_build_distance(all_arr(:,:,clust)');
    hier_sim = niak_hierarchical_clustering(mat_sim);
    hier_dis = niak_hierarchical_clustering(-mat_dis);
    opt.thresh = 25;
    part_sim = niak_threshold_hierarchy(hier_sim, opt);
    part_dis = niak_threshold_hierarchy(hier_dis, opt);
    clust_sim = niak_part2mat(part_sim);
    clust_dis = niak_part2mat(part_dis);
    img_name = sprintf('clust_map_net_%d_%s.png', clust, metric);
    img_path = [out_fig filesep img_name];
    clf;
    vopt.color_map = niak_hot_cold();
    subplot(2,2,1), niak_visu_matrix(mat_sim, vopt);
    subplot(2,2,2), niak_visu_matrix(mat_dis, vopt);
    subplot(2,2,3), niak_visu_matrix(clust_sim);
    subplot(2,2,4), niak_visu_matrix(clust_dis);

    suptitle(sprintf('Clustering of Network %d with %s', clust, metric));
    print(gcf, '-dpng', img_path);
end