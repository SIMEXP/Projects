%% script for overlay of boxplot with raw data points per (parcel to parcel) connection for each site

clear all

load adnet_scanner_main_results_seed28.mat % load .mat file that came out of adnet_sc33_eff2csv.m first

kk = 'Superior medial frontal cortex'; % name of desired seed region
mm = '28'; % number of seed region

for jj = 1:length(list_sig)

    fig1 = figure('position',[0 0 600 800]); % set figure to specific size
    set(fig1,'PaperPositionMode','auto'); % To keep the custom figure settings
    %set(fig1,'PaperOrientation','landscape');

    %% specify data

    % achieva data
    achieva_cne = tab{2,1}(:,jj); 
    achieva_mci = tab{3,1}(:,jj);
    % gemini data
    gemini_cne = tab{2,2}(:,jj);
    gemini_mci = tab{3,2}(:,jj);
    % ingenuity data
    ingenuity_cne = tab{2,3}(:,jj);
    ingenuity_mci = tab{3,3}(:,jj);
    % intera data
    intera_cne = tab{2,4}(:,jj);
    intera_mci = tab{3,4}(:,jj);
    % criugmmci
    criugmmci_cne = tab{2,5}(:,jj);
    criugmmci_mci = tab{3,5}(:,jj);
    % adpd data
    adpd_cne = tab{2,6}(:,jj);
    adpd_mci = tab{3,6}(:,jj);
    % mnimci data
    mnimci_cne = tab{2,7}(:,jj);
    mnimci_mci = tab{3,7}(:,jj);


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
    
    hh = list_sig(jj);
    title(['From ' num2str(kk) ' to ' num2str(hh) 'th parcel'])

    eval(['print -painters -dpdf -r600 boxplot_' num2str(mm) 'to' num2str(hh) '.pdf']);

end