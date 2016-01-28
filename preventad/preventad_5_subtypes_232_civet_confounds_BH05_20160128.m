clear all

nb_clus = 5; % nb clusters in clustering
name_clus = {'subt1','subt2','subt3','subt4','subt5'};
civet = '/Users/pyeror/Work/transfert/PreventAD/thickness_dat_20150831/preventad_civet.csv';
path_results = '/Users/pyeror/Work/transfert/PreventAD/results/subtype/preventad_232_5subtypes_civet_20160128/';

% Read model file
[tab,sub_id,labels_y,labels_id] = niak_read_csv(civet);

% Create main ouptut directory
psom_mkdir(path_results)


%% Clustering

tseries1 = tab;

% correct for the mean
gd_mean1 = mean(tseries1);
tseries_ga1 = tseries1 - repmat(gd_mean1,[size(tseries1,1),1]);

% Run a cluster analysis on the demeaned cortical thickness scores
R = corr(tseries_ga1');
hier = niak_hierarchical_clustering(R);
part = niak_threshold_hierarchy(hier,struct('thresh',nb_clus));
order = niak_hier2order(hier);
save([path_results 'civet_order.mat'],'order');
save([path_results 'civet_part.mat'],'part');


% Visualize dendrograms
figure
niak_visu_dendrogram(hier);
namefig = strcat(path_results,'dendrogram.pdf');
print(namefig,'-dpdf','-r300')

% Visualize the matrices
figure
opt_vr.limits = [-0.3 0.3];
niak_visu_matrix(R(order,order),opt_vr);
namefig = strcat(path_results,'matrix.pdf');
print(namefig,'-dpdf','-r300')
figure
opt_p.flag_labels = true;
niak_visu_part(part(order),opt_p);
namefig = strcat(path_results,'clusters.pdf');
print(namefig,'-dpdf','-r300')
close all


%% Weights
for cc = 1:max(part)
    avg_clust1(cc,:) = mean(tseries_ga1(part==cc,:),1);
    weights1(:,cc) = corr(tseries_ga1',avg_clust1(cc,:)');
end

save([path_results 'civet_weights.mat'],'weights1');

opt.labels_y = name_clus;
opt.labels_x = sub_id;
path = [path_results 'civet_weights.csv'];
opt.precision = 3;
niak_write_csv(path,weights1,opt);

% Visualize weights
figure
niak_visu_matrix(weights1(order,:))
namefig = strcat(path_res_net,'weights.pdf');
print(namefig,'-dpdf','-r300')



   

