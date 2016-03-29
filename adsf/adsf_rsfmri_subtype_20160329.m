%%%%%%%%%%%%%%%%%%%%%%

%% script for building resting-state network subtypes
%% prevent-ad dataset, data release 2.0

%%%%%%%%%%%%%%%%%%%%%%

clear

path_data = '/Users/AngelaTam/Desktop/adsf/scores/rmap_stack_20160121_nii/';  % grab the stack maps first
path_mask = '/Users/AngelaTam/Desktop/adsf/scores/mask.nii.gz'; % mask covering grey matter only
path_results = '/Users/AngelaTam/Desktop/adsf/adsf_rsfmri_subtypes_20160323/';

% set subtyping variables
nb_net = 7; % number of networks to subtype
num_net = [1 2 3 4 5 6 7]; % numbers of the networks
name_net = {'cer','lim','mot','vis','dmn','cen','san'}; % name of networks
nb_subt = 3; % number of subtypes (subject clusters)
name_clus = {'subt1','subt2','subt3'};
num_select = 19; % = fsfmri_qc = 1 for all subjects
num_sample = 19;
num_sex = 1;
num_age = 2;
num_fd = 18;

col = [0 0 0; 0 0 0; 0 0 0];

model = '/Users/AngelaTam/Desktop/adsf/model/preventad_model_vol_bl_dr2_20160316_qc.csv'; % model containing variables of interest and no interest 
[tab,list_sub,ly] = niak_read_csv(model);


%% Clustering

% struct_test = zeros(length(num_var),nb_subt,length(num_net));
% pce = struct_test;
% test_fdr_single = struct_test;


for n_net = 1:length(num_net)
    
    % Create ouptut directories
    path_res_net = [path_results 'net_' num2str(num_net(n_net)) '/'];
    psom_mkdir(path_res_net)
    
    % Load and extract betas from select data (intercept only)
    file_stack = [path_data,'stack_net_' num2str(num_net(n_net)) '.nii.gz'];
    [hdr,stack] = niak_read_vol(file_stack);
    [hdr,mask] = niak_read_vol(path_mask);
    raw_data = niak_vol2tseries(stack,mask);
    
end
    
%     sss = 0;
%     for ss = 1:length(sub_id)
%         if raw_tab(ss,num_select) == 1
%             sss=sss+1;
%             conf_tab(sss,:) = raw_tab(ss,:);
%             conf_data(sss,:) = raw_data(sss,:);
%         end
%     end
%     
%     conf_x = [ones(size(conf_data,1),1) conf_tab(:,num_sex) conf_tab(:,num_age) conf_tab(:,num_fd)];
%     conf_y = conf_data;
%     conf_betas = (conf_x'*conf_x)\conf_x'*conf_y;
    
%     % Get subtypes on select data (= sample data here)
%     sss = 0;
%     for ss = 1:length(sub_id)
%         if raw_tab(ss,num_select) == 1
%             sss=sss+1;
%             subt_tab(sss,:) = raw_tab(ss,:);
%             subt_data(sss,:) = raw_data(sss,:);
%         end
%     end
%     subt_x = [ones(size(subt_data,1),1) subt_tab(:,num_sex) subt_tab(:,num_age) subt_tab(:,num_fd)];
%     subt_y = subt_data;
%     subt_betas = (subt_x'*subt_x)\subt_x'*subt_y;
%     subt_data = subt_y-subt_x*subt_betas;


%% regress out confounding variables (age, fd, gender)

model.x = [ones(length(list_sub),1) tab(:,1) tab(:,2) tab(:,18)];
mask_nnan = ~max(isnan(model.x),[],2);
model.x = model.x(mask_nnan,:); 
data = raw_data(mask_nnan,:,:);  % putting a mask to get rid of NaNs over the newly created variable raw_data
tab = tab(mask_nnan,:); % mask to get rid of NaNs within tab
list_sub = list_sub(mask_nnan);

for nn = 1:size(data,3)
    model.y = data(:,:,nn);
    model.c = [1 0 0 0];
    opt_glm.test = 'ttest';
    opt_glm.flag_residuals = true;
    glm = niak_glm(model,opt_glm);
    data(:,:,nn) = glm.e;
end
    

%% subtyping the residual glm (left after regressing confounds)
file_sub = [path_results 'rsfmri_subtypes_20160323_TEST.mat'];

for nn = 1:nb_net
    sub(nn) = niak_build_subtypes(data,nb_subt);
end
save(file_sub,'sub')


%% Write volumes

for n_net = 1:length(num_net)
        % The average per cluster
        avg_clust_subt = zeros(max(part),size(data,2));
        for cc = 1:max(sub.part)
            avg_clust_subt(cc,:) = mean(data(sub.part==cc,:),1);
        end
        vol_avg_subt = niak_tseries2vol(avg_clust_subt,mask);
        hdr.file_name = [path_res_net 'mean_clusters.nii.gz'];
        niak_write_vol(hdr,vol_avg_subt);
        
        % The std per subtype
        avg_clust_subt = zeros(max(part),size(data,2));
        for cc = 1:max(part)
            avg_clust_subt(cc,:) = std(subt_data(part==cc,:),1);
        end
        vol_avg_subt = niak_tseries2vol(avg_clust_subt,mask);
        hdr.file_name = [path_res_net 'std_clusters.nii.gz'];
        niak_write_vol(hdr,vol_avg_subt);
        
        % The demeaned/z-ified per subtype
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
        
        % demeaned subtype
        vol_demean = niak_tseries2vol(
        
        % Mean and std grand average
        hdr.file_name = [path_res_net 'grand_mean_clusters.nii.gz'];
        niak_write_vol(hdr,mean(stack,4));
        hdr.file_name = [path_res_net 'grand_std_clusters.nii.gz'];
        niak_write_vol(hdr,std(stack,0,4));
end

%%
% %% glm to test for associations between subtypes and variables of interest 
% 
% % generate the models, do the GLMs, and save them
% 
% file_res = [path_out 'adsf_glm_cog_20160316.mat'];
% list_contrast = {'im_mem','vis','lan','att','del_mem'};
% list_covariate = [13 14 15 16 17];
% glm = struct();
% model = struct();
% for nn = 1:nb_net
%     for cc = 1:length(list_contrast)
%         contrast = list_contrast{cc};
%         model(nn).(contrast).x = [ones(size(sub(nn).weights,1),1) tab(:,1) tab(:,2) tab(:,18) tab(:,list_covariate(cc))];
%         mask_nan = max(isnan(model(nn).(contrast).x),[],2);
%         model(nn).(contrast).x = model(nn).(contrast).x(~mask_nan,:);
%         model(nn).(contrast).x(:,2:end) = niak_normalize_tseries(model(nn).(contrast).x(:,2:end));
%         model(nn).(contrast).y = niak_normalize_tseries(sub(nn).weights(~mask_nan,:));
%         model(nn).(contrast).c = [0 0 0 0 1]; % structure containing contrast vectors (1 for variable of interest, 0 for covariates of no interest)
%         opt_glm.test = 'ttest';
%         glm(nn).(contrast) = niak_glm(model(nn).(contrast),opt_glm);
%     end
% end
% save(file_res,'model','glm')
% 
% %% Check p-values
% nn = 10;
% for cc = 1:length(list_contrast)
%     contrast = list_contrast{cc}
%     glm(nn).(contrast).pce
% end
% 
% 
% %% visualization
% 
% for nn = 1:nb_net
%     for gg = 1:nb_subt
%         for cc = 1:length(list_contrast)
%             contrast = list_contrast{cc};
%             figure 
%             plot(model(nn).(contrast).x(:,5),model(nn).(contrast).y(:,gg),'o','markersize',7,'markeredgecolor', (col(3,:)), 'markerfacecolor', (col(3,:)+[2 2 2])/3,'linewidth', 0.3);
%             hold on
%             beta = niak_lse(model(nn).(contrast).y(:,gg),[ones(size(model(nn).(contrast).y(:,gg))) model(nn).(contrast).x(:,5)]);
%             plot(model(nn).(contrast).x(:,5),[ones(size(model(nn).(contrast).y(:,gg))) model(nn).(contrast).x(:,5)]*beta,'linewidth',0.3,'color', (col(3,:)));
%             namefig = [path_out 'net' num2str(nn) '_subt' num2str(gg) '_' contrast '.pdf'];
%             print(namefig,'-dpdf','-r300')
%             close all
%         end
%     end
% end