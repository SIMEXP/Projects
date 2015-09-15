
% graber for individual subtypes weight for heritabylity analysis 
clear
path_root =  '/media/yassinebha/database2/Google_Drive/twins_movie/';
scale =  'sci10_scg7_scf6';
fir_norm = 'shape';
scrub = 'noscrub';
path_pedigre = '~/github_repos/Projects/twins/script/models/twins_pedigre_raw_all.csv';
path_fmri    =[path_root 'fmri_preprocess_' ];
path_subtypes     =[path_root 'stability_fir_all_sad_blocs_' scrub '_' fir_norm '/'];
load ([path_subtypes 'fir_' fir_norm '_subtypes_weights_scale_' scale '_all_networks.mat'])
path_out     = [path_root 'stability_fir_all_sad_blocs_' scrub '_' fir_norm '/'];
nb_subtypes = nb_clust; % the nember of subtypes 
num_scale = str2num(scale(strfind(scale,'scf')+3:end));



%IF  flg_fd = true  it remove subjects with FD higher than max_fd (section not completed)
flag_fd = false
max_fd = 4 ; % maximum FD allowed
list_subj =fir_sub.labels_x;
if flag_fd == true
    list_out  = niak_grab_all_preprocess([path_root 'fmri_preprocess_' scrub '_' fir_norm ]);
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

%Concatenate networks then combine with pedigree
%% fill header 
sub_weights.(scale).label_x= fir_sub.labels_x;
sub_weights.(scale).label_y= cell(1,((length(fir_sub.labels_y)-1)*num_scale)+1); %empty cell for label_y
sub_weights.(scale).label_y{1} = fir_sub.labels_y{1};
net_label_y={};
net_tmp = {};
tab_tmp = [];
tab = []
for ll = 1:length(list_ind)
      net_tmp = strcat(['net_' num2str(list_ind(ll))],'_',fir_sub.labels_y(1,2:end));
      net_label_y = [net_label_y net_tmp];
      tab_tmp = fir_sub.(['net_' num2str(list_ind(ll))]);
      tab = [tab tab_tmp ];
end
sub_weights.(scale).label_y(2:end) = net_label_y;
sub_weights.(scale).tab = tab;
%% Combine weghts and pedigree 
tab_head = vertcat( sub_weights.(scale).label_y , [ sub_weights.(scale).label_x' num2cell(tab)] );
pedigree = niak_read_csv_cell(path_pedigre);
cell_combin = combine_cell_tab(tab_head,pedigree);
namesave = [ 'combine_scan_pedig_fir_' fir_norm '_subtypes_weights_scale_' scale '.csv'];
niak_write_csv_cell([path_out namesave],cell_combin)