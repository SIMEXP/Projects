%%%%%%%%%%%%%%%%%%%%%%

%% script for building resting-state network subtypes
%% prevent-ad dataset, data release 2.0

%%%%%%%%%%%%%%%%%%%%%%

clear

path_data = '/Users/AngelaTam/Desktop/adsf/scores/rmap_stack_20160121_nii/';  % grab the stack maps first
path_mask = '/Users/AngelaTam/Desktop/adsf/scores/mask.nii.gz'; % mask covering grey matter only
path_results = '/Users/AngelaTam/Desktop/adsf/adsf_rsfmri_subtypes_20160329/';

% set subtyping variables
nb_net = 7; % number of networks to subtype
num_net = [1 2 3 4 5 6 7]; % numbers of the networks (from parcellation)
nb_subt = 3; % number of subtypes (subject clusters)

% read model
model = '/Users/AngelaTam/Desktop/adsf/model/preventad_model_vol_bl_dr2_20160316_qc.csv'; % model containing variables of interest and no interest 
[tab,list_sub,ly] = niak_read_csv(model);


%% Load and extract betas from select data (intercept only)

for n_net = 1:length(num_net)
    file_stack = [path_data,'stack_net_' num2str(num_net(n_net)) '.nii.gz'];
    [hdr,stack] = niak_read_vol(file_stack);
    [hdr,mask] = niak_read_vol(path_mask);
    raw_data = niak_vol2tseries(stack,mask);
end

%% regress out confounding variables (age, fd, gender) prior to subtyping

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

file_sub = [path_results 'rsfmri_subtypes_20160329_TEST.mat'];

for nn = 1:nb_net
    sub(nn) = niak_build_subtypes(data,nb_subt);
end
save(file_sub,'sub')


%% Write volumes

for n_net = 1:length(num_net)
    
    % Create ouptut directories for each network
    path_res_net = [path_results 'net_' num2str(num_net(n_net)) '/'];
    psom_mkdir(path_res_net)
    
    % The average per cluster
    avg_clust_subt = zeros(max(sub(n_net).part),size(data,2));
    for cc = 1:max(sub(n_net).part)
        avg_clust_subt(cc,:) = mean(data(sub(n_net).part==cc,:),1);
    end
    vol_avg_subt = niak_tseries2vol(avg_clust_subt,mask);
    hdr.file_name = [path_res_net 'mean_clusters_net' num2str(num_net(n_net)) '.nii.gz'];
    niak_write_vol(hdr,vol_avg_subt);
    
    % The std per subtype
    std_clust_subt = zeros(max(sub(n_net).part),size(data,2));
    for cc = 1:max(sub(n_net).part)
        std_clust_subt(cc,:) = std(data(sub(n_net).part==cc,:),1);
    end
    vol_std_subt = niak_tseries2vol(std_clust_subt,mask);
    hdr.file_name = [path_res_net 'std_clusters_net' num2str(num_net(n_net)) '.nii.gz'];
    niak_write_vol(hdr,vol_std_subt);
    
    % demeaned/z-fied subtype
    vol_demean = niak_tseries2vol(sub(n_net).map,mask);
    hdr.file_name = [path_res_net 'demean_clusters_net' num2str(num_net(n_net)) '.nii.gz'];
    niak_write_vol(hdr,vol_demean);
    
    % t-test between subtype and mean
    vol_ttest = niak_tseries2vol(sub(n_net).ttest,mask);
    hdr.file_name = [path_res_net 'ttest_clusters_net' num2str(num_net(n_net)) '.nii.gz'];
    niak_write_vol(hdr,vol_ttest);
    
    % Mean and std grand average
    hdr.file_name = [path_res_net 'grand_mean_clusters_net' num2str(num_net(n_net)) '.nii.gz'];
    niak_write_vol(hdr,mean(stack,4));
    hdr.file_name = [path_res_net 'grand_std_clusters_net' num2str(num_net(n_net)) '.nii.gz'];
    niak_write_vol(hdr,std(stack,0,4));
end


%% Write csv for weights

name_clus = {'subt1','subt2','subt3'};

for n_net = 1:length(num_net)
    for cc = 1:max(sub(n_net).part)
        avg_clust(cc,:) = mean(data(sub(n_net).part==cc,:),1);
        weights(:,cc) = corr(data',avg_clust(cc,:)');
    end
    
    opt.labels_y = name_clus;
    opt.labels_x = list_sub;
    opt.precision = 3;
    path_res_net = [path_results 'net_' num2str(num_net(n_net)) '/'];
    path = [path_res_net 'net' num2str(num_net(n_net)) '_weights.csv'];
    niak_write_csv(path,weights,opt);
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