function sub = adni_build_subtypes(data,nb_subtype)
% Extract subtypes from functional maps
% Syntax: SUB = ADNI_BUILD_SUBTYPES(DATA,NB_SUBTYPE)
%
% DATA (nb of subjects x nb of voxels) each row is a connectivity map for one subject.
% MASK (1 x nb of vertices) a binary vector defining a subset of vertices.
% NB_SUBTYPE (integer) the number of subtypes.
% SUB (structure) with a bunch of stuff. Fields should be self-explanatory. 
%
% (C) Pierre Bellec 2016

% reorganize and normalize data
nb_subject = size(data,1);
nb_voxels = size(data,2);

% normalize each map to zero mean and unit variance
%data = niak_normalize_tseries(data')'; 
data_d = niak_normalize_tseries(data,struct('type','mean'));

% Perfom a cluster analysis to identify subgroups
% Inter  subject correlation
sub.R = niak_build_correlation(data_d'); % Compute inter-subject correlation matrix restricted to the mask
% hierarchical clustering
sub.hier = niak_hierarchical_clustering(sub.R);
% build an ordering on the subjects based on the hierarchy
sub.order = niak_hier2order(sub.hier);
% Build subgroups by thresholding the hierarchy
sub.part = niak_threshold_hierarchy(sub.hier,struct('thresh',nb_subtype));

%% Compute subtypes and associated weights
sub.mean = mean(data,1);
sub.map = zeros(nb_subtype,nb_voxels);
sub.map_d = zeros(nb_subtype,nb_voxels);
sub.map_ttest = zeros(nb_subtype,nb_voxels);
sub.weights = zeros(nb_subject,nb_subtype);
X = ones([nb_subject 1]);
for ss = 1:nb_subtype
    sub.map(ss,:) = mean(data(sub.part==ss,:),1);
    X(:,2) = sub.part==ss;
    [tmp0,tmp,tmp2,sub.map_ttest(ss,:),sub.map_pce(ss,:),sub.map_eff(ss,:),sub.map_std_eff(ss,:)] = niak_lse(data,X,[0 1]);
    for ssub = 1:nb_subject
        sub.weights(ssub,ss) = corr(sub.map(ss,:)-sub.mean,data(ssub,:)-sub.mean);
    end
end