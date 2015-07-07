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

figure

%% adni2 subplot
subplot(4,1,1) 
adni_cne = tab{2,1};
adni_mci = tab{3,1};

% plotting raw data points
for num_sig = 1:size(adni_cne,2)
    hold on
    adni_plot_cne = plot(num_sig-0.05+0.1*rand(size(adni_cne,1),1),adni_cne(:,num_sig),'.','Marker','o','MarkerSize',5,'MarkerFaceColor','red','MarkerEdgeColor','red');
    adni_plot_mci = plot(num_sig+0.25+0.1*rand(size(adni_mci,1),1),adni_mci(:,num_sig),'.','Marker','o','MarkerSize',5,'MarkerFaceColor','blue','MarkerEdgeColor','blue');
end

% making box plots
adni_position_cne = 1:1:num_sig; % set position of cne boxes to be placed from 1 to num_sig
adni_position_mci = 1.3:1:num_sig+0.3; % set position of mci boxes to be shifted from cne by 0.3
adni_box_cne = boxplot(adni_cne,'colors','k','width',0.18,'positions',adni_position_cne,'symbol','');
set(gca,'XTickLabel',{' '}) % temporarily get rid of xtick labels
hold on
adni_box_mci = boxplot(adni_mci,'colors','k','width',0.18,'positions',adni_position_mci,'symbol',''); 

% aesthetics
ylim auto
labels_parcels = {list_sig(1:num_sig)}; 
set(gca,'XTick',1.15:num_sig+0.15,'XTickLabel',labels_parcels) % automatically label with parcels with significant connections to seed
title('ADNI2') % first subplot title

%% criugmmci subplot
subplot(4,1,2)
criugmmci_cne = tab{2,2};
criugmmci_mci = tab{3,2};

% plotting raw data points
for num_sig = 1:size(criugmmci_cne,2)
    hold on
    criugmmci_plot_cne = plot(num_sig-0.05+0.1*rand(size(criugmmci_cne,1),1),criugmmci_cne(:,num_sig),'.','Marker','o','MarkerSize',5,'MarkerFaceColor','red','MarkerEdgeColor','red');
    criugmmci_plot_mci = plot(num_sig+0.25+0.1*rand(size(criugmmci_mci,1),1),criugmmci_mci(:,num_sig),'.','Marker','o','MarkerSize',5,'MarkerFaceColor','blue','MarkerEdgeColor','blue');
end

% making box plots
criugmmci_position_cne = 1:1:num_sig; % set position of cne boxes to be placed from 1 to num_sig
criugmmci_position_mci = 1.3:1:num_sig+0.3; % set position of mci boxes to be shifted from cne by 0.3
criugmmci_box_cne = boxplot(criugmmci_cne,'colors','k','width',0.18,'positions',criugmmci_position_cne,'symbol','');
set(gca,'XTickLabel',{' '}) % temporarily get rid of xtick labels
hold on
criugmmci_box_mci = boxplot(criugmmci_mci,'colors','k','width',0.18,'positions',criugmmci_position_mci,'symbol',''); 

% aesthetics
ylim auto
labels_parcels = {list_sig(1:num_sig)}; 
set(gca,'XTick',1.15:num_sig+0.15,'XTickLabel',labels_parcels) % automatically label with parcels with significant connections to seed
title('CRIUGMa') % second subplot title

%% adpd subplot
subplot(4,1,3)
adpd_cne = tab{2,3};
adpd_mci = tab{3,3};

% plotting raw data points
for num_sig = 1:size(adpd_cne,2)
    hold on
    adpd_plot_cne = plot(num_sig-0.05+0.1*rand(size(adpd_cne,1),1),adpd_cne(:,num_sig),'.','Marker','o','MarkerSize',5,'MarkerFaceColor','red','MarkerEdgeColor','red');
    adpd_plot_mci = plot(num_sig+0.25+0.1*rand(size(adpd_mci,1),1),adpd_mci(:,num_sig),'.','Marker','o','MarkerSize',5,'MarkerFaceColor','blue','MarkerEdgeColor','blue');
end

% making box plots
adpd_position_cne = 1:1:num_sig; % set position of cne boxes to be placed from 1 to num_sig
adpd_position_mci = 1.3:1:num_sig+0.3; % set position of mci boxes to be shifted from cne by 0.3
adpd_box_cne = boxplot(adpd_cne,'colors','k','width',0.18,'positions',adpd_position_cne,'symbol','');
set(gca,'XTickLabel',{' '}) % temporarily get rid of xtick labels
hold on
adpd_box_mci = boxplot(adpd_mci,'colors','k','width',0.18,'positions',adpd_position_mci,'symbol',''); 

% aesthetics 
ylim auto
labels_parcels = {list_sig(1:num_sig)};
set(gca,'XTick',1.15:num_sig+0.15,'XTickLabel',labels_parcels) % automatically label with parcels with significant connections to seed
title('CRIUGMb') % third subplot title

%% mnimci subplot
subplot(4,1,4)
mnimci_cne = tab{2,4};
mnimci_mci = tab{3,4};

% plotting raw data points
for num_sig = 1:size(mnimci_cne,2)
    hold on
    mnimci_plot_cne = plot(num_sig-0.05+0.1*rand(size(mnimci_cne,1),1),mnimci_cne(:,num_sig),'.','Marker','o','MarkerSize',5,'MarkerFaceColor','red','MarkerEdgeColor','red');
    mnimci_plot_mci = plot(num_sig+0.25+0.1*rand(size(mnimci_mci,1),1),mnimci_mci(:,num_sig),'.','Marker','o','MarkerSize',5,'MarkerFaceColor','blue','MarkerEdgeColor','blue');
end

% making box plots
mnimci_position_cne = 1:1:num_sig; % set position of cne boxes to be placed from 1 to num_sig
mnimci_position_mci = 1.3:1:num_sig+0.3; % set position of mci boxes to be shifted from cne by 0.3
mnimci_box_cne = boxplot(mnimci_cne,'colors','k','width',0.18,'positions',mnimci_position_cne,'symbol','');
set(gca,'XTickLabel',{' '}) % temporarily get rid of xtick labels
hold on
mnimci_box_mci = boxplot(mnimci_mci,'colors','k','width',0.18,'positions',mnimci_position_mci,'symbol',''); 

% aesthetics 
ylim auto
labels_parcels = {list_sig(1:num_sig)};
set(gca,'XTick',1.15:num_sig+0.15,'XTickLabel',labels_parcels) % automatically label with parcels with significant connections to seed
title('MNI') % fourth subplot title

%% other aesthetics of whole figure
ylabel('Mean connectivity with seed','FontSize',11,'FontName','Helvetica')
xlabel('Parcel','FontSize',11,'FontName','Helvetica')
legend('CN','MCI')


