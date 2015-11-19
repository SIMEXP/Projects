%% script for overlay of boxplot with raw data points per (parcel to parcel) connection for each site

clear all

load adnet_scanner_main_results_seed28.mat % load .mat file that came out of adnet_sc33_eff2csv.m first

fig1 = figure('position',[0 0 600 800]); % set figure to specific size
set(fig1,'PaperPositionMode','auto'); % To keep the custom figure settings
%set(fig1,'PaperOrientation','landscape');

%% specify data
connec = 2; % specify desired connection (from 1:length(list_sig))

% achieva data
achieva_cne = tab{2,1}(:,connec); 
achieva_mci = tab{3,1}(:,connec);
% gemini data
gemini_cne = tab{2,2}(:,connec);
gemini_mci = tab{3,2}(:,connec);
% ingenuity data
ingenuity_cne = tab{2,3}(:,connec);
ingenuity_mci = tab{3,3}(:,connec);
% intera data
intera_cne = tab{2,4}(:,connec);
intera_mci = tab{3,4}(:,connec);
% criugmmci
criugmmci_cne = tab{2,5}(:,connec);
criugmmci_mci = tab{3,5}(:,connec);
% adpd data
adpd_cne = tab{2,6}(:,connec);
adpd_mci = tab{3,6}(:,connec);
% mnimci data
mnimci_cne = tab{2,7}(:,connec);
mnimci_mci = tab{3,7}(:,connec);


data_cne = {achieva_cne,gemini_cne,ingenuity_cne,intera_cne,criugmmci_cne,adpd_cne,mnimci_cne};
data_mci = {achieva_mci,gemini_mci,ingenuity_mci,intera_mci,criugmmci_mci,adpd_mci,mnimci_mci};

all_data=[];
labels_data=[];
for i = 1:7
    all_data = [all_data;data_cne{i}];
    labels_data = [labels_data;repmat(10*(i),length(data_cne{i}),1)];
    
    all_data = [all_data;data_mci{i}];
    labels_data = [labels_data;repmat(10*(i+0.5),length(data_mci{i}),1)];
end

hold on
%% plotting raw data points for all sites for one connection
for ii = 1:7
    idx = ii*2-1;
    plot(idx-0.1+0.2*rand(size(data_cne{ii},1),1),data_cne{ii},'.','Marker','o','MarkerSize',3,'MarkerFaceColor','red','MarkerEdgeColor','red');
end

for ii = 1:7
    idx = ii*2;
    plot(idx-0.1+0.2*rand(size(data_mci{ii},1),1),data_mci{ii},'.','Marker','o','MarkerSize',3,'MarkerFaceColor','blue','MarkerEdgeColor','blue');
end

%% overlay box plots
bp = boxplot(all_data,labels_data,'color','k','symbol','','width',0.5);
set(findobj(gcf,'LineStyle','--'),'LineStyle','-')

hold off

%% aesthetics
ylim([-1 1.5])
set(gca,'XTick',1.5:2:14.5,'XTickLabel',['Achieva';' Gemini';'Ingenia';' Intera';'CRIUGMa';'CRIUGMb';'  MNI  ']); 
xlabel('Sample','FontSize',11,'FontName','Helvetica')
ylabel('Mean connectivity with seed','FontSize',11,'FontName','Helvetica')
set(bp,'linewidth',0.5);
title('Superior medial frontal cortex -- Striatum')

print -painters -dpdf -r600 figure2.pdf