clear;
% Paths are for Mammouth atm
in_path = '/data1/abide/Full/abide_release_sym_gsc0_lp01/Stanford';
part_path = '/data1/abide/Mask/basc_group_masks/stability_group/part_sc10_resampled.nii.gz';
out_path = '/data1/abide/Test/Out';
% Search for the files we need and build the structure
f = dir(in_path);
in_strings = {f.name};
in_files.fmri = struct;
for f_id = 1:numel(in_strings)
    in_string = in_strings{f_id};
    [start, stop] = regexp(in_string, '[0-9]*_session_[0-9]+_run[0-9]+.nii.gz');
    if ~isempty(start) && ~isempty(stop)
        [~, fname, ~] = niak_fileparts(in_string(start:stop));
        sub_name = ['sub_' fname];
        in_files.fmri.(sub_name) = [in_path filesep in_string];
        a = [in_path filesep in_string];
        % Only do it once for testing purposes
        break
    end
end

in_files.part = part_path;
debug.fmri = {a};
debug.part = part_path;
dbg.flag_target = true;
dbg.flag_rois = true;
dbg.flag_deal = true;
dbg.folder_out = out_path;
out = struct;

opt.folder_out = out_path;
opt.scores.flag_deal = true;
opt.psom.max_queued = 1;
opt.scores.flag_target = true;
disp('Running the pipeline now.')
niak_brick_scores_fmri(debug, out, dbg);
% niak_pipeline_stability_scores(in_files, opt)