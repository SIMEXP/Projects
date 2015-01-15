clear

%% Load data
path_data = '/home/pbellec/database/phenoclust/scale_12_2015_01_14/';
[hdr,vol] = niak_read_vol([path_data 'netstack_net10.nii.gz']);
[hdr,mask] = niak_read_vol([path_data 'mask_gm.nii.gz']);
tseries = niak_vol2tseries(vol,mask);

%% Run a normalization by regressing out the average stability map
model_ga.y = tseries';
model_ga.x = [mean(tseries,1)'];
model_ga.c = [1];
opt_ga.flag_residuals = true;
opt_ga.test = 'ttest';
res_ga = niak_glm(model_ga,opt_ga);
tseries_ga = res_ga.e';

%% Run a cluster analysis on the demeaned maps
R = corr(tseries_ga');
hier = niak_hierarchical_clustering(R);
order = niak_hier2order(hier);
part = niak_threshold_hierarchy(hier,struct('thresh',7));

%% Visualize the matrices
figure
opt_vr.limits = [-0.3 0.3];
niak_visu_matrix(R(order,order),opt_vr);
figure
opt_p.flag_labels = true;
niak_visu_part(part(order),opt_p);

%% Visualize the cluster means
opt_vp.vol_limits = [0 1];
for cc = 1:max(part)
    figure
    niak_montage(mean(vol(:,:,:,part==cc),4),opt_vp);
end

%% Visualize the cluster means, after demeaning
opt_vp.vol_limits = [-0.2 0.2];
opt_vp.type_color = 'hot_cold';
vol_ga = niak_tseries2vol(tseries_ga,mask);
for cc = 1:max(part)
    figure
    niak_montage(mean(vol_ga(:,:,:,part==cc),4),opt_vp);
end

%% Build loads
avg_clust = zeros(max(part),size(tseries_ga,2));
for cc = 1:max(part)
    avg_clust(cc,:) = mean(tseries_ga(part==cc,:),1);
end
model_load.x = [mean(tseries,1)' avg_clust'];
model_load.y = tseries';
model_load.c = zeros(max(part),1);
opt_load.flag_beta = true;
res_load = niak_glm(model_load,opt_load);
weights = res_load.beta';

%% Load phenotypic variables
tab = niak_read_csv_cell([path_data 'pheno_unique.csv']);
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

%% GLM analysis for age - METAL
model_age_met.x = [ones(size(weights,1),1) niak_normalize_tseries(age,'mean')];
model_age_met.y = weights;
model_age_met.c = [0 ; 1];
opt_multi.multisite = ind_site;
res_age_met = niak_glm_multisite(model_age_met,opt_multi);

%% GLM analysis for age - site covariates
model_age.x = [model_site.x niak_normalize_tseries(age,'mean')];
model_age.y = weights;
model_age.c = [zeros(size(model_site.x,2),1) ; 1];
opt_glm.test = 'ttest';
opt_glm.flag_beta = true;
res_age = niak_glm(model_age,opt_glm);

%% GLM analysis for age - site covariates - without shitty clusters
model_age.x = [model_site.x(part~=6,:) niak_normalize_tseries(age(part~=6,:),'mean')];
model_age.y = weights(part~=6,:);
model_age.c = [zeros(size(model_site.x,2),1) ; 1];
opt_glm.test = 'ttest';
opt_glm.flag_beta = true;
res_age = niak_glm(model_age,opt_glm);

%% GLM analysis for age - the other way around
model_age.y = age;
model_age.x = [model_site.x weights];
model_age.c = [zeros(size(model_site.x,2),1) ; ones(size(weights,2),1)];
opt_glm.test = 'ftest';
opt_glm.flag_beta = true;
res_age = niak_glm(model_age,opt_glm);

%% Diagnosis - METAL
diagnosis = cell2mat(cellfun (@str2num, tab(2:end,4),"UniformOutput", false));
for num_site = 1:max(ind_site)
     fprintf('site %s nb controls %i nb patients %i\n',list_site{num_site},sum(diagnosis(ind_site==num_site)==1),sum(diagnosis(ind_site==num_site)==2))
end
model_diagnosis_met.x = [ones(size(weights,1),1) niak_normalize_tseries(diagnosis,'mean')];
model_diagnosis_met.y = weights;
model_diagnosis_met.c = [0 ; 1];
opt_multi.multisite = ind_site;
res_diagnosis_met = niak_glm_multisite(model_diagnosis_met,opt_multi);

%% GLM analysis for diagnosis - site covariates
model_diagnosis.x = [model_site.x niak_normalize_tseries(diagnosis,'mean')];
model_diagnosis.y = weights;
model_diagnosis.c = [zeros(size(model_site.x,2),1) ; 1];
opt_glm.test = 'ttest';
res_diagnosis = niak_glm(model_diagnosis,opt_glm);

%% GLM analysis for diagnosis - the other way around
model_diagnosis.y = [niak_normalize_tseries(diagnosis,'mean')];
model_diagnosis.x = [model_site.x weights];
model_diagnosis.c = [zeros(size(model_site.x,2),1) ; ones(size(model_diagnosis.x,2)-size(model_site.x,2),1) ];
opt_glm.test = 'ftest';
opt_glm.flag_beta = true;
res_diagnosis = niak_glm(model_diagnosis,opt_glm);

%% GLM analysis for diagnosis - the other way around without shitty clusters
model_diagnosis.y = [niak_normalize_tseries(diagnosis(part~=6),'mean')];
model_diagnosis.x = [model_site.x(part~=6,:) weights(part~=6,:)];
model_diagnosis.c = [zeros(size(model_site.x,2),1) ; ones(size(model_diagnosis.x,2)-size(model_site.x,2),1) ];
opt_glm.test = 'ftest';
opt_glm.flag_beta = true;
res_diagnosis = niak_glm(model_diagnosis,opt_glm);
