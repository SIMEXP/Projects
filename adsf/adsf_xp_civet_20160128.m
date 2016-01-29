%% clustering based on civet outputs

clear all

path_data = '/Users/AngelaTam/Desktop/adsf/';
file_data = [path_data 'adsf_model_preventad_bl_dr2_civet_raw_20160128.csv'];
[tab,lx,ly] = niak_read_csv(file_data);

% Extract model
model = tab(:,1:21);
labels_model = ly(1:21);

% Extract civet measures
ct = tab(:,22:end);
labels_ct = ly(22:end);

%% Run a measure-level clustering
nb_ct = 5;
mask = max(isnan(ct),[],2);
ct = ct(~mask,:);
ct = niak_normalize_tseries(ct);
R = niak_build_correlation(ct);
hier = niak_hierarchical_clustering(R);
order = niak_hier2order(hier);
figure
niak_visu_matrix(R(order,order));
labels_ct(order)
part_ct = niak_threshold_hierarchy(hier,struct('thresh',nb_ct));
figure
niak_visu_part(part_ct(order));
mean_ct = zeros(size(ct,1),nb_ct);
for vv = 1:nb_ct
    fprintf('Cluster %i\n',vv)
    labels_ct(part_ct==vv)
    mean_ct(:,vv) = mean(ct(:,part_ct==vv),2);
end

%% Run subtype analysis
nb_subtype = 5;
R_subtype = niak_build_correlation(ct');
hier_subtype = niak_hierarchical_clustering(R_subtype);
order_subtype = niak_hier2order(hier_subtype);
figure
niak_visu_matrix(R_subtype(order_subtype,order_subtype));
part_subtype = niak_threshold_hierarchy(hier_subtype,struct('thresh',nb_subtype));
figure
niak_visu_part(part_subtype(order_subtype))

% Compute the subtypes
subtype = zeros(nb_subtype,size(ct,2));
for ss = 1:nb_subtype
    subtype(ss,:) = mean(ct(part_subtype==ss,:),1);
end

plot(subtype(1,order)');

% Compute the subtype weights
%weights = zeros(length(mask),nb_subtype);
weights = repmat(NaN,[size(ct,1),nb_subtype]);
for ss = 1:nb_subtype
    %weights(~mask,ss) = corr(ct',subtype(ss,:)');
    weights(:,ss) = corr(ct',subtype(ss,:)');
end
plot(weights (order_subtype ,1))