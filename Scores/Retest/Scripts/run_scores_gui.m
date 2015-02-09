clear;
% Paths are for Mammouth atm
in_path = '/gs/scratch/surchs/nyu_trt/data/fmri/';
part_path = '/gs/project/gsf-624-aa/database2/cambridge_template/templates/template_cambridge_basc_multiscale_sym_scale007.nii.gz';
out_path = ['/gs/project/gsf-624-aa/database2/cambridge_template/templates' filesep 'sc36/'];
search_pattern = 'fmri_sub[0-9]*_session[0-9]+_rest.mnc.gz';
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
            [start, stop] = regexp(dir_string, search_pattern);
            if ~isempty(start) && ~isempty(stop)
                [~, fname, ~] = niak_fileparts(dir_string(start:stop));
                sub_name = [dir_name '_' fname];
		in_files.fmri.(sub_name) = [tmp_path filesep dir_string];
                a = [in_path filesep in_string];
            end
        end
    else
        [start, stop] = regexp(in_string, search_pattern);
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
% Compute the number of matched files
fnames = fieldnames(in_files.fmri);
numf = length(fnames);
disp(sprintf('I found %d files in %s.\n', numf, in_path));
opt.psom.max_queued = 100;
opt.scores.flag_target = true;
opt.scores.flag_deal = true;
% Remove the number of subjects for debugging
fprintf('To make debugging easier, I will remove most of the subjects again\n');
fn = fieldnames(in_files.fmri);
in_files.fmri = rmfield(in_files.fmri, fn(5:end));

disp('Running the pipeline now.')
%pipeline = niak_pipeline_stability_scores(in_files, opt);
