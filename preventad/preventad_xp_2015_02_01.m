clear

path_data = '/home/pbellec/database/preventad/scores_po/';
path_run1 = [path_data 'scores_s12_run1/'];
path_run2 = [path_data 'scores_s12_run2/'];

%list_cov = [5 10 11 14];
list_cov = [5 9 11 14];
%list_cov = 5;

%list_net = [3 4 6 7 8 10 11];
%list_net = [3 6 7 10 11];
list_net = [3 4 6 7 8 10];
labels_net = { 'limb' , 'lang' , 'pcc' , 'mot' , 'mpfc' , 'att' };

%list_net = 7;
nb_clust = 5;
pce1 = zeros(length(list_cov),nb_clust,length(list_net));
pce2 = zeros(length(list_cov),nb_clust,length(list_net));

for ind_net = 1:length(list_net)
    num_net = list_net(ind_net);
    path_res = [path_data 'cluster_' num2str(num_net) 'R_diff' filesep];

    %% Load data
    file_stack1 = [path_run1,'netstack/stability_maps_netstack_net',num2str(num_net),'_scale_12.nii.gz'];
    [hdr,stab1] = niak_read_vol(file_stack1);
    
    file_stack2 = [path_run2,'netstack/stability_maps_netstack_net',num2str(num_net),'_scale_12.nii.gz'];
    [hdr,stab2] = niak_read_vol(file_stack2);
    stab = (stab1+stab2)/2;
    [hdr,mask] = niak_read_vol([path_run2,'mask.nii.gz']);
    tseries1 = niak_vol2tseries(stab1,mask);
    tseries2 = niak_vol2tseries(stab2,mask);

    %% correct for the mean
    gd_mean1 = mean(tseries1);
    tseries_ga1 = tseries1 - repmat(gd_mean1,[size(tseries1,1),1]);
    tseries_ga2 = tseries2 - repmat(gd_mean1,[size(tseries1,1),1]);
    
    %% Run a cluster analysis on the demeaned maps
    R = corr(tseries_ga1');
    hier = niak_hierarchical_clustering(R);
    part = niak_threshold_hierarchy(hier,struct('thresh',nb_clust));
    order = niak_part2order (part,R);

    %% Build loads
    avg_clust = zeros(max(part),size(tseries_ga1,2));
    weights = zeros(size(tseries_ga1,1),max(part));
    for cc = 1:max(part)
        avg_clust1(cc,:) = mean(tseries_ga1(part==cc,:),1);
        weights1(:,cc) = corr(tseries_ga1',avg_clust1(cc,:)');
        weights2(:,cc) = corr(tseries_ga2',avg_clust1(cc,:)');
    end
    
    %% Reproc of stab maps
    for ss = 1:size(tseries1,1)
        repro_stab(ss,ind_net) = corr(tseries_ga1(ss,:)',tseries_ga2(ss,:)');
    end
    
    %% Reproc of weights
    %tmp = corr([weights1,weights2]);
    for cc = 1:nb_clust
        repro_weights(cc,ind_net) = IPN_icc([weights1(:,cc) weights2(:,cc)],2,'single'); 
    end
    
    %% Load phenotypic variables
    [tab,lx,ly] = niak_read_csv([path_run2 'model_preventad_20150128.csv']);
    load([path_run2 'subjects.mat']);
    list_subject = subjects;
    tab2 = zeros(length(list_subject),size(tab,2));
    for ss = 1:length(list_subject)
        ind_s = find(ismember(lx,list_subject{ss}));
        tab2(ss,:) = tab(ss,:);
    end

    %% GLM analysis 
    for cc = 1:length(list_cov)
        covar = tab2(:,list_cov(cc));
        fd = tab2(:,21);
        age = tab2(:,1);
        sex = tab2(:,2);
        mask_covar = ~isnan(covar)&~isnan(fd);
        %mask_covar = ~isnan(covar)&(tab2(:,2)~=1);
        %model_covar.x = [ones(sum(mask_covar),1) niak_normalize_tseries(covar(mask_covar),'mean').*niak_normalize_tseries(sex(mask_covar),'mean') niak_normalize_tseries([covar(mask_covar) fd(mask_covar) age(mask_covar) sex(mask_covar)],'mean')];
        model_covar.x = [ones(sum(mask_covar),1) niak_normalize_tseries([covar(mask_covar) fd(mask_covar)],'mean')];
        model_covar.y = weights1(mask_covar,:);
        %model_covar.c = [0 ; 0 ; 1; 0 ; 0 ; 0];
        model_covar.c = [0 ; 1 ; 0];
        opt_glm.test = 'ttest';
        opt_glm.flag_beta = true;
        res_covar1 = niak_glm(model_covar,opt_glm);
        model_covar.y = weights2(mask_covar,:);
        res_covar2 = niak_glm(model_covar,opt_glm);
        fprintf('%s\n',ly{list_cov(cc)});
        %res_covar.beta(model_covar.c>0,:)
        pce1(cc,:,ind_net) = res_covar1.pce;
        pce2(cc,:,ind_net) = res_covar2.pce;
    end
end

[fdr,test1] = niak_fdr(pce1(:),'BH',0.2);
test1 = reshape(test1,size(pce1))

[fdr,test2] = niak_fdr(pce2(:),'BH',0.2);
test2 = reshape(test2,size(pce2))

chi2_trt = -2*(log(pce1)+log(pce2));
pce_comb = 1-chi2cdf(chi2_trt , 4);

[fdr,test_comb] = niak_fdr(pce_comb(:),'BH',0.2);
test_comb = reshape(test_comb,size(pce_comb))

test_loc = zeros(size(pce));
for cc = 1:length(list_cov)
    pce_tmp = squeeze(pce(cc,:,:));
    pce_tmp = pce_tmp(:);
    [hdr,test] = niak_fdr(pce_tmp,'BH',0.1);
    test_loc(cc,:,:) = reshape(test,size(pce,2),size(pce,3));
end

if 0

w_hat = model_covar.x*res_covar.beta;
plot(w_hat(:,1), model_covar.y(:,1),'.')

%% GLM analysis -- full brain
covar = tab2(:,9);
fd = tab2(:,15); 
mask_covar = ~isnan(covar)&(part~=2);
model_covar.x = [ones(sum(mask_covar),1) niak_normalize_tseries([covar(mask_covar) fd(mask_covar)],'mean')];
model_covar.y = tseries_ga(mask_covar,:);
model_covar.c = [0 ; 1 ; 0];
opt_glm.test = 'ttest';
opt_glm.flag_beta = true;
res_covar = niak_glm(model_covar,opt_glm);
res_covar.pce;
res_covar.beta(model_covar.c>0,:);
w_hat = model_covar.x*res_covar.beta;
plot(w_hat(:,2), model_covar.y(:,2),'.')

%% GLM analysis the other way
covar = tab2(:,13);
fd = tab2(:,15); 
mask_covar = ~isnan(covar);
model_covar.y = [niak_normalize_tseries(covar(mask_covar),'mean')];
model_covar.x = [ones(sum(mask_covar),1) niak_normalize_tseries(weights(mask_covar,:),'mean') fd(mask_covar)];
model_covar.c = [0 ; ones(size(weights,2),1) ; 0];
opt_glm.test = 'ftest';
opt_glm.flag_beta = true;
res_covar = niak_glm(model_covar,opt_glm);
res_covar.pce
%res_covar.beta(model_covar.c>0,:)

%% Visualize the cluster means
ind_visu = 1:max(part);
opt_vp.vol_limits = [0 1];
gd_avg = mean(stab,4);
for cc = ind_visu
    figure
    niak_montage(mean(stab(:,:,:,part==cc),4),opt_vp);
    title(sprintf('Average cluster %i',cc))
end
figure
niak_montage(gd_avg,opt_vp);
title('Grand average')

%% Visualize the cluster means, after substraction of the mean
opt_vp.vol_limits = [-0.2 0.2];
opt_vp.type_color = 'hot_cold';
ind_visu = 1:max(part);
gd_avg = mean(stab,4);
for cc = ind_visu
    figure
    niak_montage(mean(stab(:,:,:,part==cc),4)-gd_avg,opt_vp);
    title(sprintf('Average cluster %i',cc))
end

%% Write volumes
% The average per cluster
psom_mkdir(path_res)
avg_clust_raw = zeros(max(part),size(tseries,2));
for cc = 1:max(part)
    avg_clust_raw(cc,:) = mean(tseries(part==cc,:),1);
end
vol_avg_raw = niak_tseries2vol(avg_clust_raw,mask);
hdr.file_name = [path_res 'mean_clusters.nii.gz'];
niak_write_vol(hdr,vol_avg_raw);

% The demeaned, z-ified volumes
avg_clust = zeros(max(part),size(tseries,2));
for cc = 1:max(part)
    avg_clust(cc,:) = mean(tseries_ga(part==cc,:),1);
end
avg_clust = niak_normalize_tseries(avg_clust','median_mad')';
vol_avg = niak_tseries2vol(avg_clust,mask);
hdr.file_name = [path_res 'mean_cluster_demeaned.nii.gz'];
niak_write_vol(hdr,vol_avg);

hdr.file_name = [path_res 'grand_mean_clusters.nii.gz'];
niak_write_vol(hdr,mean(stab,4));

end