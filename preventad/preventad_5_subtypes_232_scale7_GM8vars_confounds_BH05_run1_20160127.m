clear all

num_scale = 7; 
val_qfdr = 0.05;
num_net = [1 2 3 4 5 6 7]; % networks s7
name_net = {'cer','lim','mot','vis','dmn','fpa','cos'};
num_var = [76 77 78 79 80 81 82 83]; % num variable in model.csv
name_var = {'par','occ','fro','tem','cer','bg','cau','hpa'}; % name variable in model.csv
type_plot = [2 2 2 2 2 2 2 2]; % 1=boxplot, 2=regression line
num_fd1 = 18; % num FD variable in model.csv, used as confounding variable
num_age = 1;
num_sex = 2;
nb_clus = 5; % nb clusters in clustering
name_clus = {'subt1','subt2','subt3','subt4','subt5'};
model = '/Users/pyeror/Work/transfert/PreventAD/models/adsf_model_preventad_bl_dr2_20160127_noout.csv';
template_file = 'rest1_rmap_part.nii.gz';
path_data_1 = '/Users/pyeror/Work/transfert/PreventAD/results/scores/preventad_7/rmap_part_run1/';
path_stack_1 = '/Users/pyeror/Work/transfert/PreventAD/results/scores/preventad_7/rmap_stack_run1/';
path_results = '/Users/pyeror/Work/transfert/PreventAD/results/subtype/preventad_232_s7_5subtypes_rmaps_GM8vars_BH05_confounds_run1/';
save_figs_clust = 1; % 1 = save, 0 do not save
save_figs_plots = 1; % 1 = save, 0 do not save
save_figs_weights = 0; % 1 = save, 0 do not save

% Read model file
[tab,sub_id,labels_y,labels_id] = niak_read_csv(model);

% Create main ouptut directory
psom_mkdir(path_results)


%% stack maps

for nnet = 1:length(num_net)
    for id = 1:size(sub_id,1)
        sub_name = sub_id{id,1};
        tag = 'NAP';
        nap = findstr(tag,sub_name);
        if isempty(nap)
            file_sub_vol = [path_data_1 'fmri_' sub_name '_PREBL00_' template_file];
        else file_sub_vol = [path_data_1 'fmri_' sub_name '_NAPBL00_' template_file];
        end
        
        [hdr,sub_vol] = niak_read_vol(file_sub_vol);
        stack(:,:,:,id) = sub_vol(:,:,:,nnet);
    end
    hdr.file_name = [path_results,'stack_net',num2str(nnet),'.nii.gz'];
    niak_write_vol(hdr,stack);
    mean_stack(:,:,:,nnet) = mean(stack,4);
    std_stack(:,:,:,nnet) = std(stack,0,4);
end

hdr.file_name = [path_results,'stack_mean','.nii.gz'];
niak_write_vol(hdr,mean_stack);
hdr.file_name = [path_results,'stack_std','.nii.gz'];
niak_write_vol(hdr,std_stack);



%% Clustering

struct_test = zeros(length(num_var),nb_clus,length(num_net));
pce1 = struct_test;
test_fdr_single1 = struct_test;


for n_net = 1:length(num_net)
    
    % Create ouptut directories
    path_res_net = [path_results 'net_'  num2str(num_net(n_net)) '_' name_net{n_net} '_' num2str(nb_clus) 'clusters' filesep];
    psom_mkdir(path_res_net)
    
    % Load data
    file_stack1 = [path_stack_1,'stack_net',num2str(num_net(n_net)),'.nii.gz'];
    [hdr,stab1] = niak_read_vol(file_stack1);
    
    [hdr,mask] = niak_read_vol([path_stack_1 'mask.nii.gz']);
    
    tseries1 = niak_vol2tseries(stab1,mask);
    
    % correct for the mean
    gd_mean1 = mean(tseries1);
    tseries_ga1 = tseries1 - repmat(gd_mean1,[size(tseries1,1),1]);
    
    % Run a cluster analysis on the demeaned maps
    R = corr(tseries_ga1');
    hier = niak_hierarchical_clustering(R);
    part = niak_threshold_hierarchy(hier,struct('thresh',nb_clus));
    order = niak_hier2order(hier);
    save([path_res_net 'net_' num2str(num_net(n_net)) '_order.mat'],'order');
    save([path_res_net 'net_' num2str(num_net(n_net)) '_part.mat'],'part');
    
    
    if save_figs_clust ==1
        
        % Visualize dendrograms
        figure
        niak_visu_dendrogram(hier);
        namefig = strcat(path_res_net,'dendrogram.pdf');
        print(namefig,'-dpdf','-r300')
        
        % Visualize the matrices
        figure
        opt_vr.limits = [-0.3 0.3];
        niak_visu_matrix(R(order,order),opt_vr);
        namefig = strcat(path_res_net,'matrix.pdf');
        print(namefig,'-dpdf','-r300')
        figure
        opt_p.flag_labels = true;
        niak_visu_part(part(order),opt_p);
        namefig = strcat(path_res_net,'clusters.pdf');
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
            namefig = strcat(path_res_net,name, '_average_cluster_', num2str(cc), '.pdf');
            print(namefig,'-dpdf','-r600')
        end
        figure
        niak_montage(gd_avg,opt_vp);
        title('Grand average')
        namefig = strcat(path_res_net,name,'_grand_average.pdf');
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
            namefig = strcat(path_res_net,name,'_diff_average_cluster_', num2str(cc), '.pdf');
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
        hdr.file_name = [path_res_net name '_mean_clusters.nii.gz'];
        niak_write_vol(hdr,vol_avg_raw);
        
        % The demeaned, z-ified volumes
        avg_clust = zeros(max(part),size(tseries,2));
        for cc = 1:max(part)
            avg_clust(cc,:) = mean(tseries_ga(part==cc,:),1);
        end
        avg_clust = niak_normalize_tseries(avg_clust','median_mad')';
        vol_avg = niak_tseries2vol(avg_clust,mask);
        hdr.file_name = [path_res_net name '_mean_cluster_demeaned.nii.gz'];
        niak_write_vol(hdr,vol_avg);
        
        hdr.file_name = [path_res_net name '_grand_mean_clusters.nii.gz'];
        niak_write_vol(hdr,mean(stab,4));
        
    end
    
    
    %% GLM analysis
    
    % Build loads
    for cc = 1:max(part)
        avg_clust1(cc,:) = mean(tseries_ga1(part==cc,:),1);
        weights1(:,cc) = corr(tseries_ga1',avg_clust1(cc,:)');
    end
    
    save([path_res_net 'net_' num2str(num_net(n_net)) '_' name_net{n_net} '_weights.mat'],'weights1');
    
    opt.labels_y = name_clus;
    opt.labels_x = sub_id;
    path = [path_results 'weights_net' num2str(num_net(n_net)) '.csv'];
    opt.precision = 3;
    niak_write_csv(path,weights1,opt);
    
    if save_figs_weights ==1
        % Visualize weights
        figure
        niak_visu_matrix(weights1(order,:))
        namefig = strcat(path_res_net,'weights.pdf');
        print(namefig,'-dpdf','-r300')
    end
    
    
    % Load phenotypic variables
    
    [tab2,sub_id,labels_y,labels_id] = niak_read_csv(model);
    
    
    for n_var = 1:length(num_var)
        covar = tab2(:,num_var(n_var));
        mask_covar = ~isnan(covar);
        fd1 = tab2(:,num_fd1);
        age = tab2(:,num_age);
        sex = tab2(:,num_sex);
        model_covar.x = [ones(sum(mask_covar),1) niak_normalize_tseries([covar(mask_covar) fd1(mask_covar) sex(mask_covar) age(mask_covar)],'mean')];
        model_covar.y = weights1(mask_covar,:);
        covar1 = model_covar.y;
        model_covar.c = [0;1;0;0;0];
        opt_glm.test = 'ttest';
        opt_glm.flag_beta = true;
        res_covar1 = niak_glm(model_covar,opt_glm);
        pce1(n_var,:,n_net) = res_covar1.pce;
        
        
        if save_figs_plots == 1
            if type_plot(n_var) ==1 % boxplot
                for n_subtype = 1:max(part)
                    figure
                    mask = model_covar.x(:,2)==min(model_covar.x(:,2));
                    plot(mask+1+0.1*randn(size(mask)),covar1(:,n_subtype),'.','markersize',20)
                    hold on
                    boxplot(covar1(:,n_subtype),mask);
                    bh = boxplot(covar1(:,n_subtype),mask);
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
                    beta = niak_lse(covar1(:,n_subtype),[ones(size(covar1(:,n_subtype))) model_covar.x(:,2)]);
                    plot(model_covar.x(:,2),[ones(size(covar1(:,n_subtype))) model_covar.x(:,2)]*beta,'r','linewidth',0.7);
                    namefig = strcat(path_res_net,'plot_net_',num2str(num_net(n_net)), '_var_', num2str(num_var(n_var)), '_subtype_', num2str(n_subtype), '.pdf');
                    print(namefig,'-dpdf','-r300')
                    close all
                end
            end
        end
    end
end

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


%% Findings .csv

for n_net = 1:length(num_net)
    nn1 = 1+(nb_clus*(n_net-1));
    nn2 = nb_clus+(nb_clus*(n_net-1));
    pce1_csv(nn1:nn2,:) = pce1(:,:,n_net)';
    test_all1_csv(nn1:nn2,:) = test_all1(:,:,n_net)';
    test_single1_csv(nn1:nn2,:) = test_single1(:,:,n_net)';
end

opt.labels_y = name_var;

for name_n = 1:length(name_net)
    for name_c = 1:length(name_clus)
        name_all = 1+(nb_clus*(name_n-1))+(name_c-1);
        opt.labels_x{name_all} = strcat(name_net{name_n},'_',name_clus{name_c});
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




