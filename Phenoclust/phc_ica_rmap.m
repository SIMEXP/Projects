clear

%% Load data
path_rmap = '/home/pbellec/database/phenoclust/rmap_scale_12/';
path_stab = '/home/pbellec/database/phenoclust/scale_12/';
[hdr,rmap] = niak_read_vol([path_rmap 'netstack_net10.nii.gz']);
[hdr,stab] = niak_read_vol([path_stab 'netstack_net10.nii.gz']);
[hdr,mask] = niak_read_vol([path_rmap 'mask_gm.nii.gz']);
trmap = niak_vol2tseries(rmap,mask);
tstab = niak_vol2tseries(stab,mask);

%% Cluster subjects
Rrmap = niak_build_correlation(trmap');
Rstab = niak_build_correlation(tstab');
hier = niak_hierarchical_clustering (Rrmap);
order = niak_hier2order (hier);
figure
niak_visu_matrix(abs(Rrmap(order,order)))
figure
niak_visu_matrix(abs(Rstab(order,order)))
part = niak_threshold_hierarchy(hier,struct('thresh',30));
figure
opt_p.flag_labels = true;
niak_visu_part(part(order),opt_p)
opt_v.type_color = 'jet';
opt_v.vol_limits = [0 1];
niak_montage (abs(mean(vol(:,:,:,part==26),4)),opt_v)
niak_montage (abs(mean(stab(:,:,:,part==26),4)),opt_v)
%% Run an ica
opt_i.type_nb_comp = 0;
opt_i.param_nb_comp = 30;
res_ica = niak_sica(tseries,opt_i);
save([path_data 'res_ica_net10.mat','res_ica']);
vol_ica = niak_tseries2vol(res_ica.composantes',mask);
weights = res_ica.poids;

%% Load phenotypic variables
tab = niak_read_csv_cell([path_data 'pheno_unique.csv']);
[list_site,tmp,ind_site] = unique(tab(2:end,2));
age = cell2mat(cellfun (@str2num, tab(2:end,6),"UniformOutput", false));

%% GLM analysis
model_age.x = [ones(size(weights,1),1) niak_normalize_tseries(age,'mean')];
model_age.y = weights;
model_age.c = [0 ; 1];
opt_glm.test = 'ttest';
res_age = niak_glm(model_age,opt_glm);

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

%% Diagnosis
diagnosis = cell2mat(cellfun (@str2num, tab(2:end,4),"UniformOutput", false));
model_diagnosis.x = [ones(size(weights,1),1) niak_normalize_tseries(diagnosis,'mean')];
model_diagnosis.y = weights;
model_diagnosis.c = [0 ; 1];
opt_glm.test = 'ttest';
res_diagnosis = niak_glm(model_diagnosis,opt_glm);

