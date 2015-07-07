clear

%% This script shows how to extract the connectivity values for different contrasts and seeds in the ADNET analysis.

% this will write a csv for seeds of interest
clear all

%% Parameters
path_data = '/home/atam/database/adnet/results/main_results/';
list_seed = [2; 9; 10; 22]; % select seed of interest 
scale = 'sci35_scg35_scf33'; % select scale
list_contrast = { 'ctrlvsmci' , 'avg_ctrl' , 'avg_mci' }; % list the contrasts of interest
list_site = { 'adni2' , 'criugmmci' , 'adpd' , 'mnimci' }; % list of the sites.

for num_seed = 1:length(list_seed)
    seed = list_seed(num_seed);
    file_res = [path_data 'adnet_main_results_seed' sprintf('%i',seed) '.mat'];

    %% First read the networks and find a few significant seeds
    [hdr,netwk] = niak_read_vol([path_data 'glm30b_pooled_nii_' scale filesep 'networks_' scale '.nii.gz']);
    [hdr,tmap1] = niak_read_vol([path_data 'glm30b_pooled_nii_' scale filesep list_contrast{1} filesep 'fdr_' list_contrast{1} '_' scale '.nii.gz']);
    list_sig = unique(netwk((tmap1(:,:,:,seed)~=0))); % List of parcels with significant findings for the selected seed in the MCI-CNE contrast
    for num_sig = 1:length(list_sig)
        labels_sig{num_sig} = sprintf('%i',list_sig(num_sig));
    end

    %% Extract the info for each contrast
    tab = cell(length(list_contrast),length(list_site));
    for num_c = 1:length(list_contrast)
        for num_s = 1:length(list_site)
            contrast = list_contrast{num_c};
            site = list_site{num_s};
            file_glm = [path_data 'glm30b_' site '_nii_' scale filesep contrast filesep 'glm_' contrast '_' scale '.mat'];
            data = load(file_glm);
            y = data.model_group.y; % a subject x connections array
            list_subject{num_c,num_s} = data.model_group.labels_x;
            tab{num_c,num_s} = zeros([size(y,1) length(list_sig)]);
            for num_subj = 1:length(list_subject{num_c,num_s})
                % Extract the vectorized connectome
                conn_v = y(num_subj,:);
                % Convert into a square matrix
                conn = niak_lvec2mat(conn_v);
                tab{num_c,num_s}(num_subj,:) = conn(list_sig,seed);
            end
        end
    end

    save(file_res,'tab','list_site','list_contrast','list_subject','list_sig');
end

%% to do the plots (overlay of boxplot with raw data points)
% adni2
data_cne = tab{2,1};
data_mci = tab{3,1};

% plotting raw data points
clf
for num_sig = 1:size(data_cne,2)
    hold on
    plot_cne = plot(num_sig-0.05+0.1*rand(size(data_cne,1),1),data_cne(:,num_sig),'.','Marker','o','MarkerSize',5,'MarkerFaceColor','red','MarkerEdgeColor','red');
    plot_mci = plot(num_sig+0.25+0.1*rand(size(data_mci,1),1),data_mci(:,num_sig),'.','Marker','o','MarkerSize',5,'MarkerFaceColor','blue','MarkerEdgeColor','blue');
end

% making box plots
position_cne = 1:1:num_sig; % set position of cne boxes to be placed from 1 to num_sig
position_mci = 1.3:1:num_sig+0.3; % set position of mci boxes to be shifted from cne by 0.3
box_cne = boxplot(data_cne,'colors','r','width',0.18,'positions',position_cne,'symbol','');
set(gca,'XTickLabel',{' '}) % temporarily get rid of xtick labels
hold on
box_mci = boxplot(data_mci,'colors','b','width',0.18,'positions',position_mci,'symbol',''); 

% other aesthetics of figure
ylim auto
labels_parcels = {list_sig(1:num_sig)}; 
set(gca,'XTick',1.15:num_sig+0.15,'XTickLabel',labels_parcels) % automatically label with parcels with significant connections to seed
ylabel('Mean connectivity with seed (ADNI2)','FontSize',11,'FontName','Helvetica')
xlabel('Parcel','FontSize',11,'FontName','Helvetica')
legend('CN','MCI')


