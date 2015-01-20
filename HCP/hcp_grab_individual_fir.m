
% graber for individual fir for heritabylity analysis
clear
%on Peuplier
%  path_fir  = '/media/database3/twins_study/stability_fir_exp1/stability_group/fir/';

task  = 'motor';
exp   = 'hcp_perc';
trial = 'rh';
path_fir = '/media/database8/HCP_task/stability_fir_perc_MOTORrh_hcp_all_sub/stability_group/fir';
path_out = '/media/database8/HCP_heritability/';

delete ([path_fir filesep 'octave-core']);

%set subject list and discard empty subject from the list
list_subj = dir(path_fir);
list_subj = {list_subj(3:end).name};
for nn = 1:length(list_subj)
    subject_file = strtrim(list_subj{nn});
    subject      = strrep(strrep(subject_file,'.mat',''),'fir_group_level_','');
    file_fir     = [path_fir filesep subject_file];
    ind_fir      = load([path_fir filesep subject_file]); % Load the individual fir
    scales       = fieldnames(ind_fir);
    if (ind_fir.(scales{1}).nb_fir_tot == 0)
       list_subj{nn}='';
    end
end
list_subj(cellfun(@isempty,list_subj)) = [];   %remove empty cells 

%% Loop over individual fir and grab the firs for all scales
for xx = 1:length(list_subj)
    subject_file  = strtrim(list_subj{xx});
    subject       = strrep(strrep(subject_file,'.mat',''),'fir_group_level_','');
    file_fir      = [path_fir filesep subject_file];
    ind_fir       = load(file_fir); %% Load the individual fir
    scales        = fieldnames(ind_fir);
    %% prepare empty tables and headers
    if xx == 1 
       for ss = 1:length(scales) %% nb of scales used
           nt = size(ind_fir.(scales{ss}).fir_mean,1); % nb of times points
           nn = size(ind_fir.(scales{ss}).fir_mean,2); % nb of clusters           
           fir.(scales{ss})= cell( length(list_subj)+1, nn*nt+1); % setting empty table for each scale
           fir.(scales{ss}){1,1}= 'id_subj';
           for cc = 1:nn
              for tt = 1:nt 
                  fir.(scales{ss}){1,nt*(cc -1) + tt + 1} = sprintf('clust_%i_v%i', cc, tt); % write subsequent clusters headers
              end
           end
       end     
    end
    %% fill table
    for zz = 1:length(scales)
        fir.(scales{zz})(xx+1,:)= [ {subject} num2cell(ind_fir.(scales{zz}).fir_mean(:)')]; % fill table for each scale
    end

end    

%%%%%%%pedigree builder%%%%%%%%
%keep only twins in pedigree
csv_cell = niak_read_csv_cell ([ '/media/database8/RESTRICTED_HCP/RESTRICTED_yassinebha_1_6_2015_14_22_6.csv' ]);
data = csv_cell(2:end,:)(strcmp('Twin',csv_cell(2:end,3)),:);
tmp_cell = cell([size(data)(1)+1 size(data)(2)]);
tmp_cell(1,:) = csv_cell(1,:);
tmp_cell(2:end,:) = data;
csv_cell = tmp_cell;
% add HCP suffic in subject ID
for ii = 2:length(csv_cell)
    csv_cell{ii,1} = sprintf('HCP%s',csv_cell{ii,1});
end
%write pedigree
niak_write_csv_cell ( [path_out 'hcp_pedigre_clean.csv'] , csv_cell );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%write each scale cells to a .csv file
for dd = 1:length(scales)
    namesave = [path_out 'fir_' task '_' trial '_' scales{dd} '_' exp '.csv'];
    fir_mean = fir.(scales{dd});
    niak_write_csv_cell (namesave,fir_mean);
    niak_combine = niak_combine_csv_cell(namesave,[path_out 'hcp_pedigre_clean.csv']);
    niak_write_csv_cell ([path_out 'niak_combine_scan_pedig_' task '_' trial '_' scales{dd} '_' exp '.csv'],niak_combine);
    system([ 'scp -r ' path_out 'niak_combine_scan_pedig_'  task '_' trial '_' scales{dd} '_' exp '.csv noisetier:~/Dropbox/HCP_fir_heritability/.'])
end
delete (['fir_' task '_'trial '_sci*']); % remove temporary  files
