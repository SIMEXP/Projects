clear all;
% Find the subclusters of the cambridge template
in_dir = '/data1/cambridge/template/';
temp = [niak_full_path(in_dir) 'template_cambridge_basc_multiscale_sym_scale%03d.nii.gz'];
% template scale 7
t7 = sprintf(temp, 7);
% template scale 12
t12 = sprintf(temp, 12);

% Subclusters 20 - 64
sc_list = [20, 36, 64, 122];

% Do this for scale 7
for sc = sc_list
    % Set up the files
    files_in = struct('cluster', t7, 'subcluster', sprintf(temp, sc));
    files_out = struct;
    opt = struct('folder_out', niak_full_path([niak_full_path(in_dir), sprintf('sc%03d_overlap', sc)]));
    niak_brick_subclusters(files_in, files_out, opt);
end

% And also for scale 12
for sc = sc_list
    % Set up the files
    files_in = struct('cluster', t12, 'subcluster', sprintf(temp, sc));
    files_out = struct;
    opt = struct('folder_out', niak_full_path([niak_full_path(in_dir), sprintf('sc%03d_overlap', sc)]));
    niak_brick_subclusters(files_in, files_out, opt);
end