
%% Intitialization
clear

path = '/Users/pyeror/Work/ccna/20160201_multisite_TR/results_nii/';

list_session = {'p2pconnectome_all_session1','p2pconnectome_all_session2'}; % 'p2pconnectome_all_sessions12'
%list_session     = {'p2pconnectome_MNI_session3_run1','p2pconnectome_MNI_session3_run2','p2pconnectome_MNI_session3_run3'};
list_site    = {'CHUS','CINQ','UNF','MNI'};
%list_site    = {'MNI'};
list_net     = {'CER','LIM','MOT','VIS','DMN','FPN','SAL'};

%% Load data
data = struct;
for nn = 1:length(list_net)
    for ss = 1:length(list_site)
        for ssess = 1:length(list_session)
            session = list_session{ssess};
            site    = list_site{ss};
            name = [site '_' session];
            net     = list_net{nn};
            fprintf('Network: %s, site: %s, session: %s\n',net,site,session)
            [hdrv,vol] = niak_read_vol([path session '/rmap_seeds/rmap_' site '_' net '.nii.gz']);
            [hdrm,mask] = niak_read_vol([path 'mask.nii']);
            data.(net).(name) = niak_vol2tseries(vol,mask);
        end
    end
end

%% Create correlation
corr_net = struct;
for nn = 1:length(list_net)
    net     = list_net{nn};
    list_name = fieldnames(data.(net));
    corr_net.(net) = zeros(length(list_name),length(list_name));
    for nn1 = 1:length(list_name);
        for nn2 = 1:length(list_name)
            corr_net.(net)(nn1,nn2) = corr(data.(net).(list_name{nn1})',data.(net).(list_name{nn2})');
        end
    end
end


%% Table

for nn = 1:length(list_net)
    net = list_net{nn};
    
    path_csv = [path 'correlation_' net '.csv'];
    
    opt.precision = 2;
    niak_write_csv(path_csv,corr_net.(net),opt);
    
end


%% Visualization


for nn = 1:length(list_net)
    net = list_net{nn};
    
    figure
    niak_visu_matrix(corr_net.(net))
    ha = gca;
    set(ha,'YTickLabel',list_name)
    set(ha,'XTickLabel',list_name)
    title(sprintf('Network: %s',net))
    namefig = [path 'correlation_' net '.pdf'];
    print(namefig,'-dpdf','-r300')
    close all
    
end


