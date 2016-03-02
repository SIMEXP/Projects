%% regress sex age fd sites before subtypes, based on betas in matched HC in all 7 sites
%% test associations with admci with metal
%% 3 clusters

clear all

% paths
model = '/Users/pyeror/Work/transfert/PreventAD/models/all_model_20160302.csv';
path_data = '/Users/pyeror/Work/transfert/PreventAD/results/scores/all_samples_7/rmap_part_stack//';
path_mask = '/Users/pyeror/Work/transfert/PreventAD/results/scores/';
path_results = '/Users/pyeror/Work/transfert/PreventAD/results/subtype/admci_20160302_subtype1/';

% subtyping
% num_net = [1 2 3 4 5 6 7];
% name_net = {'cer','lim','mot','vis','dmn','cen','san'};
num_net = 5;
name_net = {'dmn'};
nb_clus = 3;
name_clus = {'subt1','subt2','subt3'};
name_grp = {'hc','admci'};
num_matchedHC = 4;
num_sample = 13;
num_sex = 1;
num_age = 2;
num_fd = 3;
num_mnimci = 6;
num_criugmad = 7;
num_criugmmci = 8;
num_adni5 = 9;
num_adni9 = 10;
num_pad = 11;
num_nki = 12;
num_admci = 15;

% association
num_var = [15 1 2 3 6 7 8 9 10];
name_var = {'admci','sex','age','fd','mnimci','criugmad','criugmmci','adni5','adni9'};
conf = {'sex','age','fd','mnimci','criugmad','criugmmci','adni5','adni9'};
num_multisite = 5;
qfdr = 0.05;
type_plot = [1 1 2 2 1 1 1 1 1]; % 1=boxplot, 2=regression line
col = [0 0 0; 0 0 0; 0 0 0];

% save: 1 = save, 0 do not save
fig_clust = 1;
fig_plots = 1;
fig_weights = 1;
fig_limits_l = [-0.2 0.2];
fig_limits_h = [-0.5 0.5];

% Create main ouptut directory
psom_mkdir(path_results)

% Read model file
[raw_tab,sub_id,labels_y,labels_id] = niak_read_csv(model);


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
    
    sss = 0;
    for ss = 1:length(sub_id)
        if raw_tab(ss,num_matchedHC) == 1 && raw_tab(ss,num_nki) == 0
            sss=sss+1;
            conf_tab(sss,:) = raw_tab(ss,:);
            conf_data(sss,:) = raw_data(ss,:);
        end
    end
    
    % Extract betas and regress confounds 
    conf_x = [conf_tab(:,num_sex) conf_tab(:,num_age) conf_tab(:,num_fd) conf_tab(:,num_mnimci) conf_tab(:,num_criugmad) conf_tab(:,num_criugmmci) conf_tab(:,num_adni5) conf_tab(:,num_adni9)  conf_tab(:,num_pad)]; % ones(length(sub_id),1) conf_tab(:,num_nki)
    conf_y = conf_data;
    beta = (conf_x'*conf_x)\conf_x'*conf_y;
    
    sss = 0;
    for ss = 1:length(sub_id)
        if raw_tab(ss,num_sample) == 1
            sss=sss+1;
            tab(sss,:) = raw_tab(ss,:);
            sample_data(sss,:) = raw_data(ss,:);
        end
    end
    x = [tab(:,num_sex) tab(:,num_age) tab(:,num_fd) tab(:,num_mnimci) tab(:,num_criugmad) tab(:,num_criugmmci) tab(:,num_adni5) tab(:,num_adni9)]; % ones(length(sub_id),1)
    y = sample_data;
    betas(1:length(conf),:) = beta(1:length(conf),:);
    data = y-x*betas;
    
    % Run a cluster analysis on the processed maps
    R = niak_build_correlation(data');
    hier = niak_hierarchical_clustering(R);
    part = niak_threshold_hierarchy(hier,struct('thresh',nb_clus));
    order = niak_hier2order(hier);
    save([path_res_net 'order.mat'],'order');
    save([path_res_net 'part.mat'],'part');
    
    % Contingency table (subjects x subtypes)
    for cc = 1:nb_clus
        mask_hc = tab(:,num_admci)==min(tab(:,num_admci));
        part_hc = part(mask_hc);
        p=0;
        for pp = 1:length(part_hc)
            if part_hc(pp) == cc
                p=p+1;
            end
        end
        ct(1,cc) = p;
        
        mask_admci = tab(:,num_admci)==max(tab(:,num_admci));
        part_admci = part(mask_admci);
        p=0;
        for pp = 1:length(part_admci)
            if part_admci(pp) == cc
                p=p+1;
            end
        end
        ct(2,cc) = p;
    end
    
    [~,pchi,~] = chi2cont(ct);
    statschi(n_net,1) = pchi;
    
    opt.labels_x = name_grp;
    opt.labels_y = name_clus;
    opt.precision = 2;
    path_ct = [path_res_net 'chi2_ct.csv'];
    niak_write_csv(path_ct,ct,opt)
    
    
    % Figs
    if fig_clust ==1
        
        % Visualize dendrograms
        figure
        niak_visu_dendrogram(hier);
        namefig = strcat(path_res_net,'dendrogram.pdf');
        print(namefig,'-dpdf','-r300')
        
        % Visualize the matrices
        figure
        opt_vr.color_map = 'brewer_bgyor';
        opt_vr.limits = fig_limits_l;
        niak_visu_matrix(R(order,order),opt_vr);
        namefig = strcat(path_res_net,'matrix.pdf');
        print(namefig,'-dpdf','-r300')
        figure
        opt_p.flag_labels = true;
        opt_p.type_map = 'brewer_bgyor';
        niak_visu_part_po(part(order),opt_p);
        namefig = strcat(path_res_net,'clusters.pdf');
        print(namefig,'-dpdf','-r300')
        close all
        
        % Pie charts
        for hh = 1:2
            figure
            h = pie(ct(hh,:));
            hp = findobj(h, 'Type', 'patch');
            colormap(brewer_bgyor);
            colors = colormap;
            step = round((size(colors,1)/nb_clus)-1);
            for cc = 1:nb_clus
                colorpie(cc,:) = colors(step*cc,:);
                set(hp(cc),'FaceColor', colorpie(cc,:));
            end
            if hh == 1
                namefig = strcat(path_res_net,'pie_hc.pdf');
            else namefig = strcat(path_res_net,'pie_admci.pdf');
            end
            print(namefig,'-dpdf','-r300')
            close all
        end
        
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
        gd_mean = mean(data);
        data_ga = data - repmat(gd_mean,[size(data,1),1]);
        avg_clust = zeros(max(part),size(data,2));
        for cc = 1:max(part)
            avg_clust(cc,:) = mean(data_ga(part==cc,:),1);
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
    
    % Visualize weights
    if fig_weights ==1
        figure
        opt_vr.limits = fig_limits_h;
        opt_vr.color_map = 'brewer_bgyor';
        niak_visu_matrix(weights(order,:),opt_vr)
        namefig = strcat(path_res_net,'weights.pdf');
        print(namefig,'-dpdf','-r300')
        close all
    end
    
    
    % Load phenotypic variables
    
    for n_var = 1:length(num_var)
        covar = tab(:,num_var(n_var));
        mask_covar = ~isnan(covar);
        model_covar.x = [ones(sum(mask_covar),1) niak_normalize_tseries([covar(mask_covar)],'mean')];
        model_covar.y = weights(mask_covar,:);
        covar = model_covar.y;
        model_covar.c = [0;1];
        opt_glm.test = 'ttest';
        opt_glm.flag_beta = true;
        %opt_glm.multisite = tab(:,num_multisite);
        res_covar = niak_glm(model_covar,opt_glm);
%         res_covar = niak_glm_multisite(model_covar,opt_glm);
        pce(n_var,:,n_net) = res_covar.pce;
        
        if fig_plots == 1
            if type_plot(n_var) ==1
                for n_subtype = 1:max(part)
                    figure
                    mask = model_covar.x(:,2)==min(model_covar.x(:,2));
                    var1_tmp = covar(:,n_subtype);
                    var1 = var1_tmp(mask);
                    cateye_po(var1,1,col(1,:),0.3)
                    hold on
                    mask = model_covar.x(:,2)==max(model_covar.x(:,2));
                    var2_tmp = covar(:,n_subtype);
                    var2 = var2_tmp(mask);
                    cateye_po(var2,2,col(2,:),0.3)
                    namefig = strcat(path_res_net,'plot_net_',num2str(num_net(n_net)), '_var_', num2str(num_var(n_var)), '_subtype_', num2str(n_subtype), '.pdf');
                    print(namefig,'-dpdf','-r300')
                    close all
                end
            else
                for n_subtype = 1:max(part)
                    figure
                    plot(model_covar.x(:,2),model_covar.y(:,n_subtype),'o','markersize',7,'markeredgecolor', (col(3,:)), 'markerfacecolor', (col(3,:)+[2 2 2])/3,'linewidth', 0.3);
                    hold on
                    beta = niak_lse(covar(:,n_subtype),[ones(size(covar(:,n_subtype))) model_covar.x(:,2)]);
                    plot(model_covar.x(:,2),[ones(size(covar(:,n_subtype))) model_covar.x(:,2)]*beta,'linewidth',0.3,'color', (col(3,:)));
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

%chi2
statschi(:,2) = niak_fdr(statschi,'BH',0.05);
opt.labels_x = name_net;
opt.labels_y = {'pchi2','qfdr'};
opt.precision = 5;
path_stats = [path_results 'chi2_stats.csv'];
niak_write_csv(path_stats,statschi,opt)



    



