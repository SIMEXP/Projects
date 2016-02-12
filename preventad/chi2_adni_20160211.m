
clear all

num_net = [1 2 3 4 5 6 7]; % networks s7
name_net = {'cer','lim','mot','vis','dmn','fpa','cos'};
nb_clus = 3;
name_clus = {'subt1','subt2','subt3'};

path_results = '/Users/pyeror/Work/transfert/PreventAD/results/subtype/adni_148_7networks_3x3NKIsubtypes_rmaps_categorical_confounds_BH05/';

for nn = 1:length(num_net)
    
    for cc = 1:nb_clus
        
        tab = [];
        id = [];
        dx = [];
        ct = zeros(3,3);
               
        path_model = [path_results 'net_' num2str(num_net(nn)) '_' name_net{nn} '_' num2str(nb_clus) 'clusters/clus_' num2str(cc) '/model_net_' num2str(num_net(nn)) '_' name_net{nn} '_clus' num2str(cc) '.csv'];
        path_part = [path_results 'net_' num2str(num_net(nn)) '_' name_net{nn} '_' num2str(nb_clus) 'clusters/clus_' num2str(cc) '/net_' num2str(num_net(nn)) '_clus_' num2str(cc) '_part.mat'];
        
        [tab,id,labels_y,labels_id] = niak_read_csv(path_model);
        load(path_part)
               
        dx = tab(:,3);
        
        for ii = 1:length(id)
            
            if dx(ii)==1 & part(ii)==1
                ct(1,1) = ct(1,1)+1;
            elseif dx(ii)==1 & part(ii)==2
                ct(1,2) = ct(1,2)+1;
            elseif dx(ii)==1 & part(ii)==3
                ct(1,3) = ct(1,3)+1;
            elseif dx(ii)==2 & part(ii)==1
                ct(2,1) = ct(2,1)+1;
            elseif dx(ii)==2 & part(ii)==2
                ct(2,2) = ct(2,2)+1;
            elseif dx(ii)==2 & part(ii)==3
                ct(2,3) = ct(2,3)+1;
            elseif dx(ii)==3 & part(ii)==1
                ct(3,1) = ct(3,1)+1;
            elseif dx(ii)==3 & part(ii)==2
                ct(3,2) = ct(3,2)+1;
            elseif dx(ii)==3 & part(ii)==3
                ct(3,3) = ct(3,3)+1;
            end
        end
        
        [~,p,~] = chi2cont(ct);
        
        stats(nn,cc) = p;
        
    end
end

opt.labels_x = name_net;
opt.labels_y = name_clus;
opt.precision = 2;
path_stats = [path_results 'chi2_stats.csv'];
niak_write_csv(path_stats,stats,opt)


