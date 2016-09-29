function files = fcon_grab_raw(path_read)

%% Minimal graber for the 1000 functional connectome database
if nargin < 1
    path_read = pwd;
end

%path_read = niak_full_path(path_read);

list_files = dir(path_read);

for num_f = 1:length(list_files)
    if list_files(num_f).isdir && ~strcmp(list_files(num_f).name,'.') && ~strcmp(list_files(num_f).name,'..')
        fprintf('%s\n',list_files(num_f).name)
        subject = list_files(num_f).name;
        files.(subject).anat = [path_read subject filesep 'anat' filesep  'mprage_anonymized.mnc.gz'];
        files.(subject).fmri.session1.rest = [path_read filesep subject filesep 'func' filesep 'rest.mnc.gz'];
    end
end
