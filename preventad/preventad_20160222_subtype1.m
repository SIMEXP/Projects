%% regress sex age fd
%% subtypes on run 1
%% ICC weights runs 1 & 2
%% test associations, for each run, with other biomarkers (apoe4, beta, tau, apoecsf, hp volume)
%% idea is to look for associations on PreventAD subtypes, then to match these to ADMCI subtypes

clear all

% paths
model = '/Users/pyeror/Work/transfert/PreventAD/models/preventad_model_20160222.csv';
path_data1 = '/Users/pyeror/Work/transfert/PreventAD/results/scores/preventad_run1_7/rmap_part_stack/';
path_data2 = '/Users/pyeror/Work/transfert/PreventAD/results/scores/preventad_run2_7/rmap_part_stack/';
path_mask = '/Users/pyeror/Work/transfert/PreventAD/results/scores/';
path_results = '/Users/pyeror/Work/transfert/PreventAD/results/subtype/preventad_20160222_subtype1/';

% subtyping
num_net = [2 5 6 7];
name_net = {'lim','dmn','cen','san'};
nb_clus = 4;
name_clus = {'subt1','subt2','subt3','subt4'};
regress_conf = 1; % 1 = yes, 0 = no

% association
num_var = [5 6 7 8 9];
name_var = {'apoe4','beta','tau','apoecsf','hp'};
num_sex = 1;
num_age = 2;
num_fd1 = 3;
num_fd2 = 4;
qfdr = 0.05;
type_plot = [1 2 2 2 2];

% save: 1 = save, 0 do not save
fig_clust = 1;
fig_plots = 0;
fig_weights = 1;
fig_limits = [-0.5 0.5];

% Read model file
[tab,sub_id,labels_y,labels_id] = niak_read_csv(model);

% Create main ouptut directory
psom_mkdir(path_results)

struct_test = zeros(length(num_var),nb_clus,length(num_net));
pce1 = struct_test;
test_fdr_single1 = struct_test;
pce2 = struct_test;
test_fdr_single2 = struct_test;


%% Clustering

struct_test = zeros(length(num_var),nb_clus,length(num_net));
pce = struct_test;
test_fdr_single = struct_test;


for n_net = 1:length(num_net)
    
    % Create ouptut directories
    path_res_net = [path_results 'net_' num2str(num_net(n_net)) '/'];
    psom_mkdir(path_res_net)
    
    for n_run = 1:2
        
        % Create ouptut directories
        path_res_run = [path_res_net '/run_' num2str(n_run) '/'];
        psom_mkdir(path_res_run)
        
        % Load data
        if n_run == 1
            path_data = path_data1;
        else path_data = path_data2;
        end
        
        file_stack = [path_data,'stack_net_' num2str(num_net(n_net)) '.nii.gz'];
        [hdr,stack] = niak_read_vol(file_stack);
        [hdr,mask] = niak_read_vol([path_mask 'mask.nii.gz']);
        raw_data = niak_vol2tseries(stack,mask);
        
        % Regress confounds tab(:,num_fd) tab(:,num_age) tab(:,num_sex)
        if regress_conf == 1
            if n_run == 1
                num_fd = num_fd1;
            else num_fd = num_fd2;
            end
            x = [ones(length(sub_id),1) tab(:,num_fd) tab(:,num_age) tab(:,num_sex)];
            y = raw_data;
            beta = (x'*x)\x'*y;
            data = y-x*beta;
        end
        
        if n_run == 1
            % Run a cluster analysis on the processed maps
            R = niak_build_correlation(data');
            hier = niak_hierarchical_clustering(R);
            part = niak_threshold_hierarchy(hier,struct('thresh',nb_clus));
            order = niak_hier2order(hier);
            save([path_res_run 'order.mat'],'order');
            save([path_res_run 'part.mat'],'part');
            
            % Figs
            if fig_clust ==1
                
                % Visualize dendrograms
                figure
                niak_visu_dendrogram(hier);
                namefig = strcat(path_res_run,'dendrogram.pdf');
                print(namefig,'-dpdf','-r300')
                
                % Visualize the matrices
                figure
                opt_vr.limits = fig_limits;
                niak_visu_matrix(R(order,order),opt_vr);
                namefig = strcat(path_res_run,'matrix.pdf');
                print(namefig,'-dpdf','-r300')
                figure
                opt_p.flag_labels = true;
                niak_visu_part(part(order),opt_p);
                namefig = strcat(path_res_run,'clusters.pdf');
                print(namefig,'-dpdf','-r300')
                close all
                
                % Write volumes
                % The average per cluster
                avg_clust_raw = zeros(max(part),size(data,2));
                for cc = 1:max(part)
                    avg_clust_raw(cc,:) = mean(raw_data(part==cc,:),1);
                end
                vol_avg_raw = niak_tseries2vol(avg_clust_raw,mask);
                hdr.file_name = [path_res_run 'mean_clusters.nii.gz'];
                niak_write_vol(hdr,vol_avg_raw);
                
                % The std per cluster
                avg_clust_raw = zeros(max(part),size(data,2));
                for cc = 1:max(part)
                    avg_clust_raw(cc,:) = std(raw_data(part==cc,:),1);
                end
                vol_avg_raw = niak_tseries2vol(avg_clust_raw,mask);
                hdr.file_name = [path_res_run 'std_clusters.nii.gz'];
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
                hdr.file_name = [path_res_run 'mean_clusters_demeaned.nii.gz'];
                niak_write_vol(hdr,vol_avg);
                
                % Mean and std grand average
                hdr.file_name = [path_res_run 'grand_mean_clusters.nii.gz'];
                niak_write_vol(hdr,mean(stack,4));
                hdr.file_name = [path_res_run 'grand_std_clusters.nii.gz'];
                niak_write_vol(hdr,std(stack,0,4));
            end
        end
        
        
        %% GLM analysis
        
        % Build loads
        for cc = 1:max(part)
            avg_clust(cc,:) = mean(data(part==cc,:),1);
            weights(:,cc) = corr(data',avg_clust(cc,:)');
        end
        
        save([path_res_run 'weights.mat'],'weights');
        
        opt.labels_y = name_clus;
        opt.labels_x = sub_id;
        path = [path_res_run 'weights.csv'];
        opt.precision = 3;
        niak_write_csv(path,weights,opt);
        
        if fig_weights ==1
            % Visualize weights
            figure
            opt_vr.limits = fig_limits;
            niak_visu_matrix(weights(order,:),opt_vr)
            namefig = strcat(path_res_run,'weights.pdf');
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
            covar = tab(:,num_var(n_var));
            mask_covar = ~isnan(covar);
            model_covar.x = [ones(sum(mask_covar),1) niak_normalize_tseries([covar(mask_covar)],'mean')];
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
                        plot(mask+1+0.1*randn(size(mask)),covar(:,n_subtype),'.','markersize',20)
                        hold on
                        boxplot(covar(:,n_subtype),mask);
                        bh = boxplot(covar(:,n_subtype),mask);
                        set(bh(:,1),'linewidth',0.5);
                        set(bh(:,2),'linewidth',0.5);
                        namefig = strcat(path_res_run,'plot_net_',num2str(num_net(n_net)), '_var_', num2str(num_var(n_var)), '_subtype_', num2str(n_subtype), '.pdf');
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
                        namefig = strcat(path_res_run,'plot_net_',num2str(num_net(n_net)), '_var_', num2str(num_var(n_var)), '_subtype_', num2str(n_subtype), '.pdf');
                        print(namefig,'-dpdf','-r300')
                        close all
                    end
                end
            end
        end
    end
end

% Stats
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

% Stats
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



