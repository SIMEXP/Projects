clear

path_data = '/Users/AngelaTam/Desktop/adsf/';
file_data = [path_data 'adsf_model_preventad_bl_dr2_20160126_nan.csv'];
[tab,lx,ly] = niak_read_csv(file_data);

% Extract model
model = tab(:,1:22);
labels_model = ly(1:22);

% Extract volume measures
vol = tab(:,23:end);
labels_vol = ly(23:end);
labels_vol_sf = ly(24:end);
vol_sf = vol(:,2:end) .* repmat(vol(:,1),[1 size(vol,2)-1]);

% Run a measure-level clustering
nb_vol = 5;
mask = max(isnan(vol_sf),[],2);
vol_sf = vol_sf(~mask,:);
vol_sf = niak_normalize_tseries(vol_sf);
R = niak_build_correlation(vol_sf);
hier = niak_hierarchical_clustering(R);
order = niak_hier2order(hier);
figure
niak_visu_matrix(R(order,order));
labels_vol_sf(order)
part_vol = niak_threshold_hierarchy(hier,struct('thresh',nb_vol));
figure
niak_visu_part(part_vol(order));
mean_vol = zeros(size(vol_sf,1),nb_vol);
for vv = 1:nb_vol
    fprintf('Cluster %i\n',vv)
    labels_vol_sf(part_vol==vv)
    mean_vol(:,vv) = mean(vol_sf(:,part_vol==vv),2);
end

%% Run subtype analysis
nb_subtype = 5;
R_subtype = niak_build_correlation(vol_sf');
hier_subtype = niak_hierarchical_clustering(R_subtype);
order_subtype = niak_hier2order(hier_subtype);
figure
niak_visu_matrix(R_subtype(order_subtype,order_subtype));
part_subtype = niak_threshold_hierarchy(hier_subtype,struct('thresh',nb_subtype));
figure
niak_visu_part(part_subtype(order_subtype))

% Compute the subtypes
subtype = zeros(nb_subtype,size(vol_sf,2));
for ss = 1:nb_subtype
    subtype(ss,:) = mean(vol_sf(part_subtype==ss,:),1);
end

plot(subtype(1,order)');

% Compute the subtype weights
%weights = zeros(length(mask),nb_subtype);
weights = repmat(NaN,[size(vol_sf,1),nb_subtype]);
for ss = 1:nb_subtype
    %weights(~mask,ss) = corr(vol',subtype(ss,:)');
    weights(:,ss) = corr(vol_sf',subtype(ss,:)');
end
plot(weights (order_subtype ,1))