%% regress sex age fd sites before subtypes, based on the run 1 of
%% preventad data
%% test associations with apoe, beta, tpao
%% 3 clusters

clear all

% paths
model = '/Users/pyeror/Work/transfert/PreventAD/models/all_model_20160303.csv';
path_data_select = '/Users/pyeror/Work/transfert/PreventAD/results/scores/preventad_run1_7/rmap_part_stack/';
path_data_sample1 = '/Users/pyeror/Work/transfert/PreventAD/results/scores/preventad_run1_7/rmap_part_stack/';
path_data_sample2 = '/Users/pyeror/Work/transfert/PreventAD/results/scores/preventad_run2_7/rmap_part_stack/';
path_mask = '/Users/pyeror/Work/transfert/PreventAD/results/scores/';
path_results = '/Users/pyeror/Work/transfert/PreventAD/results/subtype/preventad_20160303_subtype1/';

% subtyping
num_net = [1 2 3 4 5 6 7];
name_net = {'cer','lim','mot','vis','dmn','cen','san'};
nb_clus = 3;
name_clus = {'subt1','subt2','subt3'};
name_grp = {'pad1','pad2'};
num_select = 11; % = num_adni_mtl
num_sample = 11;
num_sex = 1;
num_age = 2;
num_fd1 = 34;
num_fd2 = 35;

% association
num_var = [16 17 18];
name_var = {'apoe4','beta','tpao'};
qfdr = 0.05;
type_plot = [1 2 2]; % 1=boxplot, 2=regression line
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
    
    % Load and extract betas from select data (intercept only)
    file_stack = [path_data_select,'stack_net_' num2str(num_net(n_net)) '.nii.gz'];
    [hdr,stack] = niak_read_vol(file_stack);
    [hdr,mask] = niak_read_vol([path_mask 'mask.nii.gz']);
    raw_data = niak_vol2tseries(stack,mask);
    
    sss = 0;
    for ss = 1:length(sub_id)
        if raw_tab(ss,num_select) == 1
            sss=sss+1;
            conf_tab(sss,:) = raw_tab(ss,:);
            conf_data(sss,:) = raw_data(sss,:);
        end
    end
    
    conf_x = [ones(size(conf_data,1),1) conf_tab(:,num_sex) conf_tab(:,num_age) conf_tab(:,num_fd)];
    conf_y = conf_data;
    conf_betas = (conf_x'*conf_x)\conf_x'*conf_y;
    
    % Get subtypes on select data (= sample data here)
    sss = 0;
    for ss = 1:length(sub_id)
        if raw_tab(ss,num_select) == 1
            sss=sss+1;
            subt_tab(sss,:) = raw_tab(ss,:);
            subt_data(sss,:) = raw_data(sss,:);
        end
    end
    subt_x = [ones(size(subt_data,1),1) subt_tab(:,num_sex) subt_tab(:,num_age) subt_tab(:,num_fd)];
    subt_y = subt_data;
    subt_betas = (subt_x'*subt_x)\subt_x'*subt_y;
    subt_data = subt_y-subt_x*subt_betas;
    
    % Run a cluster analysis on the processed maps
    R = niak_build_correlation(subt_data');
    hier = niak_hierarchical_clustering(R);
    part = niak_threshold_hierarchy(hier,struct('thresh',nb_clus));
    order = niak_hier2order(hier);
    save([path_res_net 'order.mat'],'order');
    save([path_res_net 'part.mat'],'part');
    
    % Contingency table (runs x subtypes)
    for cc = 1:nb_clus
        p=0;
        for pp = 1:length(part)
            if part(pp) == cc
                p=p+1;
            end
        end
        ct(1,cc) = p;
    end
        
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
            namefig = strcat(path_res_net,'pie_pad1.pdf');
            print(namefig,'-dpdf','-r300')
            close all
        
        % Write volumes
        % The average per cluster
        avg_clust_subt = zeros(max(part),size(subt_data,2));
        for cc = 1:max(part)
            avg_clust_subt(cc,:) = mean(subt_data(part==cc,:),1);
        end
        vol_avg_subt = niak_tseries2vol(avg_clust_subt,mask);
        hdr.file_name = [path_res_net 'mean_clusters.nii.gz'];
        niak_write_vol(hdr,vol_avg_subt);
        
        % The std per cluster
        avg_clust_subt = zeros(max(part),size(data,2));
        for cc = 1:max(part)
            avg_clust_subt(cc,:) = std(subt_data(part==cc,:),1);
        end
        vol_avg_subt = niak_tseries2vol(avg_clust_subt,mask);
        hdr.file_name = [path_res_net 'std_clusters.nii.gz'];
        niak_write_vol(hdr,vol_avg_subt);
        
        % The demeaned/z-ified per cluster
        gd_mean = mean(subt_data);
        subt_data_ga = subt_data - repmat(gd_mean,[size(data,1),1]);
        avg_clust = zeros(max(part),size(subt_data,2));
        for cc = 1:max(part)
            avg_clust(cc,:) = mean(subt_data_ga(part==cc,:),1);
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
    end
    
    
    %% GLM analysis
    
    for n_run = 1:2
        
        % Create ouptut directories
        path_res_net_run = [path_res_net '/run_' num2str(n_run) '/'];
        psom_mkdir(path_res_net_run)
        
        % Load data
        if n_run == 1
            path_data = path_data_sample1;
        else path_data = path_data_sample2;
        end
        
        file_stack = [path_data,'stack_net_' num2str(num_net(n_net)) '.nii.gz'];
        [hdr,stack] = niak_read_vol(file_stack);
        [hdr,mask] = niak_read_vol([path_mask 'mask.nii.gz']);
        raw_sample_data = niak_vol2tseries(stack,mask);
        
        sss = 0;
        for ss = 1:length(sub_id)
            if raw_tab(ss,num_sample) == 1
                sss=sss+1;
                sample_tab(sss,:) = raw_tab(ss,:);
                sample_data(sss,:) = raw_sample_data(sss,:);
                sample_id{sss} = sub_id{ss};
            end
        end
        
        % Regress confounds from select data
        if n_run == 1
            num_fd_run = num_fd1;
        else num_fd_run = num_fd2;
        end
        x = [ones(size(sample_data,1),1) sample_tab(:,num_sex) sample_tab(:,num_age) sample_tab(:,num_fd_run)];
        y = sample_data;
        data = y-x*conf_betas;
        
        
        
        
        
        
        
        
        % Weights
        for cc = 1:max(part)
            avg_clust(cc,:) = mean(subt_data(part==cc,:),1);
            weights(:,cc) = corr(data',avg_clust(cc,:)');
        end
        
        opt.labels_y = name_clus;
        opt.labels_x = sample_id;
        opt.precision = 3;
        if n_run ==1
            path = [path_res_net 'weights_1.csv'];
        else path = [path_res_net 'weights_2.csv'];
        end
        niak_write_csv(path,weights,opt);
        
        if n_run ==1
            R_w = niak_build_correlation(weights');
            hier_w = niak_hierarchical_clustering(R_w);
            part_w = niak_threshold_hierarchy(hier_w,struct('thresh',nb_clus));
            order_w = niak_hier2order(hier_w);
        end
        weights_order = weights(order_w,:);
        
        save([path_res_net 'weights_order.mat'],'weights_order');
        
        % Contingency table (pad x subtypes)
        [m,index] = max(weights');
        part_pad = index';
        
        for cc = 1:nb_clus
            p=0;
            for pp = 1:length(part_pad)
                if part_pad(pp) == cc
                    p=p+1;
                end
            end
            if n_run ==1
                ct(3,cc) = p;
            else ct(4,cc) = p;
            end
        end
        
        if n_run == 2
            [~,chi_hc_pad1,~] = chi2cont(ct(1:2:3,:));
            stats_chi(n_net,1) = chi_hc_pad1;
            [~,chi_hc_pad2,~] = chi2cont(ct(1:3:4,:));
            stats_chi(n_net,2) = chi_hc_pad2;
            [~,chi_admci_pad1,~] = chi2cont(ct(2:3,:));
            stats_chi(n_net,3) = chi_admci_pad1;
            [~,chi_admci_pad2,~] = chi2cont(ct(2:2:4,:));
            stats_chi(n_net,4) = chi_admci_pad2;
            
            opt.labels_x = name_grp;
            opt.labels_y = name_clus;
            opt.precision = 2;
            path_ct = [path_res_net 'chi2_ct.csv'];
            niak_write_csv(path_ct,ct,opt)
        end
        
        if fig_clust ==1
            % Pie charts
            figure
            if n_run ==1
                hh=3;
            else hh = 4;
            end
            h = pie(ct(hh,:));
            hp = findobj(h, 'Type', 'patch');
            colormap(brewer_bgyor);
            colors = colormap;
            step = round((size(colors,1)/nb_clus)-1);
            for cc = 1:nb_clus
                colorpie(cc,:) = colors(step*cc,:);
                set(hp(cc),'FaceColor', colorpie(cc,:));
            end
            if n_run ==1
                namefig = strcat(path_res_net,'pie_pad_1.pdf');
            else namefig = strcat(path_res_net,'pie_pad_2.pdf');
            end
            print(namefig,'-dpdf','-r300')
            close all
            
            % Visualize dendrograms
            figure
            niak_visu_dendrogram(hier_w);
            namefig = strcat(path_res_net,'dendrogram_w.pdf');
            print(namefig,'-dpdf','-r300')
            
            % Visualize the matrices
            figure
            opt_vr.limits = fig_limits_h;
            opt_vr.color_map = 'brewer_bgyor';
            niak_visu_matrix(R_w(order_w,order_w),opt_vr);
            namefig = strcat(path_res_net,'matrix_w.pdf');
            print(namefig,'-dpdf','-r300')
            figure
            opt_p.flag_labels = true;
            opt_p.type_map = 'brewer_bgyor';
            niak_visu_part_po(part_w(order_w),opt_p);
            namefig = strcat(path_res_net,'clusters_w.pdf');
            print(namefig,'-dpdf','-r300')
            close all
            
            % Visualize weights
            figure
            opt_vr.limits = fig_limits_h;
            opt_vr.color_map = 'brewer_bgyor';
            niak_visu_matrix(weights_order,opt_vr)
            if n_run == 1
                namefig = strcat(path_res_net,'weights_order_1.pdf');
            else namefig = strcat(path_res_net,'weights_order_2.pdf');
            end
            print(namefig,'-dpdf','-r300')
            close all
        end
        
        %ICC
        if n_run == 1
            weights1 = weights;
        else weights2 = weights;
        end
        
        if n_run == 2
            for cc = 1:nb_clus
                repro_weights(cc,n_net) = IPN_icc([weights1(:,cc) weights2(:,cc)],2,'single');
            end
        end
        
        
        % Load phenotypic variables
        
        for n_var = 1:length(num_var)
            covar = sample_tab(:,num_var(n_var));
            mask_covar = ~isnan(covar);
            model_covar.x = [ones(sum(mask_covar),1) niak_normalize_tseries([covar(mask_covar)],'mean')]; %%% pq normaliser ici???
            model_covar.y = weights(mask_covar,:);
            covar = model_covar.y;
            model_covar.c = [0;1];
            opt_glm.test = 'ttest';
            opt_glm.flag_beta = true;
            res_covar = niak_glm(model_covar,opt_glm);
            
            if n_run == 1
                pce1(n_var,:,n_net) = res_covar.pce;
            else pce2(n_var,:,n_net) = res_covar.pce;
            end
            
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
                        namefig = strcat(path_res_net_run,'plot_net_',num2str(num_net(n_net)), '_var_', num2str(num_var(n_var)), '_subtype_', num2str(n_subtype), '.pdf');
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
                        namefig = strcat(path_res_net_run,'plot_net_',num2str(num_net(n_net)), '_var_', num2str(num_var(n_var)), '_subtype_', num2str(n_subtype), '.pdf');
                        print(namefig,'-dpdf','-r300')
                        close all
                    end
                end
            end
        end
    end
end


%% t-test stats
%run1
for n_var = 1:length(num_var)
    pce_single1 = pce1(n_var,:,:);
    [fdr,test_single1] = niak_fdr(pce_single1(:),'BH',qfdr);
    test_singletmp1(n_var,:,:) = test_single1;
end

test_single1 = reshape(test_singletmp1,size(pce1));

[fdr,test1] = niak_fdr(pce1(:),'BH',qfdr);
test_all1 = reshape(test1,size(pce1));

save([path_results 'test_fdr_all_run1.mat'],'test_all1');
save([path_results 'test_fdr_single_run1.mat'],'test_single1');
save([path_results 'pce_all_run1.mat'],'pce1');

%run2
for n_var = 1:length(num_var)
    pce_single2 = pce2(n_var,:,:);
    [fdr,test_single2] = niak_fdr(pce_single2(:),'BH',qfdr);
    test_singletmp2(n_var,:,:) = test_single2;
end

test_single2 = reshape(test_singletmp2,size(pce2));

[fdr,test2] = niak_fdr(pce2(:),'BH',qfdr);
test_all2 = reshape(test2,size(pce2));

save([path_results 'test_fdr_all_run2.mat'],'test_all2');
save([path_results 'test_fdr_single_run2.mat'],'test_single2');
save([path_results 'pce_all_run2.mat'],'pce2');


%% Findings .csv

% weights
file_write = [path_results 'ICC_weights.csv'];
opt.labels_x = name_clus;
opt.labels_y = name_net; 
niak_write_csv(file_write,repro_weights,opt)

% chi2
opt.labels_x = name_net;
opt.labels_y = {'hc_pad1','hc_pad2','admci_pad1','admci_pad2'};
opt.precision = 5;
path_stats = [path_results 'chi2_stats.csv'];
niak_write_csv(path_stats,stats_chi,opt)

% t-test
opt.labels_y = name_var;

for name_n = 1:length(name_net)
    for name_c = 1:length(name_clus)
        name_all = 1+(nb_clus*(name_n-1))+(name_c-1);
        opt.labels_x{name_all} = strcat(name_net{name_n},'_',name_clus{name_c});
    end
end

% run1
for n_net = 1:length(num_net)
    nn1 = 1+(nb_clus*(n_net-1));
    nn2 = nb_clus+(nb_clus*(n_net-1));
    pce1_csv(nn1:nn2,:) = pce1(:,:,n_net)';
    test_all1_csv(nn1:nn2,:) = test_all1(:,:,n_net)';
    test_single1_csv(nn1:nn2,:) = test_single1(:,:,n_net)';
end

path_res_pce = [path_results 'pce1.csv'];
path_res_test_all = [path_results 'test_all1.csv'];
path_res_test_single = [path_results 'test_single1.csv'];

opt.precision = 0;
niak_write_csv(path_res_test_all,test_all1_csv,opt);
opt.precision = 0;
niak_write_csv(path_res_test_single,test_single1_csv,opt);
opt.precision = 5;
niak_write_csv(path_res_pce,pce1_csv,opt);

% run2
for n_net = 1:length(num_net)
    nn1 = 1+(nb_clus*(n_net-1));
    nn2 = nb_clus+(nb_clus*(n_net-1));
    pce2_csv(nn1:nn2,:) = pce2(:,:,n_net)';
    test_all2_csv(nn1:nn2,:) = test_all2(:,:,n_net)';
    test_single2_csv(nn1:nn2,:) = test_single2(:,:,n_net)';
end

path_res_pce = [path_results 'pce2.csv'];
path_res_test_all = [path_results 'test_all2.csv'];
path_res_test_single = [path_results 'test_single2.csv'];

opt.precision = 0;
niak_write_csv(path_res_test_all,test_all2_csv,opt);
opt.precision = 0;
niak_write_csv(path_res_test_single,test_single2_csv,opt);
opt.precision = 5;
niak_write_csv(path_res_pce,pce2_csv,opt);

    



