%% script for overlay of boxplot with raw data points per (parcel to parcel) connection for each site

% load .mat file that came out of adnet_sc33_eff2csv.m first

clf

%% specify data
connec = 1; % specify connection (from 1:length(list_sig))
num_site = 4; % specify number of sites

% adni2 data
adni_cne = tab{2,1}(:,connec);
adni_mci = tab{3,1}(:,connec);
% criugmmci data
criugmmci_cne = tab{2,2}(:,connec);
criugmmci_mci = tab{3,2}(:,connec);
% adpd data
adpd_cne = tab{2,3}(:,connec);
adpd_mci = tab{3,3}(:,connec);
% mnimci 
mnimci_cne = tab{2,4}(:,connec);
mnimci_mci = tab{3,4}(:,connec);

data_cne = {adni_cne,criugmmci_cne,adpd_cne,mnimci_cne};
data_mci = {adni_mci,criugmmci_mci,adpd_mci,mnimci_mci};
%data_all = {data_cne,data_mci};

%% plotting raw data points for all sites for one connection
for ii = 1:length(data_cne)
    hold on
    plot(ii-0.05+0.1*rand(size(data_cne{ii},1),1),data_cne{ii}(:,connec),'.','Marker','o','MarkerSize',3,'MarkerFaceColor','red','MarkerEdgeColor','red');
    plot(ii+0.25+0.1*rand(size(data_mci{ii},1),1),data_mci{ii}(:,connec),'.','Marker','o','MarkerSize',3,'MarkerFaceColor','blue','MarkerEdgeColor','blue');
end

%% making box plots
for jj = 1:length(data_cne)
%     maxpos = size(data_cne,2);
    position_cne = linspace(1,jj,jj); % set position of cne boxes to be placed from 1 to length(data_cne)
    position_mci = position_cne+0.3; % set position of mci boxes to be shifted from cne by 0.3
    boxplot(data_cne{jj},'colors','k','width',0.18,'positions',position_cne,'symbol','');
    set(gca,'XTickLabel',{' '}) % temporarily get rid of xtick labels
    hold on
    boxplot(data_mci{jj},'colors','k','width',0.18,'positions',position_mci,'symbol',''); 
end
    
% %% box plot
% 
% 
% adni_position_cne = 1;%:1:num_sig; % set position of cne boxes to be placed from 1 to num_sig
% adni_position_mci = 1.3;%:1:num_sig+0.3; % set position of mci boxes to be shifted from cne by 0.3
% boxplot(adni_cne,'colors','k','width',0.18,'positions',1,'symbol','');
% hold on
% boxplot(adni_mci,'colors','k','width',0.18,'positions',1.3,'symbol','');
% hold on
% criugmmci_position_cne = 2;
% criugmmci_position_mci = criugmmci_position_cne+0.3;
% boxplot(criugmmci_cne,'colors','b','width',0.18,'positions',2,'symbol','');
% hold on
% boxplot(criugmmci_mci,'colors','b','width',0.18,'positions',2.3,'symbol',''); 
% 
% criugmmci_position_cne = 1:1:2;
% criugmmci_position_mci = criugmmci_position_cne+0.3;
% boxplot([criugmmci_cne,criugmmci_mci],'colors','bk','width',0.18,'positions',criugmmci_position_cne,'symbol','');
% hold on
% boxplot([criugmmci_mci,criugmmci_mci],'colors','bk','width',0.18,'positions',criugmmci_position_mci,'symbol',''); 
% 
% yy = nan(size(adni_cne));
% criugmmci_cne_b = yy(1:numel(criugmmci_cne));
% boxplot([adni_cne,criugmmci_cne_b])
% 
% 
% 
% x = [data_cne,data_mci];
% group = [1,2];
% positions = [1,2];
% boxplot(x,group,'positions',positions);

%% aesthetics
ylim([-1 1.5])
labels_sites = ['ADNI2','CRIUGMa','CRIUGMb','MNI'];
set(gca,'XTick',1.15:num_site+0.15,'XTickLabel',labels_sites) % automatically label with parcels with significant connections to seedylabel('Mean connectivity with seed','FontSize',11,'FontName','Helvetica')
xlabel('Sample','FontSize',11,'FontName','Helvetica')
legend('CN','MCI')

%print -painters -dpdf -r600 figure.pdf