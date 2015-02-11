%% Example of "states" clustering, weight generation and statistical testing
clear

%% Simulation parameters

% The number of regions
N = 30; 
% The number of clusters
nb_clust = 3;
size_clust = N/nb_clust;
% The number of time points 
T = 200;
% The brain states
states1 = [ false(15,1) ; true(35,1) ; false(15,1) ; true(35,1) ; false(15,1) ; true(35,1) ; false(15,1) ; true(35,1) ]; % The first  group has more of state 1
states2 = [ false(35,1) ; true(15,1) ; false(35,1) ; true(15,1) ; false(35,1) ; true(15,1) ; false(35,1) ; true(15,1) ]; % The second group has more of state 0
% State parameters
sigma_inter = [0 1]; % First number drives the connectivity between clusters 1 and 2 at state 0, and the second number for state 1.
sigma_intra = 1;     % strength of within-cluster connectivity
% Number of subjects per group
S = 10;
% Window length
length_w = 15;
% The number of tested states
nb_clust_states = 3;

%% Now simulate data
y = cell(2*S,1);
for ss = 1:2*S
     y{ss} = randn(T,N); % Gaussian noise
     % Add a within-cluster structure
     for cc = 1:nb_clust
         y{ss}(:,1+((cc-1)*size_clust):cc*size_clust) = y{ss}(:,1+((cc-1)*size_clust):cc*size_clust) + sigma_intra*repmat(randn(T,1),[1 size_clust]);
     end
     % Now add a state-dependent between-cluster structure
     if ss<=S % Group 1
        y{ss}(~states1,1:2*size_clust) = y{ss}(~states1,1:2*size_clust) + sigma_inter(1)*repmat(randn(sum(~states1),1),[1 2*size_clust]);
        y{ss}( states1,1:2*size_clust) = y{ss}( states1,1:2*size_clust) + sigma_inter(2)*repmat(randn(sum(states1),1),[1 2*size_clust]);
     else
        y{ss}(~states2,1:2*size_clust) = y{ss}(~states2,1:2*size_clust) + sigma_inter(1)*repmat(randn(sum(~states2),1),[1 2*size_clust]);
        y{ss}( states2,1:2*size_clust) = y{ss}( states2,1:2*size_clust) + sigma_inter(2)*repmat(randn(sum(states2),1),[1 2*size_clust]);
     end
end

%% Build dynamic connectomes, and cluster them

% The dynamic connectomes
conn = states_dyn_conn(y,length_w);
% For (interesting) fun: visualize the dynamics of connectivity (press p to play)
% The random variation in structure actually appear as non-random in connectome space
% niak_visu_motion(conn{1}) % Subject in group 1
% niak_visu_motion(conn{21}) % Subject in group 2

% vectorize connectomes, as well as associated subject and state information
all_conn = [];
ind_subj = [];
ind_states = [];
for ss = 1:2*S
    all_conn = [ all_conn conn{ss}];
    ind_subj = [ ind_subj ; ss*ones(size(conn{ss},2),1)];
    perc_states = zeros(size(conn{ss},2),1);
    for ww = 1:size(conn{ss},2)
        if ss<=S
            perc_states(ww) = mean(states1(ww:(ww+length_w-1)));
        else
            perc_states(ww) = mean(states2(ww:(ww+length_w-1)));
        end
    end
    ind_states = [ind_states ; perc_states];
end
% At this stage we end up with a 4005 (connections in the connectome) x 7640 (number of time windows x number of subjects) array
% Let's build a (correlation-based) distance matrix between dynamic connectomes
R = corr(all_conn);

% Run a hierarchical clustering on the distance matrix.
% I am avoiding to use niak functions here, but I suspect they are quite faster.
hier = niak_hierarchical_clustering(R);

% Alright, now compute average states (1 per actual brain state, plus one for transitions)
part = niak_threshold_hierarchy(hier,struct('thresh',nb_clust_states));
for cc = 1:nb_clust_states
    avg_states(:,cc) = mean(all_conn(:,part==cc),2);
    demeaned_states(:,cc) = mean(all_conn(:,part==cc),2) - mean(all_conn,2);
end
% For (interesting) fun again, let's visualize the estimated states
% niak_visu_matrix(avg_states(:,1))
% There is clearly one that corresponds to state 1, another to state 0, and one in between, as expected


%% Now, on to the statistics!

% Start building weights
all_demeaned = niak_normalize_tseries(all_conn','mean')';
weights = corr(all_demeaned,demeaned_states);

