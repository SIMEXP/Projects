clear;
% Paths are for Mammouth atm
in_path = '/data1/abide/Full/abide_release_sym_gsc0_lp01';
part_path = '/data1/abide/Mask/basc_group_masks/stability_group/part_sc10_resampled.nii.gz';
out_path = '/data1/abide/Test/Testrun';
% Search for the files we need and build the structure
f = dir(in_path);
[~, path_name, ~] = niak_fileparts(in_path);
in_strings = {f.name};
in_strings = in_strings(3:end);
in_files.fmri = struct;
for f_id = 1:numel(in_strings)
    in_string = in_strings{f_id};
    tmp_path = [in_path filesep in_string];
    if isdir(tmp_path)
        % This is a subdirectory, we should see if there are other files inside
        [~, dir_name, ~] = niak_fileparts(tmp_path);
        f_dir = dir(tmp_path);
        dir_strings = {f_dir.name};
        for fd_id = 1:numel(dir_strings)
            dir_string = dir_strings{fd_id};
            [start, stop] = regexp(dir_string, '[0-9]*_session_[0-9]+_run[0-9]+.nii.gz');
            if ~isempty(start) && ~isempty(stop)
                [~, fname, ~] = niak_fileparts(dir_string(start:stop));
                sub_name = [dir_name '_' fname];
                disp(sub_name);
		disp([tmp_path filesep dir_string]);
		in_files.fmri.(sub_name) = [tmp_path filesep dir_string];
                a = [in_path filesep in_string];
                % Only do it once for testing purposes
                break
            end
        end
    else
        [start, stop] = regexp(in_string, '[0-9]*_session_[0-9]+_run[0-9]+.nii.gz');
        if ~isempty(start) && ~isempty(stop)
            [~, fname, ~] = niak_fileparts(in_string(start:stop));
            sub_name = [path_name '_' fname];
            in_files.fmri.(sub_name) = [in_path filesep in_string];
            a = [in_path filesep in_string];
        end
    end
end

in_files.part = part_path;
opt.folder_out = out_path;
opt.psom.max_queued = 6;
opt.scores.flag_target = true;
opt.scores.flag_deal = true;
disp('Running the pipeline now.')
niak_pipeline_stability_scores(in_files, opt)
