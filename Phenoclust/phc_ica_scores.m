clear

%% Load data
path_data = '/home/pbellec/database/phenoclust/scale_12_2015_01_14/';
[hdr,vol] = niak_read_vol([path_data 'netstack_net10.nii.gz']);
[hdr,mask] = niak_read_vol([path_data 'mask_gm.nii.gz']);
tseries = niak_vol2tseries(vol,mask);

%% Run an ica
opt_i.type_nb_comp = 0;
opt_i.param_nb_comp = 10;
res_ica = niak_sica(tseries,opt_i);
save([path_data 'res_ica_net10.mat','res_ica']);
vol_ica = niak_tseries2vol(res_ica.composantes',mask);
weights = res_ica.poids;

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
model_diagnosis.c = [zeros(size(model_site.x,2),1) ; ones(size(weights,2),1) ];
opt_glm.test = 'ftest';
res_diagnosis = niak_glm(model_diagnosis,opt_glm);
