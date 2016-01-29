clear all

nb_clus = 5; % nb clusters in clustering
name_clus = {'subt1','subt2','subt3','subt4','subt5'};
civet = '/Users/pyeror/Work/transfert/PreventAD/models/preventad_civet_raw_';
stack = '/Users/pyeror/Work/transfert/PreventAD/results/scores/preventad_7/rmap_stack_run1/';
path_results = '/Users/pyeror/Work/transfert/PreventAD/results/subtype/preventad_232_ICC_civet_rmaps_6networks_5subtypes_20160129/';
net = {'2_lim','3_mot','4_vis','5_dmn','6_fpa','7_cos'};
num_net = [2 3 4 5 6 7];

% Create main ouptut directory
psom_mkdir(path_results)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%      networks     %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n_net = 1:length(num_net)
    
    %% civet subtypes (networks)
    
    % Create main ouptut directory
    path_res_net = [path_results net{n_net}];
    psom_mkdir(path_res_net)
    
    % Read model files
    [tab_c,sub_id,~,~] = niak_read_csv([civet net{n_net} '.csv']);
    
    tseries1 = tab_c;
    gd_mean1 = mean(tseries1);
    tseries_ga1 = tseries1 - repmat(gd_mean1,[size(tseries1,1),1]);
    
    % Run a cluster analysis on the demeaned cortical thickness scores
    R = corr(tseries_ga1');
    hier = niak_hierarchical_clustering(R);
    part = niak_threshold_hierarchy(hier,struct('thresh',nb_clus));
    order = niak_hier2order(hier);
    save([path_res_net '/civet_order.mat'],'order');
    save([path_res_net '/civet_part.mat'],'part');
    
    % Visualize dendrograms & matrices
    figure
    niak_visu_dendrogram(hier);
    namefig = strcat(path_res_net,'/civet_dendrogram.pdf');
    print(namefig,'-dpdf','-r300')
    figure
    opt_vr.limits = [-0.3 0.3];
    niak_visu_matrix(R(order,order),opt_vr);
    namefig = strcat(path_res_net,'/civet_matrix.pdf');
    print(namefig,'-dpdf','-r300')
    figure
    opt_p.flag_labels = true;
    niak_visu_part(part(order),opt_p);
    namefig = strcat(path_res_net,'/civet_clusters.pdf');
    print(namefig,'-dpdf','-r300')
    close all
    
    % Weights
    for cc = 1:max(part)
        avg_clust1(cc,:) = mean(tseries_ga1(part==cc,:),1);
        weights(:,cc) = corr(tseries_ga1',avg_clust1(cc,:)');
    end
    
    save([path_res_net '/civet_weights.mat'],'weights');
    
    opt.labels_y = name_clus;
    opt.labels_x = sub_id;
    path = [path_res_net '/civet_weights.csv'];
    opt.precision = 3;
    niak_write_csv(path,weights,opt);
    
    % Visualize weights
    figure
    niak_visu_matrix(weights(order,:))
    namefig = strcat(path_res_net,'/civet_weights_order.pdf');
    print(namefig,'-dpdf','-r300')
    figure
    niak_visu_matrix(weights)
    namefig = strcat(path_res_net,'/civet_weights.pdf');
    print(namefig,'-dpdf','-r300')
    close all
    
    
    %% rmaps subtypes (networks)
    
    file_stack1 = [stack,'stack_net',num2str(num_net(n_net)),'.nii.gz'];
    [hdr,stab1] = niak_read_vol(file_stack1);
    [hdr,mask] = niak_read_vol([stack 'mask.nii.gz']);
    tseries1 = niak_vol2tseries(stab1,mask);
    
    gd_mean1 = mean(tseries1);
    tseries_ga1 = tseries1 - repmat(gd_mean1,[size(tseries1,1),1]);
    
    % Run a cluster analysis on the demeaned cortical thickness scores
    R = corr(tseries_ga1');
    hier = niak_hierarchical_clustering(R);
    part = niak_threshold_hierarchy(hier,struct('thresh',nb_clus));
    order = niak_hier2order(hier);
    save([path_res_net '/rmaps_order.mat'],'order');
    save([path_res_net '/rmaps_part.mat'],'part');
    
    % Visualize dendrograms & matrices
    figure
    niak_visu_dendrogram(hier);
    namefig = strcat(path_res_net,'/rmaps_dendrogram.pdf');
    print(namefig,'-dpdf','-r300')
    figure
    opt_vr.limits = [-0.3 0.3];
    niak_visu_matrix(R(order,order),opt_vr);
    namefig = strcat(path_res_net,'/rmaps_matrix.pdf');
    print(namefig,'-dpdf','-r300')
    figure
    opt_p.flag_labels = true;
    niak_visu_part(part(order),opt_p);
    namefig = strcat(path_res_net,'/rmaps_clusters.pdf');
    print(namefig,'-dpdf','-r300')
    close all
    
    % Weights
    for cc = 1:max(part)
        avg_clust(cc,:) = mean(tseries_ga1(part==cc,:),1);
        weights(:,cc) = corr(tseries_ga1',avg_clust(cc,:)');
    end
    
    save([path_res_net '/rmaps_weights.mat'],'weights');
    
    opt.labels_y = name_clus;
    opt.labels_x = sub_id;
    path = [path_res_net '/rmaps_weights.csv'];
    opt.precision = 3;
    niak_write_csv(path,weights,opt);
    
    % Visualize weights
    figure
    niak_visu_matrix(weights(order,:))
    namefig = strcat(path_res_net,'/rmaps_weights_order.pdf');
    print(namefig,'-dpdf','-r300')
    figure
    niak_visu_matrix(weights)
    namefig = strcat(path_res_net,'/rmaps_weights.pdf');
    print(namefig,'-dpdf','-r300')
    close all
    
    
    %% ICC
    
    load([path_res_net '/rmaps_weights.mat']);
    weights_func = weights;
    load([path_res_net '/civet_weights.mat']);
    weights_stru = weights;
    
    for cc_f = 1:nb_clus
        for cc_s = 1:nb_clus
            repro_weights(cc_f,cc_s) = IPN_icc([weights_func(:,cc_f) weights_stru(:,cc_s)],2,'single');
        end
    end
    
    file_write = [path_res_net '/' net{n_net} '_ICC_rmap_civet.csv'];
    opt.labels_x = {'subt1_f','subt2_f','subt3_f','subt4_f','subt5_f'};
    opt.labels_y = {'subt1_s','subt2_s','subt3_s','subt4_s','subt5_s'};
    niak_write_csv(file_write,repro_weights,opt)
    
    % Visualize ICC
    figure
    opt_vr.limits = [-0.5 0.5];
    niak_visu_matrix(repro_weights,opt_vr);
    namefig = strcat(path_res_net,'/',net{n_net},'_ICC_matrix.pdf');
    print(namefig,'-dpdf','-r300')
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    whole-brain    %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Civet subtypes (whole brain)

% Read model files
[tab_c,sub_id,~,~] = niak_read_csv([civet 'nomean_20160128.csv']);

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
    avg_clust(cc,:) = mean(tseries_ga1(part==cc,:),1);
    weights(:,cc) = corr(tseries_ga1',avg_clust(cc,:)');
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

%% ICC

load([path_results 'rmaps_weights.mat']);
weights_func = weights;
load([path_results 'civet_weights.mat']);
weights_stru = weights;

for cc_f = 1:nb_clus
    for cc_s = 1:nb_clus
    repro_weights(cc_f,cc_s) = IPN_icc([weights_func(:,cc_f) weights_stru(:,cc_s)],2,'single');
    end
end

file_write = [path_results 'ICC_rmap_civet.csv'];
opt.labels_x = {'subt1_f','subt2_f','subt3_f','subt4_f','subt5_f'};
opt.labels_y = {'subt1_s','subt2_s','subt3_s','subt4_s','subt5_s'};
niak_write_csv(file_write,repro_weights,opt)









