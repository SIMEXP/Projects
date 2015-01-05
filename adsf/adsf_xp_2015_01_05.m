clear

%% Import data
[tab,lx,ly] = niak_read_csv('Volumetry_prevendAD_new_method_BL_only.csv');
list_subject = tab(:,1); % extract subject IDs
tab = tab(:,2:end);
ly = ly(2:end);

%% Run the clustering
R = corr(tab); % Similarity (correlation) matrix between measures
hier = niak_hierarchical_clustering(R); % hierarchical clustering, Ward's criterion
order = niak_hier2order(hier); % Get the order of measures based on the clustering
opt_p.thresh = 20; % Number of clusters
part = niak_threshold_hierarchy(hier,opt_p); % Generate the partition

%% visualize the results
figure
niak_visu_matrix(abs(R(order,order))); % The correlation matrix, re-ordered
figure
niak_visu_part(part(order)); % The partition, re-ordered
ly{part==20} % Measures in the 20-th cluster

