%%Scores tutorial
clear all;
close all;
%% Get the files
% Get the func data
if ~psom_exist('single_subject_cambridge_preprocessed_nii')
    system('wget http://www.nitrc.org/frs/download.php/6784/single_subject_cambridge_preprocessed_nii.zip')
    system('unzip single_subject_cambridge_preprocessed_nii.zip')
    psom_clean('single_subject_cambridge_preprocessed_nii.zip')
end
% Get the template
if ~psom_exist('template_cambridge_basc_multiscale_nii_sym')
    system('wget http://files.figshare.com/1861819/template_cambridge_basc_multiscale_nii_sym.zip')
    system('unzip template_cambridge_basc_multiscale_nii_sym.zip')
    psom_clean('template_cambridge_basc_multiscale_nii_sym.zip')
end
%% Create the input for the scores pipeline
in_path = [pwd filesep 'single_subject_cambridge_preprocessed_nii'];
part_path = [pwd filesep 'template_cambridge_basc_multiscale_nii_sym' filesep 'template_cambridge_basc_multiscale_sym_scale012.nii.gz'];
out_path = [pwd filesep 'output'];
% This search pattern can be useful, if you have a lot of input files but
% only want to capture some. Check help regexp for details
search_pattern = 'fmri_sub[0-9]*_session[0-9]+_rest.nii.gz';
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
opt.psom.max_queued = 1;
opt.scores.flag_target = true;
opt.scores.flag_deal = true;
%% Run the pipeline
disp('Running the pipeline now.')
pipeline = niak_pipeline_stability_scores(in_files, opt);
%% Take a look at the outputs - once the pipeline has completed!
stab_path = [out_path filesep 'stability_maps' filesep 'single_subject_cambridge_preprocessed_nii_fmri_sub00156_session_stability_maps.nii.gz'];
% The output file is organized by networks. Since we used 12 template
% networks, there will be 12 3D blocks stacked along the 4th dimension
[~, stab] = niak_read_vol(stab_path);
% Let's take a look at network 5 for example
net = 5;
scores_f = figure;
niak_montage(stab(:,:,:,net));
title(sprintf('scores network %d', net));
% For comparison, we can also take a look at the seed map of network 5
seed_path = [out_path filesep 'rmap_part' filesep 'single_subject_cambridge_preprocessed_nii_fmri_sub00156_session_rmap_part.nii.gz'];
[~, seed] = niak_read_vol(seed_path);
seed_f = figure;
niak_montage(seed(:,:,:,net));
title(sprintf('seed network %d', net));