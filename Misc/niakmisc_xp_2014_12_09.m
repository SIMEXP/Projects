clear all

%% Parameters
nb_clust = 30; % Number of cluster for spatial shuffling

%% Load data
load('/home/pbellec/database/network_fdr/blind/glm_CBvsSC_conf_sci280_scg308_scf313.mat');
model = model_group;

%% Compute a mean connectome and associated partition 
mean_R = niak_lvec2mat(mean(model.y,1));
hier = niak_hierarchical_clustering(mean_R);
order = niak_hier2order(hier);
niak_visu_matrix(mean_R(order,order));
part = niak_threshold_hierarchy(hier,struct('thresh',nb_cluster));
siz_clust = niak_build_size_roi(part);

%% GLM options
opt_glm.test = 'ttest';
opt_glm.flag_residuals = true;

%% Create an index of all connections in matrix form
mat_ind = niak_lvec2mat(1:size(model.y,2));
vec_ind = 1:size(mat_ind,2);

%% Now resample

for num_samp = 1:nb_samps 
    niak_progress(num_samp,nb_samps)
    model_perm = model;
    for num_subject = 1:size(model.y,1)
        perm_clust = randperm(nb_clust);
        vec_ind_perm = zeros(size(vec_ind));
        curr_pos = 1;
        for num_c = 1:nb_clust
            vec_ind_perm(curr_pos:curr_pos+siz_clust(perm_clust(num_c))-1) = vec_ind(part==perm_clust(num_c));
            curr_pos = curr_pos + siz_clust(perm_clust(num_c));
        end
        mat_ind_perm = mat_ind(vec_ind_perm,vec_ind_perm);
        model_perm.y(num_subject,:) = model_perm.y(num_subject,niak_mat2lvec(mat_ind_perm));
    end
    res_null = niak_glm(model_perm,opt_glm);
end
