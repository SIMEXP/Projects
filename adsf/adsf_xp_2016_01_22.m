clear

path_data = '/home/pbellec/Desktop/';
file_data = [path_data 'adsf_model_preventad_baseline_dr2_20160121.csv'];
[tab,lx,ly] = niak_read_csv(file_data);

% Extract model
model = tab(:,1:22);
labels_model = ly(1:22);

% Extract volume measures
vol = tab(:,23:end);
labels_vol = ly(23:end);
vol(:,2:end) = vol(:,2:end) .* repmat(vol(:,1),[1 size(vol,2)-1]);

% Run a measure-level clustering
nb_vol = 5;
mask = max(isnan(vol),[],2);
vol = vol(~mask,:);
vol = niak_normalize_tseries(vol);
R = niak_build_correlation(vol);
hier = niak_hierarchical_clustering(R);
order = niak_hier2order(hier);
figure
niak_visu_matrix(R(order,order));
labels_vol(order)
part_vol = niak_threshold_hierarchy(hier,struct('thresh',nb_vol));
figure
niak_visu_part(part_vol(order));
mean_vol = zeros(size(vol,1),nb_vol);
for vv = 1:nb_vol
    fprintf('Cluster %i\n',vv)
    labels_vol(part_vol==vv)
    mean_vol(:,vv) = mean(vol(:,part_vol==vv),2);
end

%% Run subtype analysis
nb_subtype = 5;
R_subtype = niak_build_correlation(vol');
hier_subtype = niak_hierarchical_clustering(R_subtype);
order_subtype = niak_hier2order(hier_subtype);
figure
niak_visu_matrix(R_subtype(order_subtype,order_subtype));
part_subtype = niak_threshold_hierarchy(hier_subtype,struct('thresh',nb_subtype));
figure
niak_visu_part(part_subtype(order_subtype))

% Compute the subtypes
subtype = zeros(nb_subtype,size(vol,2));
for ss = 1:nb_subtype
    subtype(ss,:) = mean(vol(part_subtype==ss,:),1);
end

plot(subtype(1,order)');

% Compute the subtype weights
%weights = zeros(length(mask),nb_subtype);
weights = repmat(NaN,[size(vol,1),nb_subtype]);
for ss = 1:nb_subtype
    %weights(~mask,ss) = corr(vol',subtype(ss,:)');
    weights(:,ss) = corr(vol',subtype(ss,:)');
end
plot(weights (order_subtype ,1))