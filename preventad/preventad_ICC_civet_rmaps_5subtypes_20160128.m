clear all

nb_clus = 5; % nb clusters in clustering
name_clus = {'subt1','subt2','subt3','subt4','subt5'};
civet = '/Users/pyeror/Work/transfert/PreventAD/models/preventad_civet_raw_nomean_20160128.csv'; 
%model = '/Users/pyeror/Work/transfert/PreventAD/models/model_preventad_20160121.csv';
stack = '/Users/pyeror/Work/transfert/PreventAD/results/scores/preventad_7/rmap_stack_run1/';
path_results = '/Users/pyeror/Work/transfert/PreventAD/results/subtype/preventad_232_ICC_civet_rmaps_5subtypes_20160128/';
net = {'1_cer','2_lim','3_mot','4_vis','5_dmn','6_fpa','7_cos'};
num_net = [1 2 3 4 5 6 7];

% Read model files
[tab_c,sub_id,labels_y,labels_x] = niak_read_csv(civet);

% Create main ouptut directory
psom_mkdir(path_results)


%% Civet subtypes

tseries1 = tab_c;
gd_mean1 = mean(tseries1);
tseries_ga1 = tseries1 - repmat(gd_mean1,[size(tseries1,1),1]);

% Run a cluster analysis on the demeaned cortical thickness scores
R = corr(tseries_ga1');
hier = niak_hierarchical_clustering(R);
part = niak_threshold_hierarchy(hier,struct('thresh',nb_clus));
order = niak_hier2order(hier);
save([path_results 'civet_order.mat'],'order');
save([path_results 'civet_part.mat'],'part');

% Visualize dendrograms & matrices
figure
niak_visu_dendrogram(hier);
namefig = strcat(path_results,'civet_dendrogram.pdf');
print(namefig,'-dpdf','-r300')
figure
opt_vr.limits = [-0.3 0.3];
niak_visu_matrix(R(order,order),opt_vr);
namefig = strcat(path_results,'civet_matrix.pdf');
print(namefig,'-dpdf','-r300')
figure
opt_p.flag_labels = true;
niak_visu_part(part(order),opt_p);
namefig = strcat(path_results,'civet_clusters.pdf');
print(namefig,'-dpdf','-r300')
close all

% Weights
for cc = 1:max(part)
    avg_clust1(cc,:) = mean(tseries_ga1(part==cc,:),1);
    weights(:,cc) = corr(tseries_ga1',avg_clust1(cc,:)');
end

save([path_results 'civet_weights.mat'],'weights');

opt.labels_y = name_clus;
opt.labels_x = sub_id;
path = [path_results 'civet_weights.csv'];
opt.precision = 3;
niak_write_csv(path,weights,opt);

% Visualize weights
figure
niak_visu_matrix(weights(order,:))
namefig = strcat(path_results,'civet_weights_order.pdf');
print(namefig,'-dpdf','-r300')
figure
niak_visu_matrix(weights)
namefig = strcat(path_results,'civet_weights.pdf');
print(namefig,'-dpdf','-r300')
close all



%% rmaps subtype (whole brain)


for n_net = 1:length(net)
    % Load dat
    file_stack1 = [stack,'stack_net',num2str(num_net(n_net)),'.nii.gz'];
    [hdr,stab1] = niak_read_vol(file_stack1);
    
    [hdr,mask] = niak_read_vol([stack 'mask.nii.gz']);
    
    tseriesnet = niak_vol2tseries(stab1,mask);
    nb_region_net = size(tseriesnet,2);
    
    if n_net ==1
        tseries1 = tseriesnet;
        
    elseif n_net>1
        nb_region = size(tseries1,2);
        nb_region_s = nb_region+1;
        nb_region_e = nb_region_net*n_net;
        tseries1(:,nb_region_s:nb_region_e) = tseriesnet;
    end
end

gd_mean1 = mean(tseries1);
tseries_ga1 = tseries1 - repmat(gd_mean1,[size(tseries1,1),1]);

% Run a cluster analysis on the demeaned cortical thickness scores
R = corr(tseries_ga1');
hier = niak_hierarchical_clustering(R);
part = niak_threshold_hierarchy(hier,struct('thresh',nb_clus));
order = niak_hier2order(hier);
save([path_results 'rmaps_order.mat'],'order');
save([path_results 'rmaps_part.mat'],'part');

% Visualize dendrograms & matrices
figure
niak_visu_dendrogram(hier);
namefig = strcat(path_results,'rmaps_dendrogram.pdf');
print(namefig,'-dpdf','-r300')
figure
opt_vr.limits = [-0.3 0.3];
niak_visu_matrix(R(order,order),opt_vr);
namefig = strcat(path_results,'rmaps_matrix.pdf');
print(namefig,'-dpdf','-r300')
figure
opt_p.flag_labels = true;
niak_visu_part(part(order),opt_p);
namefig = strcat(path_results,'rmaps_clusters.pdf');
print(namefig,'-dpdf','-r300')
close all

% Weights
for cc = 1:max(part)
    avg_clust1(cc,:) = mean(tseries_ga1(part==cc,:),1);
    weights(:,cc) = corr(tseries_ga1',avg_clust1(cc,:)');
end

save([path_results 'rmaps_weights.mat'],'weights');

opt.labels_y = name_clus;
opt.labels_x = sub_id;
path = [path_results 'rmaps_weights.csv'];
opt.precision = 3;
niak_write_csv(path,weights,opt);

% Visualize weights
figure
niak_visu_matrix(weights(order,:))
namefig = strcat(path_results,'rmaps_weights_order.pdf');
print(namefig,'-dpdf','-r300')
figure
niak_visu_matrix(weights)
namefig = strcat(path_results,'rmaps_weights.pdf');
print(namefig,'-dpdf','-r300')
close all



%% rmaps subtypes (networks)



for n_net = 1:length(net)
    % Load dat
    file_stack1 = [path_data_1,'stack_net',num2str(num_net(n_net)),'.nii.gz'];
    [hdr,stab1] = niak_read_vol(file_stack1);
    
    [hdr,mask] = niak_read_vol([path_data_1 'mask.nii.gz']);
    
    tseriesnet = niak_vol2tseries(stab1,mask);
    nb_region_net = size(tseriesnet,2);
    
    if n_net ==1
        tseriesall = tseriesnet;
        
    elseif n_net>1
        nb_region = size(tseriesall,2);
        nb_region_s = nb_region+1;
        nb_region_e = nb_region_net*n_net;
        tseriesall(:,nb_region_s:nb_region_e) = tseriesnet;
    end
end
    
    
    

    % Build loads
    for cc = 1:max(part)
        avg_clust1(cc,:) = mean(tseries_ga1(part==cc,:),1);
        weights1(:,cc) = corr(tseries_ga1',avg_clust1(cc,:)');
        weights2(:,cc) = corr(tseries_ga2',avg_clust1(cc,:)');
    end
    
    % Reproc of stab maps
    for ss = 1:size(tseries1,1)
        repro_stab(ss,n_net) = corr(tseries_ga1(ss,:)',tseries_ga2(ss,:)');
    end
    
    % Reproc of weights
    % tmp = corr([weights1,weights2]);
    for cc = 1:nb_clus
        repro_weights(cc,n_net) = IPN_icc([weights1(:,cc) weights2(:,cc)],2,'single');
    end
    
    
    
    
    
    
    
end



