%% script for overlay of boxplot with raw data points per (parcel to parcel) connection for each site

clear all

load adnet_main_results_seed22 % load .mat file that came out of adnet_sc33_eff2csv.m first

fig1 = figure('position',[0 0 600 800]); % set figure to specific size
set(fig1,'PaperPositionMode','auto'); % To keep the custom figure settings
%set(fig1,'PaperOrientation','landscape');

%% specify data
connec = 2; % specify desired connection (from 1:length(list_sig))

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

all_data=[];
labels_data=[];
for i = 1:4
    all_data = [all_data;data_cne{i}];
    labels_data = [labels_data;repmat(10*(i),length(data_cne{i}),1)];
    
    all_data = [all_data;data_mci{i}];
    labels_data = [labels_data;repmat(10*(i+0.5),length(data_mci{i}),1)];
end

hold on
%% plotting raw data points for all sites for one connection
for ii = 1:4
    idx = ii*2-1;
    plot(idx-0.1+0.2*rand(size(data_cne{ii},1),1),data_cne{ii},'.','Marker','o','MarkerSize',3,'MarkerFaceColor','red','MarkerEdgeColor','red');
end

for ii = 1:4
    idx = ii*2;
    plot(idx-0.1+0.2*rand(size(data_mci{ii},1),1),data_mci{ii},'.','Marker','o','MarkerSize',3,'MarkerFaceColor','blue','MarkerEdgeColor','blue');
end

%% overlay box plots
bp = boxplot(all_data,labels_data,'color','k','symbol','','width',0.5);
set(findobj(gcf,'LineStyle','--'),'LineStyle','-')

hold off

%% aesthetics
ylim([-1 1.5])
set(gca,'XTick',1.5:2:8.5,'XTickLabel',[' ADNI2 ';'CRIUGMa';'CRIUGMb';'  MNI  ']); 
xlabel('Sample','FontSize',11,'FontName','Helvetica')
ylabel('Mean connectivity with seed','FontSize',11,'FontName','Helvetica')
set(bp,'linewidth',0.5);
title('connection name')

print -painters -dpdf -r600 figure2.pdf