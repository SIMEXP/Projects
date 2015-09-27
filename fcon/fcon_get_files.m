function [process_list,missing_list] = fcon_get_files(subjects,opt);

% Gets a structure of files to be used to create the pipeline using fcon_fmri_preprocess.
% 
% [process_list,missing_list] = fcon_get_files(subjects,opt)
% 
% IN:
%   subjects:
%     List of subject names, see fcon_read_demog for more information.
%   opt:
%     Structure containing:
%       path_database:
%         Database on which to execute the command.
%       max_func:
%         Maximum number of func files to use. By default: Inf
%
% OUT:
%   process_list:
%     Structure containing all anonymized and rest Minc files to be used.
%   missing_list:
%     Structure containing all anonymized and rest Minc files which were not found.
%


gb_name_structure = 'opt';
gb_list_fields = {'path_database','max_func'};
gb_list_defaults = {NaN,Inf};
niak_set_defaults;

if ~exist(path_database,'dir')
    error(cat(2,'Database could not be found : ',opt.path_database));
end
octave = 0;
if exist('OCTAVE_VERSION','builtin')
    octave = 1;
end
process_list = struct;
missing_list = struct;

for num_s = 1:length(subjects)
    anonymized = [path_database subjects{num_s} filesep 'anat' filesep 'mprage_anonymized.mnc.gz'];
    if exist(anonymized,'file')
	process_list.(subjects{num_s}).anat = anonymized;
    else
	missing_list.(subjects{num_s}).anat = anonymized;
    end
    rest = [path_database subjects{num_s} filesep 'func' filesep 'rest.mnc.gz'];
    num_r = 0;
    if exist(rest,'file')
	num_r = num_r + 1;
	if(num_r <= opt.max_func)
	    process_list.(subjects{num_s}).fmri.rest{num_r} = rest;
	end
    end
    find_path = [opt.path_database filesep subjects{num_s} filesep];
    [s,output] = system(['find ' find_path ' -maxdepth 1 -name ''func_*'' -type d']);
    if s == 0
	if octave
        funcs_undo = undo_string_escapes(output);
        funcs_rep = strrep(funcs_undo,'\n',';');
	    funcs = strsplit(funcs_rep,';');
	else
	    funcs = regexp(output,'\n','split');
	end
	for num_f = 1:length(funcs)
	    rest2 = [funcs{num_f} filesep 'rest.mnc.gz'];
	    if exist(rest2,'file')
		num_r = num_r + 1;
		if(num_r <= opt.max_func)
		    process_list.(subjects{num_s}).fmri.rest{num_r} = rest2;
		end
	    end
	end
    end
    if (num_r == 0)
	missing_list.(subjects{num_s}).fmri.rest{1} = rest;
    end
end