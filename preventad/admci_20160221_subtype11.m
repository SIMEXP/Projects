%% regress sex age fd sites
%% use model with balanced2 (fd<0.4) admci/ctl --> N = 65/65
%% test associations with admci, fd and sites

clear all
% subtyping
num_net = [2 5 6 7];
name_net = {'lim','dmn','cen','san'};
nb_clus = 4; 
name_clus = {'subt1','subt2','subt3','subt4'};
type_norm = 0; % 0 = no norm, 1 = ga correction, 2 = norm on subjects, 3 = norm on voxels
regress_conf = 1; % 1 = yes, 0 = no

% association
num_var = [2 3 4 5 7 8 9 10 11];
name_var = {'admci','sex','age','fd','mnimci1','belleville2','criugmmci4','adni5','adni9'};
% num_var = [2];
% name_var = {'admci'};
num_sex = 3;
num_age = 4;
num_fd = 5; 
num_mnimci1 = 7;
num_belleville2 = 8;
num_criugmmci4 = 9;
num_adni5 = 10;
qfdr = 0.05;
type_plot = [1 1 2 2 1 1 1 1 1 1 1 1 1]; % 1=boxplot, 2=regression line
% type_plot = [1];

% paths
model = '/Users/pyeror/Work/transfert/PreventAD/models/admci_model_balanced2_20160222.csv';
path_data = '/Users/pyeror/Work/transfert/PreventAD/results/scores/admci_balanced2_7/rmap_part_stack/';
path_mask = '/Users/pyeror/Work/transfert/PreventAD/results/scores/';
path_results = '/Users/pyeror/Work/transfert/PreventAD/results/subtype/admci_20160221_subtype11/';

% save: 1 = save, 0 do not save
fig_clust = 1; 
fig_plots = 0; 
fig_weights = 1; 
fig_limits = [-0.5 0.5];

% Read model file
[tab,sub_id,labels_y,labels_id] = niak_read_csv(model);

% Create main ouptut directory
psom_mkdir(path_results)


%% Clustering

struct_test = zeros(length(num_var),nb_clus,length(num_net));
pce = struct_test;
test_fdr_single = struct_test;


for n_net = 1:length(num_net)
    
    % Create ouptut directories
    path_res_net = [path_results 'net_' num2str(num_net(n_net)) '/'];
    psom_mkdir(path_res_net)
    
    % Load data
    file_stack = [path_data,'stack_net_' num2str(num_net(n_net)) '.nii.gz'];
    [hdr,stack] = niak_read_vol(file_stack);
    [hdr,mask] = niak_read_vol([path_mask 'mask.nii.gz']);
    raw_data = niak_vol2tseries(stack,mask);
    
    % Regress confounds 
    % tab(:,num_fd) tab(:,num_age) tab(:,num_sex)
    % tab(:,num_mnimci1) tab(:,num_belleville2) tab(:,num_criugmmci4) tab(:,num_adni5)
    if regress_conf == 1
        x = [ones(length(sub_id),1) tab(:,num_fd) tab(:,num_age) tab(:,num_sex) tab(:,num_mnimci1) tab(:,num_belleville2) tab(:,num_criugmmci4) tab(:,num_adni5)];
        y = raw_data;
        beta = (x'*x)\x'*y;               
        data = y-x*beta;                    
    end

    % Normalization
    if type_norm == 0
    elseif type_norm == 1
        gd_mean = mean(data);
        data = data - repmat(gd_mean,[size(data,1),1]);
    elseif type_norm == 2
        data = niak_normalize_tseries(data')';
    elseif type_norm == 3
        data = niak_normalize_tseries(data','median_mad')';
    end
    
    % Run a cluster analysis on the processed maps
    R = niak_build_correlation(data');
    hier = niak_hierarchical_clustering(R);
    part = niak_threshold_hierarchy(hier,struct('thresh',nb_clus));
    order = niak_hier2order(hier);
    save([path_res_net 'order.mat'],'order');
    save([path_res_net 'part.mat'],'part');
    
    % Contingency table
    % (...)
    
    % Figs
    if fig_clust ==1
        
        % Visualize dendrograms
        figure
        niak_visu_dendrogram(hier);
        namefig = strcat(path_res_net,'dendrogram.pdf');
        print(namefig,'-dpdf','-r300')
        
        % Visualize the matrices
        figure
        opt_vr.limits = fig_limits;
        niak_visu_matrix(R(order,order),opt_vr);
        namefig = strcat(path_res_net,'matrix.pdf');
        print(namefig,'-dpdf','-r300')
        figure
        opt_p.flag_labels = true;
        niak_visu_part(part(order),opt_p);
        namefig = strcat(path_res_net,'clusters.pdf');
        print(namefig,'-dpdf','-r300')
        close all
        
        % Write volumes
        % The average per cluster
        avg_clust_raw = zeros(max(part),size(data,2));
        for cc = 1:max(part)
            avg_clust_raw(cc,:) = mean(raw_data(part==cc,:),1);
        end
        vol_avg_raw = niak_tseries2vol(avg_clust_raw,mask);
        hdr.file_name = [path_res_net 'mean_clusters.nii.gz'];
        niak_write_vol(hdr,vol_avg_raw);
        
        % The std per cluster
        avg_clust_raw = zeros(max(part),size(data,2));
        for cc = 1:max(part)
            avg_clust_raw(cc,:) = std(raw_data(part==cc,:),1);
        end
        vol_avg_raw = niak_tseries2vol(avg_clust_raw,mask);
        hdr.file_name = [path_res_net 'std_clusters.nii.gz'];
        niak_write_vol(hdr,vol_avg_raw);
        
        % The demeaned/z-ified per cluster
        gd_mean = mean(raw_data);
        raw_data_ga = raw_data - repmat(gd_mean,[size(data,1),1]);
        avg_clust = zeros(max(part),size(raw_data,2));
        for cc = 1:max(part)
            avg_clust(cc,:) = mean(raw_data_ga(part==cc,:),1);
        end
        avg_clust = niak_normalize_tseries(avg_clust','median_mad')';
        vol_avg = niak_tseries2vol(avg_clust,mask);
        hdr.file_name = [path_res_net 'mean_clusters_demeaned.nii.gz'];
        niak_write_vol(hdr,vol_avg);
        
        % Mean and std grand average
        hdr.file_name = [path_res_net 'grand_mean_clusters.nii.gz'];
        niak_write_vol(hdr,mean(stack,4));
        hdr.file_name = [path_res_net 'grand_std_clusters.nii.gz'];
        niak_write_vol(hdr,std(stack,0,4));
    end
    
    
    %% GLM analysis
    
    % Build loads
    for cc = 1:max(part)
        avg_clust(cc,:) = mean(data(part==cc,:),1);
        weights(:,cc) = corr(data',avg_clust(cc,:)');
    end
    
    save([path_res_net 'weights.mat'],'weights');
    
    opt.labels_y = name_clus;
    opt.labels_x = sub_id;
    path = [path_res_net 'weights.csv'];
    opt.precision = 3;
    niak_write_csv(path,weights,opt);
    
    if fig_weights ==1
        % Visualize weights
        figure
        opt_vr.limits = fig_limits;
        niak_visu_matrix(weights(order,:),opt_vr)
        namefig = strcat(path_res_net,'weights.pdf');
        print(namefig,'-dpdf','-r300')
        close all
    end
    
    
    % Load phenotypic variables
    
    [tab2,sub_id,labels_y,labels_id] = niak_read_csv(model);
    
    for n_var = 1:length(num_var)
        covar = tab2(:,num_var(n_var));
        mask_covar = ~isnan(covar);
        model_covar.x = [ones(sum(mask_covar),1) niak_normalize_tseries([covar(mask_covar)],'mean')];
        model_covar.y = weights(mask_covar,:);
        covar = model_covar.y;
        model_covar.c = [0;1];
        opt_glm.test = 'ttest';
        opt_glm.flag_beta = true;
        res_covar = niak_glm(model_covar,opt_glm);
        pce(n_var,:,n_net) = res_covar.pce;
        
        
        if fig_plots == 1
            if type_plot(n_var) ==1 
                for n_subtype = 1:max(part)
                    figure
                    mask = model_covar.x(:,2)==min(model_covar.x(:,2));
                    plot(mask+1+0.1*randn(size(mask)),covar(:,n_subtype),'.','markersize',20)
                    hold on
                    boxplot(covar(:,n_subtype),mask);
                    bh = boxplot(covar(:,n_subtype),mask);
                    set(bh(:,1),'linewidth',0.5);
                    set(bh(:,2),'linewidth',0.5);
                    namefig = strcat(path_res_net,'plot_net_',num2str(num_net(n_net)), '_var_', num2str(num_var(n_var)), '_subtype_', num2str(n_subtype), '.pdf');
                    print(namefig,'-dpdf','-r300')
                    close all
                end
            else
                for n_subtype = 1:max(part)
                    figure
                    plot(model_covar.x(:,2),model_covar.y(:,n_subtype),'.','markersize',20);
                    hold on
                    beta = niak_lse(covar(:,n_subtype),[ones(size(covar(:,n_subtype))) model_covar.x(:,2)]);
                    plot(model_covar.x(:,2),[ones(size(covar(:,n_subtype))) model_covar.x(:,2)]*beta,'r','linewidth',0.7);
                    namefig = strcat(path_res_net,'plot_net_',num2str(num_net(n_net)), '_var_', num2str(num_var(n_var)), '_subtype_', num2str(n_subtype), '.pdf');
                    print(namefig,'-dpdf','-r300')
                    close all
                end
            end
        end
    end
end

% Stats
for n_var = 1:length(num_var)
    pce_single = pce(n_var,:,:);
    [fdr,test_single] = niak_fdr(pce_single(:),'BH',qfdr);
    test_singletmp(n_var,:,:) = test_single;
end

test_single = reshape(test_singletmp,size(pce));

[fdr,test] = niak_fdr(pce(:),'BH',qfdr);
test_all = reshape(test,size(pce));


save([path_results 'test_fdr_all.mat'],'test_all');
save([path_results 'test_fdr_single.mat'],'test_single');
save([path_results 'pce_all.mat'],'pce');


%% Findings .csv

for n_net = 1:length(num_net)
    nn1 = 1+(nb_clus*(n_net-1));
    nn2 = nb_clus+(nb_clus*(n_net-1));
    pce_csv(nn1:nn2,:) = pce(:,:,n_net)';
    test_all_csv(nn1:nn2,:) = test_all(:,:,n_net)';
    test_single_csv(nn1:nn2,:) = test_single(:,:,n_net)';
end

opt.labels_y = name_var;

for name_n = 1:length(name_net)
    for name_c = 1:length(name_clus)
        name_all = 1+(nb_clus*(name_n-1))+(name_c-1);
        opt.labels_x{name_all} = strcat(name_net{name_n},'_',name_clus{name_c});
    end
end

path_res_pce = [path_results 'pce.csv'];
path_res_test_all = [path_results 'test_all.csv'];
path_res_test_single = [path_results 'test_single.csv'];

opt.precision = 0;
niak_write_csv(path_res_test_all,test_all_csv,opt);

opt.precision = 0;
niak_write_csv(path_res_test_single,test_single_csv,opt);

opt.precision = 5;
niak_write_csv(path_res_pce,pce_csv,opt);




