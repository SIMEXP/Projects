clear all;


% Paths
in_dir = '/data1/scores/retest/out/sc07';
mask_template = '/data1/cambridge/template/template_cambridge_basc_multiscale_sym_scale007.nii.gz';
sub_f = '/data1/scores/retest/out/subjects.txt';
f_sub = fopen(sub_f, 'r');
subjects = textscan(f_sub, repmat('%s', 1, 25), 'delimiter', ',');
num_subs = length(subjects);
[~,~,ext] = niak_fileparts(mask_template);
[m_hdr, m_vol] = niak_read_vol(mask_template);
mask = logical(m_vol);
% Options
clusters = 7;
metric = 'stability_maps';
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
        in_struct.(sub_name).(ses_name) = [in filesep in_string];
    end
end

% Now load all this and do the cluster and then show it to me
num_subs = length(fieldnames(in_struct));
num_vox = sum(mask(:));
all_array = zeros(num_subs*3, num_vox, clusters);
% Iterate over the subjects
count = 1;
for sub_id = 1:num_subs
    sub = subjects{sub_id}{1};
    sub_struct = in_struct.(sub);
    % Get sessions
    for s_id = 1:3
        s_name = sprintf('session%d',s_id);
        in_file = sub_struct.(s_name);
        [~, vol] = niak_read_vol(in_file);
        for clust = 1:clusters
            net_map = vol(:,:,:,clust);
            net_mask = net_map(mask);
            all_array(count,:,clust) = net_mask;
        end
        count = count + 1;
    end
end
