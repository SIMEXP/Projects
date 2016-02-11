function sub = adsf_build_subtypes(data,mask,nb_subtype)
% DATA (nb of subjects x nb of vertices) cortical thickness (or other) measures
% MASK (1 x nb of vertices) a binary vector defining a subset of vertices
% NB_SUBTYPE (integer) the number of subtypes

% reorganize and normalize data
nb_subject = size(data,1);
nb_vertices = size(data,2);
mask = mask == 1; % Just work on first cluster
m_data = mean(data(:,mask),2);
s_data = std(data(:,mask),[],2);
data = (data - repmat(m_data,[1 nb_vertices]))./repmat(s_data,[1 nb_vertices]); % Correct whole brain maps to zero mean and unit variance within the mask

% Perfom a cluster analysis to identify subgroups
% Inter  subject correlation
sub.R = niak_build_correlation(data(:,mask)'); % Compute inter-subject correlation matrix restricted to the mask
% hierarchical clustering
sub.hier = niak_hierarchical_clustering(sub.R);
% build an ordering on the subjects based on the hierarchy
sub.order = niak_hier2order(sub.hier);
% Build subgroups by thresholding the hierarchy
sub.part = niak_threshold_hierarchy(sub.hier,struct('thresh',nb_subtype));

%% Compute subtypes and associated weights
sub.mean = mean(data,1);
sub.map = zeros(nb_subtype,nb_vertices);
sub.map_d = zeros(nb_subtype,nb_vertices);
sub.weights = zeros(nb_subject,nb_subtype);
for ss = 1:nb_subtype
    sub.map(ss,:) = mean(data(sub.part==ss,:),1);
    sub.map_d(ss,:) = sub.map(ss,:) - sub.mean;
    sub.weights(:,ss) = corr(sub.map_d(ss,mask)',(data(:,mask)'-repmat(sub.mean(mask)',[1 nb_subject])));
end