clear all

addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-boss-0.13.4/'))

addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak_dev_git/extensions/surfstab/'))

%changed to suit nki_multimodal_fiftyplus starting with scale 7
in_path = '/gs/project/gsf-624-aa/abadhwar/NKI_fiftyplus_preprocessed2_with_niakissue100/fmri_preprocess_all_scrubb05/fmri/';
part_path = '/gs/project/gsf-624-aa/database2/preventad/templates/template_cambridge_basc_multiscale_sym_scale007.mnc.gz';
out_path = '/gs/project/gsf-624-aa/abadhwar/NKI_fiftyplus_scores_s007_20160126/'; % s12 s20 s36

%changed to reflect nki_multimodal_fiftyplus
file_template = 'fmri_s[0-9]*_sess1_rest[0-9]*.mnc.gz';
files_include = {'sess1'};

%changed to reflect nki_multimodal_fiftyplus
files_reject = {'s0101463', 's0130716', 's0144495', 's0175151'};


% Search for the files we need and build the structure
f = dir(in_path);
[~, path_name, ~] = niak_fileparts(in_path);
in_strings = {f.name};
in_strings = in_strings(3:end);
in_files.fmri = struct;

%
for f_id = 1:numel(in_strings)
    in_string = in_strings{f_id};
    tmp_path = [in_path filesep in_string];
    [start, stop] = regexp(in_string, file_template);
    if ~isempty(start) && ~isempty(stop)
        [~, fname, ~] = niak_fileparts(in_string(start:stop));
        % See if it is in the exclusion list
        get_it = 1;
        for rej_id = 1:length(files_reject)
            rej_name = files_reject{rej_id};
            if findstr(rej_name,fname)
                get_it = 0;
            else
            end
        end
        if get_it == 1
            sub_name = [path_name '_' fname];
            in_files.fmri.(fname) = [in_path filesep in_string];
            a = [in_path filesep in_string];
        else
            fprintf('We do not like subject %s\n',fname);
        end
    end
end
    


in_files.part = part_path;
opt.folder_out = out_path;
% Compute the number of matched files
fnames = fieldnames(in_files.fmri);
numf = length(fnames);
disp(sprintf('I found %d files in %s.\n', numf, in_path));
opt.psom.max_queued = 300;
opt.scores.flag_target = true;
opt.scores.flag_deal = true;
disp('Running the pipeline now.')
pipeline = niak_pipeline_stability_scores(in_files, opt);
