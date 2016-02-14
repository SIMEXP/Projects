clear all

% Variables

num_scale = 7;
val_qfdr = 0.05;
num_net = [1 2 3 4 5 6 7]; % networks s7
name_net = {'cer','lim','mot','vis','dmn','fpa','cos'};
num_var = [4 5 6]; % num variable in model.csv
name_var = {'mci_ctl','ad_ctl','ad_mci'}; % name variable in model.csv
type_plot = [1 1 1]; % 1=boxplot, 2=regression line
num_fd1 = 7; % num FD variable in model.csv, used as confounding variable
num_age = 2;
num_sex = 1;
nb_clus = 3; % nb clusters in clustering
name_clus = {'subt1','subt2','subt3'};
model = '/Users/pyeror/Work/transfert/PreventAD/models/model_adni_20160121.csv';
path_data_1 = '/Users/pyeror/Work/transfert/PreventAD/results/scores/adni/rmap_part/';
path_stack_1 = '/Users/pyeror/Work/transfert/PreventAD/results/scores/adni_7/rmap_stack/';
path_subtype = '/Users/pyeror/Work/transfert/PreventAD/results/subtype/nki_3subtypes_scale7_TR2500_rmaps_20160127/';
path_results = '/Users/pyeror/Work/transfert/PreventAD/results/subtype/adni_148_7networks_3x3NKIsubtypes_rmaps_categorical_confounds_BH05/';
save_figs_clust = 1; % 1 = save, 0 do not save
save_figs_plots = 1; % 1 = save, 0 do not save
save_figs_weights = 1; % 1 = save, 0 do not save

% Read model file
[tab,sub_id,labels_y,labels_id] = niak_read_csv(model);

% Create main ouptut directory
psom_mkdir(path_results)

% Structures for stats

struct_test = zeros(length(num_var),nb_clus*nb_clus,length(num_net));
pce1 = struct_test;
test_fdr_single1 = struct_test;



for n_net = 1:length(num_net)
    
    % Create ouptut directories
    path_res_net = [path_results 'net_'  num2str(num_net(n_net)) '_' name_net{n_net} '_' num2str(nb_clus) 'clusters' filesep];
    psom_mkdir(path_res_net)
    
    for n_clus = 1:nb_clus
        path_res_clus = [path_res_net 'clus_' num2str(n_clus) filesep];
        psom_mkdir(path_res_clus)
    end
    
    
    %% Winner-take-all on weights for each network/subtype
    
    % Mean corrected tseries for target tseries
    file_stack1 = [path_stack_1,'stack_net',num2str(num_net(n_net)),'.nii.gz'];
    [hdr,stab1] = niak_read_vol(file_stack1);
    [hdr,mask] = niak_read_vol([path_stack_1 'mask.nii.gz']);
    tseries1 = niak_vol2tseries(stab1,mask);
    gd_mean1 = mean(tseries1);
    tseries_ga1 = tseries1 - repmat(gd_mean1,[size(tseries1,1),1]);
    
    % weights (target onto reference, eg ADNI on NKI)
    [hdrs,ref] = niak_read_vol([path_subtype 'net_'  num2str(num_net(n_net)) '_' name_net{n_net} '_' num2str(nb_clus) 'clusters/run1_mean_cluster_demeaned.nii.gz']);
    for n_clus = 1:nb_clus
        refclus = ref(:,:,:,n_clus);
        tseries_ref(n_clus,:) = niak_vol2tseries(refclus,mask);
        weights(:,n_clus) = corr(tseries_ga1',tseries_ref(n_clus,:)');
    end
    [m,index] = max(weights');
    part = index';
    
    % save weights assignements
    taball = [];
    w = size(tab,2)+1;
    taball = tab;
    taball(:,w) = part;
    opt.labels_x = sub_id;
    labels_y{w} ='part';
    opt.labels_y = labels_y;
    path_res_csv = [path_res_net 'model_net_' num2str(num_net(n_net)) '_' name_net{n_net} '_part_all.csv'];
    niak_write_csv(path_res_csv,taball,opt);
    
    p1 = 0;
    p2 = 0;
    p3 = 0;
    tab1 = [];
    tab2 = [];
    tab3 = [];
    x1 = [];
    x2 = [];
    x3 = [];
    
    for n_sub = 1:length(taball) % ! only works with 3 reference subtypes
        if taball(n_sub,w) == 1
            p1 = p1+1;
            tab1(p1,:) = taball(n_sub,:);
            x1{p1} = sub_id{n_sub};
        elseif taball(n_sub,w) == 2
            p2 = p2+1;
            tab2(p2,:) = taball(n_sub,:);
            x2{p2} = sub_id{n_sub};
        elseif taball(n_sub,w) == 3
            p3 = p3+1;
            tab3(p3,:) = taball(n_sub,:);
            x3{p3} = sub_id{n_sub};
        end
    end
    
    opt.labels_x = x1;
    path_res_clus1 = [path_res_net 'clus_1/model_net_' num2str(num_net(n_net)) '_' name_net{n_net} '_clus1.csv'];
    niak_write_csv(path_res_clus1,tab1,opt);
    
    opt.labels_x = x2;
    path_res_clus2 = [path_res_net 'clus_2/model_net_' num2str(num_net(n_net)) '_' name_net{n_net} '_clus2.csv'];
    niak_write_csv(path_res_clus2,tab2,opt);
    
    opt.labels_x = x3;
    path_res_clus3 = [path_res_net 'clus_3/model_net_' num2str(num_net(n_net)) '_' name_net{n_net} '_clus3.csv'];
    niak_write_csv(path_res_clus3,tab3,opt);
    
    
    %% Clustering: subtypes (target) of subtypes (matched to reference)
    
    alltseries1 = tseries1;
    
    for n_clus = 1:nb_clus
        
        path_res_clus = [path_res_net 'clus_' num2str(n_clus) filesep];
        
        % Mean corrected target tseries for single reference subtype
        ptmp= 0;
        tseries1 = [];
        tseries_ga1 = [];
        for n_sub = 1:length(taball)
            if taball(n_sub,w) == n_clus
                ptmp = ptmp + 1;
                tseries1(ptmp,:) = alltseries1(n_sub,:);
            end
        end
        gd_mean1 = mean(tseries1);
        tseries_ga1 = tseries1 - repmat(gd_mean1,[size(tseries1,1),1]);
        
        % Run a cluster analysis on the demeaned maps
        part = [];
        order = [];
        R = corr(tseries_ga1');
        hier = niak_hierarchical_clustering(R);
        part = niak_threshold_hierarchy(hier,struct('thresh',nb_clus));
        order = niak_hier2order(hier);
        save([path_res_clus 'net_' num2str(num_net(n_net)) '_clus_' num2str(n_clus) '_order.mat'],'order');
        save([path_res_clus 'net_' num2str(num_net(n_net)) '_clus_' num2str(n_clus) '_part.mat'],'part');
        
        if save_figs_clust ==1
            
            % Visualize dendrograms
            figure
            niak_visu_dendrogram(hier);
            namefig = strcat(path_res_clus,'dendrogram.pdf');
            print(namefig,'-dpdf','-r300')
            
            % Visualize the matrices
            figure
            opt_vr.limits = [-0.3 0.3];
            niak_visu_matrix(R(order,order),opt_vr);
            namefig = strcat(path_res_clus,'matrix.pdf');
            print(namefig,'-dpdf','-r300')
            figure
            opt_p.flag_labels = true;
            niak_visu_part(part(order),opt_p);
            namefig = strcat(path_res_clus,'clusters.pdf');
            print(namefig,'-dpdf','-r300')
            close all
            
            stab = stab1;
            tseries  = tseries1;
            tseries_ga = tseries_ga1;
            name = 'run1';
            
            % Visualize the cluster means
            ind_visu = 1:max(part);
            opt_vp.vol_limits = [0 1];
            gd_avg = mean(stab,4);
            for cc = ind_visu
                figure
                niak_montage(mean(stab(:,:,:,part==cc),4),opt_vp);
                title(sprintf('Average cluster %i',cc))
                namefig = strcat(path_res_clus,name, '_average_cluster_', num2str(cc), '.pdf');
                print(namefig,'-dpdf','-r600')
            end
            figure
            niak_montage(gd_avg,opt_vp);
            title('Grand average')
            namefig = strcat(path_res_clus,name,'_grand_average.pdf');
            print(namefig,'-dpdf','-r600')
            close all
            
            % Visualize the cluster means, after substraction of the mean
            opt_vp.vol_limits = [-0.2 0.2];
            opt_vp.type_color = 'hot_cold';
            ind_visu = 1:max(part);
            gd_avg = mean(stab,4);
            for cc = ind_visu
                figure
                niak_montage(mean(stab(:,:,:,part==cc),4)-gd_avg,opt_vp);
                title(sprintf('Average cluster %i',cc))
                namefig = strcat(path_res_clus,name,'_diff_average_cluster_', num2str(cc), '.pdf');
                print(namefig,'-dpdf','-r600')
            end
            close all
            
            
            % Write volumes
            % The average per cluster
            avg_clust_raw = zeros(max(part),size(tseries,2));
            for cc = 1:max(part)
                avg_clust_raw(cc,:) = mean(tseries(part==cc,:),1);
            end
            vol_avg_raw = niak_tseries2vol(avg_clust_raw,mask);
            hdr.file_name = [path_res_clus name '_mean_clusters.nii.gz'];
            niak_write_vol(hdr,vol_avg_raw);
            
            % The demeaned, z-ified volumes
            avg_clust = zeros(max(part),size(tseries,2));
            for cc = 1:max(part)
                avg_clust(cc,:) = mean(tseries_ga(part==cc,:),1);
            end
            avg_clust = niak_normalize_tseries(avg_clust','median_mad')';
            vol_avg = niak_tseries2vol(avg_clust,mask);
            hdr.file_name = [path_res_clus name '_mean_cluster_demeaned.nii.gz'];
            niak_write_vol(hdr,vol_avg);
            
            hdr.file_name = [path_res_clus name '_grand_mean_clusters.nii.gz'];
            niak_write_vol(hdr,mean(stab,4));
        end
        
        
        %% GLM analysis
        
        % Load phenotypic variables
        tabc = [];
        sub_idc = [];
        [tabc,sub_idc,labels_yc,~] = niak_read_csv([path_res_clus 'model_net_' num2str(num_net(n_net)) '_' name_net{n_net} '_clus' num2str(n_clus) '.csv']);
        
        % Weights
        avg_clust1 = [];
        weights1 = [];
        for cc = 1:max(part)
            avg_clust1(cc,:) = mean(tseries_ga1(part==cc,:),1);
            weights1(:,cc) = corr(tseries_ga1',avg_clust1(cc,:)');
        end
        save([path_res_clus 'net_' num2str(num_net(n_net)) '_clus_' num2str(n_clus) '_weights.mat'],'weights1');
        
        opt.labels_y = name_clus;
        opt.labels_x = sub_idc;
        path = [path_res_clus 'weights_net' num2str(num_net(n_net)) '_clus' num2str(n_clus) '.csv'];
        opt.precision = 3;
        niak_write_csv(path,weights1,opt);
        
        if save_figs_weights ==1
            figure
            niak_visu_matrix(weights1(order,:))
            namefig = [path_res_clus 'weights_net' num2str(num_net(n_net)) '_clus' num2str(n_clus) '.pdf'];
            print(namefig,'-dpdf','-r300')
            close all
        end
        
        
        % GLM
        for n_var = 1:length(num_var)
            covar = tabc(:,num_var(n_var));
            mask_covar = ~isnan(covar);
            fd1 = tabc(:,num_fd1);
            age = tabc(:,num_age);
            sex = tabc(:,num_sex);
            model_covar.x = [ones(sum(mask_covar),1) niak_normalize_tseries([covar(mask_covar) fd1(mask_covar) sex(mask_covar) age(mask_covar)],'mean')];
            model_covar.y = weights1(mask_covar,:);
            covar1 = model_covar.y;
            model_covar.c = [0;1;0;0;0];
            opt_glm.test = 'ttest';
            opt_glm.flag_beta = true;
            res_covar1 = niak_glm(model_covar,opt_glm);
            
            if n_clus ==1 % ! only works with 3 reference subtypes
                clus = 1:3;
            elseif n_clus == 2
                clus = 4:6;
            elseif n_clus ==3
                clus = 7:9;
            end
            
            pce1(n_var,clus,n_net) = res_covar1.pce;
            
            
            if save_figs_plots == 1
                if type_plot(n_var) ==1 % boxplot
                    for n_subtype = 1:max(part)
                        figure
                        mask_model = model_covar.x(:,2)==min(model_covar.x(:,2));
                        plot(mask_model+1+0.1*randn(size(mask_model)),covar1(:,n_subtype),'.','markersize',20)
                        hold on
                        boxplot(covar1(:,n_subtype),mask_model);
                        bh = boxplot(covar1(:,n_subtype),mask_model);
                        set(bh(:,1),'linewidth',0.5);
                        set(bh(:,2),'linewidth',0.5);
                        namefig = strcat(path_res_clus,'plot_net_',num2str(num_net(n_net)), '_var_', num2str(num_var(n_var)), '_subtype_', num2str(n_subtype), '_clus_', num2str(n_clus),'.pdf');
                        print(namefig,'-dpdf','-r300')
                        close all
                    end
                else
                    for n_subtype = 1:max(part)
                        figure
                        plot(model_covar.x(:,2),model_covar.y(:,n_subtype),'.','markersize',20);
                        hold on
                        beta = niak_lse(covar1(:,n_subtype),[ones(size(covar1(:,n_subtype))) model_covar.x(:,2)]);
                        plot(model_covar.x(:,2),[ones(size(covar1(:,n_subtype))) model_covar.x(:,2)]*beta,'r','linewidth',0.7);
                        namefig = strcat(path_res_clus,'plot_net_',num2str(num_net(n_net)), '_var_', num2str(num_var(n_var)), '_subtype_', num2str(n_subtype), '_clus_', num2str(n_clus),'.pdf');
                        print(namefig,'-dpdf','-r300')
                        close all
                    end
                end
            end
        end   
    end
end
    
    
    
%% Stats

for n_var = 1:length(num_var)
    pce_single1 = pce1(n_var,:,:);
    [fdr,test_single1] = niak_fdr(pce_single1(:),'BH',val_qfdr);
    test_single1tmp(n_var,:,:) = test_single1;
end

test_single1 = reshape(test_single1tmp,size(pce1));

[fdr,test1] = niak_fdr(pce1(:),'BH',val_qfdr);
test_all1 = reshape(test1,size(pce1));


save([path_results 'test_run_1_fdr_all.mat'],'test_all1');
save([path_results 'test_run_1_fdr_single.mat'],'test_single1');
save([path_results 'pce_run_1_all.mat'],'pce1');


% Save findings as csv

clus = nb_clus * nb_clus;

for n_net = 1:length(num_net)
    nn1 = 1+(clus*(n_net-1));
    nn2 = clus+(clus*(n_net-1));
    pce1_csv(nn1:nn2,:) = pce1(:,:,n_net)';
    test_all1_csv(nn1:nn2,:) = test_all1(:,:,n_net)';
    test_single1_csv(nn1:nn2,:) = test_single1(:,:,n_net)';
end

opt.labels_y = name_var;

for name_n = 1:length(name_net)
    for name_s = 1:length(name_clus)
        for name_c = 1:length(name_clus)
            name_all = 1+(clus*(name_n-1))+(nb_clus*(name_s-1))+(name_c-1);
            opt.labels_x{name_all} = strcat(name_net{name_n},'_',name_clus{name_s},'_',name_clus{name_c});
        end
    end
end

path_res_pce1 = [path_results 'pce1.csv'];
path_res_test_all1 = [path_results 'test_all1.csv'];
path_res_test_single1 = [path_results 'test_single1.csv'];

opt.precision = 0;
niak_write_csv(path_res_test_all1,test_all1_csv,opt);

opt.precision = 0;
niak_write_csv(path_res_test_single1,test_single1_csv,opt);

opt.precision = 5;
niak_write_csv(path_res_pce1,pce1_csv,opt);




