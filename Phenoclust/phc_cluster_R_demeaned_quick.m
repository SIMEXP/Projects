clear

%% Load data
%path_data = '/home/pbellec/database/phenoclust/scale_12_2015_01_14/';
path_data = '/data1/abide/Out/Remote/all_worked/out/maps/stability_maps/correlation/scale_12/';
[hdr,vol] = niak_read_vol([path_data 'netstack_net1.nii.gz']);
[hdr,mask] = niak_read_vol([path_data 'mask.nii.gz']);
tseries = niak_vol2tseries(vol,mask);

%% Run a normalization by regressing out the average stability map
model_ga.y = tseries';
model_ga.x = [mean(tseries,1)'];
model_ga.c = [1];
opt_ga.flag_residuals = true;
opt_ga.test = 'ttest';
res_ga = niak_glm(model_ga,opt_ga);
tseries_ga = res_ga.e';

vol_ga = niak_tseries2vol(tseries_ga,mask);

%% Run a cluster analysis on the demeaned maps
R = corr(tseries_ga');
hier = niak_hierarchical_clustering(R);
order = niak_hier2order(hier);
part = niak_threshold_hierarchy(hier,struct('thresh',7));

%% Build loads
avg_clust = zeros(max(part),size(tseries_ga,2));
weights = zeros(size(tseries_ga,1),max(part));
for cc = 1:max(part)
    avg_clust(cc,:) = mean(tseries_ga(part==cc,:),1);
    weights(:,cc) = corr(tseries_ga',avg_clust(cc,:)');
end

%% Load phenotypic variables
tab = niak_read_csv_cell([path_data 'matched_pheno.csv']);
[list_site,tmp,ind_site] = unique(tab(2:end,2));
age = cell2mat(cellfun (@str2num, tab(2:end,6),"UniformOutput", false));

%% Multisite
model_site = struct;
model_site.x = zeros(size(weights,1),length(list_site));
model_site.x(:,1) = 1;
for num_site = 2:length(list_site)
    model_site.x(:,num_site) = ind_site==num_site;
end
model_site.y = weights;
model_site.c = [0 ones(1,length(list_site)-1)];
opt_glm.test = 'ftest';
res_site = niak_glm(model_site,opt_glm);

%% GLM analysis for diagnosis - site covariates
diagnosis = cell2mat(cellfun (@str2num, tab(2:end,4),"UniformOutput", false));
model_diagnosis.x = [model_site.x niak_normalize_tseries(diagnosis,'mean')];
model_diagnosis.y = weights;
model_diagnosis.c = [zeros(size(model_site.x,2),1) ; 1];
opt_glm.test = 'ttest';
res_diagnosis = niak_glm(model_diagnosis,opt_glm);


diag = diagnosis -1;
rats = [];
rat = sum(diag) / size(diag,1);
for i =  1:7
    rats(i) = (sum(diag(part==i)) / sum(part==i)) / rat;
end

[min_v, min_n] = min(rats);
[max_v, max_n] = max(rats);

max_net = mean(vol(:,:,:,part==max_n),4);
min_net = mean(vol(:,:,:,part==min_n),4);

max_net_ga = mean(vol_ga(:,:,:,part==max_n),4);
min_net_ga = mean(vol_ga(:,:,:,part==min_n),4);

opt_vp.vol_limits = [-0.2 0.2];
opt_vp.type_color = 'hot_cold';

%figure;
%niak_montage(max_net,opt_vp);
%figure;
%niak_montage(min_net,opt_vp);
