
% graber for individual subtypes weight for heritabylity analysis 
clear
path_root =  '/media/yassinebha/database2/Google_Drive/twins_movie/';
path_subtypes     =[path_root 'stability_fir_all_sad_blocs_EXP2_test2/'];
path_fmri    =[path_root 'fmri_preprocess_EXP2_test2'];
path_pedigre = '~/github_repos/Projects/twins/script/models/twins_pedigre_raw_all.csv';
path_out     = [path_root 'stability_fir_all_sad_blocs_EXP2_test2/'];
scale =  'sci20_scg16_scf17';
load ([path_subtypes 'fir_shape_subtypes_weights_scale_' scale '_all_networks.mat'])
nb_subtypes = nb_clust; % the nember of subtypes 
num_scale = str2num(scale(strfind(scale,'scf')+3:end));
fir_norm = 'shape';
scrub = '_noscrub';


%IF  flg_fd = true  it remove subjects with FD higher than max_fd (section not completed)
flag_fd = false
max_fd = 4 ; % maximum FD allowed
list_subj =fir_sub.labels_x;
if flag_fd == true
    list_out  = niak_grab_all_preprocess([path_root 'fmri_preprocess_EXP2_test2']);
    list_scrub = niak_read_csv_cell(list_out.quality_control.group_motion.scrubbing);
    for nn = 1:length(list_subj)
        subject = list_subj{nn};
        file_extra   = [path_fmri filesep 'fmri/fmri_' subject '_session1_run1_extra.mat'];
        extra        = load(file_extra); % Load the scrubbing masks
        file_fir     = [path_fir filesep subject_file];
        ind_fir      = load([path_fir filesep subject_file]); % Load the individual fir
        scales       = fieldnames(ind_fir);
        if (ind_fir.(scales{1}).nb_fir_tot == 0) || (sum(extra.mask_suppressed(end-size(ind_fir.(scales{1}).fir_mean,1)+1:end)) > max_scrub) %
           list_subj{nn}='';
        end
    end
    list_subj(cellfun(@isempty,list_subj)) = [];   %remove empty cells 
end

%% Loop over individual fir and grab the subtypes all networks


nt = num_scale; % nb of clusters
nn = nb_subtypes+1; % nb of subtypes       
sub_weights.(scales).label_x= fir_sub.labels_x;
sub_weights.(scales).label_y= cell(1,((length(fir_sub.labels_y)-1)*num_scale)+1); %empty cell for label_y
for cc = 1:nn
for tt = 1:nt 
     sub_weights.(scales).label_y{1,nt*(cc -1) + tt + 1} = sprintf('clust_%i_v%i', cc, tt); % write subsequent clusters headers
end
for ss = 1:length(list_ind) %% list of network


    %% fill table
    for zz = 1:length(scales)
        fir.(scales{zz})(xx+1,:)= [ {subject} num2cell(ind_fir.(scales{zz}).fir_mean(:)')]; % fill table for each scale
    end

end    

%write each scale cells to a .csv file
for dd = 1:length(scales)
    namesave = ['fir_' scales{dd} '.csv'];
    fir_mean = fir.(scales{dd});
    niak_write_csv_cell (namesave,fir_mean);
    niak_combine = niak_combine_csv_cell(namesave,path_pedigre);
    niak_write_csv_cell ([path_out 'niak_combine_scan_pedig_' scales{dd} '_' exp '.csv'],niak_combine);
    system([ 'scp -r ' path_out 'niak_combine_scan_pedig_' scales{dd} '_' exp '.csv noisetier:~/Dropbox/twins_fir_heritability/.'])
end
delete fir_sci*; % remove temporary  files
