function [databases] = fcon_get_databases(opt);

% Gets a list of databases in the specified folder.
%
% [databases] = fcon_get_databases(opt);
%
% IN:
%   opt:
%     Structure containing:
%       path_databases:
%         The specified folder to look up for databases. By default: /database/fcon_1000/.
%
% OUT:
%   databases:
%     List of databases found in the folder.
%

gb_name_structure = 'opt';
gb_list_fields = {'path_databases'};
gb_list_defaults = {'/database/fcon_1000/raw/'};
niak_set_defaults;

[status,output] = system(['find ' opt.path_databases ' -maxdepth 1 -type d']);
if status ~= 0
    return
end

num_d = 0;
octave = 0;
if exist('OCTAVE_VERSION','builtin')
    dirs_undo = undo_string_escapes(output);
    dirs_rep = strrep(dirs_undo,'\n',';');
    dirs = strsplit(dirs_rep,';');
    octave = 1;
else
    dirs = regexp(output,'\n','split');
end

for n = 1:length(dirs)
    if (~strcmpi(dirs{n},path_databases)&~isempty(dirs{n}))
        if octave
            database = strsplit(dirs{n},'/');
        else
            database = regexp(dirs{n},'/','split');
        end
        if(~strcmpi(database{end},'group_selects'))
            num_d = num_d + 1;
            databases{num_d,1} = database{end};
        end
    end
end
