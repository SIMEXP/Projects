function [infos] = fcon_get_infos(opt);

% Gets the information needed for the preprocessing of the database files.
% 
% [infos] = fcon_get_infos(database,opt)
% 
% IN:
%   opt:
%     Structure containing:
%       database:
%         Name of the database to use.
%       path_databases:
%         Path where all the databases are.
%       path_release_table:
%         Path to the release table. Use .csv file.
%       sep_char:
%         Seperation character used to read the release table file. By default: ;.
% 
% OUT:
%   infos:
%     Information matrix.
% 


gb_name_structure = 'opt';
gb_list_fields = {'database','path_databases','path_release_table','sep_char'};
gb_list_defaults = {NaN,NaN,NaN,';'};
niak_set_defaults;

if ~exist([opt.path_databases opt.database],'dir')
  error(cat(2,'Could not find specified database : ',database));
end

hf = fopen(path_release_table);
str_tab = fread(hf,Inf,'uint8=>char');
cell_tab = niak_string2lines(str_tab');
fclose(hf);

infos{1} = opt.database;
for num_s = 5:length(cell_tab')
  if exist('OCTAVE_VERSION','builtin')
    fields = strsplit(cell_tab{num_s},sep_char);
  else
    fields = regexp(cell_tab{num_s},sep_char,'split');
  end
  if (strcmpi(strrep(fields{5},'"',''),infos{1}))
    infos{2} = strrep(fields{8},'"','');  %%magnet
    infos{3} = 0;  %%dummy
    infos{4} = fields{12};   %%TR
    infos{5} = fields{13};   %%nb_slices
    infos{6} = 0;  %%delay_in_tr
    infos{7} = strrep(fields{16},'"',''); %%slice_order
    infos{8} = 'odd';
  end
end