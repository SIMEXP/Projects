function [] = fcon_group_select(files_in,files_out,opt);

% Get multiple database age selections.
% 
% [] = fcon_group_select(files_in,files_out,opt);
% 
% files_in : vector containing name of chosen databases to select from.
% files_out : string to which save the files. (Do not include extensions.)
% opt : structure containing :
%     flag_nohist : 0 to create the histogram, 1 to not create.
%     databases_path : path to all databases.
% 
gb_name_structure = 'opt';
gb_list_fields = {'flag_nohist','databases_path'};
gb_list_defaults = {0,'/home/pbellec/database/fcon_1000/raw/'};
niak_set_defaults;

if ~isvector('files_in')|~exist('files_in','var')
    error('Files_in should be a structure containing specific database names');
end

groups = [];

for num_i = 1:length(files_in)
    path = [databases_path files_in{num_i} '/' files_in{num_i} '_demographics.txt'];
    if ~exist(path,'file')
	warning(['Database ' files_in{num_i} ' could not be found.']);
    else
	subjects = fcon_read_demog(path);
	groups = [groups;subjects(1:end,1:4)];
    end
end

if length(groups)~=0
    opt_select.flag_nohist = opt.flag_nohist;
    opt_select.image_path = [opt.databases_path 'group_selects/' files_out '.png'];
    opt_select.diary_path = [opt.databases_path 'group_selects/' files_out '.txt'];
    fcon_select(groups,opt_select);
else
    error('No subjects in the groups, or an error occured.');
end