function files_out = fcon_basc_get_files(files_in,opt);

% Gets a structure of files to be used to use with fcon_basc_group.
% 
% [files_out] = fcon_basc_get_files(files_in,opt)
% 
% IN:
%   files_in:
%     Structure containing:
%       databases:
%         List of databases to use.
%       path_databases:
%         Path to databases. (Default: '/database/fcon_1000/')
%   opt:
%     max_func:
%       Maximum number of func files to use. (Default: Inf)
%
% OUT:
%   files_out:
%     Structure of files to be used in niak_pipeline_basc_group.

gb_name_structure = 'files_in';
gb_list_fields = {'databases','path_databases'}
gb_list_defaults = {[],'/database/fcon_1000/'}
niak_set_defaults;

gb_name_structure = 'opt';
gb_list_fields = {'max_func'};
gb_list_defaults = {Inf};
niak_set_defaults;

octave = 0;
if exist('OCTAVE_VERSION','builtin')
    octave = 1;
end

files_out = struct;

for num_d = 1:length(files_in.databases)
    path_subjects = [files_in.path_databases filesep 'raw' filesep files_in.databases{num_d} filesep 'output' filesep 'subjects.mat'];
    if exist(path_subjects,'file')
	load(path_subjects);
    else
	warning(['Subjects file for database ' files_in.databases{num_d} ' could not be found. Ignoring database.']);
	continue;
    end
    for num_s = 1:length(subjects)
	rest = [files_in.path_databases filesep 'preprocessed' filesep files_in.databases{num_d} filesep 'smooth_vol' filesep subjects{num_s} filesep 'rest_a_mc_f_p_res_s.mnc.gz'];
	if exist(rest,'file')
	    files_out.data.(subjects{num_s}).fmri{1} = rest;
	    files_out.data.(subjects{num_s}).extra.gender = upper(subjects{num_s,4});
	    files_out.data.(subjects{num_s}).extra.age = subjects{num_s,3};
	else
	    warning(['Smooth Volume for subject ' subjects{num_s} ' of databases ' files_in.databases{num_d} ' could not be found. Ignoring subject.']);
	end
    end
end