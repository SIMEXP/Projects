function [subjects] = fcon_read_demog(file_name)

% Reads the demographics file and output useful information in a matrix.
% 
% [subjects] = fcon_read_demog(file_name)
% 
% IN:
%   file_name:
%     Path to the demographics file of a database.
% 
% OUT:
%   subjects:
%     Matrix with database information for all subjects according to demographics file.
% 

if ~exist(file_name,'file')
    error(cat(2,'Could not find any file matching the description ',file_name));
end

%% Reading the table
hf = fopen(file_name);
str_tab = fread(hf,Inf,'uint8=>char')';
cell_tab = niak_string2lines(str_tab);
fclose(hf);

%% Reading the lines and seperating in to specified lists.
for num_v = 1:length(cell_tab)
  if exist('OCTAVE_VERSION','builtin')
    line_undo = undo_string_escapes(cell_tab{num_v});
    line_rep = strrep(line_undo,'\t',';');
    line_tmp = strsplit(line_rep,';');
  else
    line_tmp = regexp(cell_tab{num_v},'\t','split');
  end
  nb_col = length(line_tmp);
  subjects{num_v,1} = line_tmp{1};
  subjects{num_v,2} = line_tmp{2};
  subjects{num_v,3} = line_tmp{3};
  subjects{num_v,4} = line_tmp{4};
  if nb_col >= 5
    subjects{num_v,5} = line_tmp{5};
  end
end