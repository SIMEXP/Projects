% Twins Movie subgoups heritability 
%  EXP: test heritability of FD
clear all

% Parameters
path_root =  '/home/yassinebha/Google_Drive/twins_movie/';
path_pedigre = '~/github_repos/Projects/twins/script/models/twins_pedigre_raw_all.csv';
scrub = 'noscrub';
path_fmri = [path_root 'fmri_preprocess_' scrub filesep ];

%combine pedigre and scrubbing
master_cell = niak_read_csv_cell(path_pedigre);
master_cell{1} ='id_scan_pedig' ; 
files_out  = niak_grab_all_preprocess(path_fmri);
slave_cell = niak_read_csv_cell(files_out.quality_control.group_motion.scrubbing);
slave_cell{1}='id_scan_scrub' ; 
for cc = 1:length(slave_cell)-1;
    slave_cell{cc+1,1} = slave_cell{cc+1,1}(1:end-14);
end
combine_pedig_fd = combine_cell_tab(master_cell,slave_cell);
combine_pedig_fd(any(cellfun(@(x) any(isnan(x)),combine_pedig_fd),2),:)=[] ;%remove empty cells

%write a test csv file
niak_write_csv_cell([path_fmri 'combine_pedig_fd_test.csv'],combine_pedig_fd);

%remove unused tab
list_remove_combine_pedig_fd = { 'frames_OK','frames_scrubbed','id_scan_scrub','FD_scrubbed' };
mask_remove_combine_pedig_fd = ones(1,size(combine_pedig_fd,2));
for cc = 1: length(list_remove_combine_pedig_fd)
    mask_tmp = strfind(combine_pedig_fd(1,:),list_remove_combine_pedig_fd{cc});
    mask_tmp = cellfun(@isempty,mask_tmp);
    mask_remove_combine_pedig_fd = mask_remove_combine_pedig_fd & mask_tmp ;
end
combine_pedig_fd(:,~mask_remove_combine_pedig_fd)=[];
namesave = [path_fmri 'combine_pedig_fd_' scrub '.csv'];
niak_write_csv_cell(namesave,combine_pedig_fd);