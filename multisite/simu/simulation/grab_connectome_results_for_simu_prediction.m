%% Graber
addpath(genpath('/usr/local/niak/niak-boss-0.12.13'));

%% to change for each connectome set
%main_path = '/data/cisl/cdansereau/adni2/connectomes_multisite/';
%main_path = '/data/cisl/cdansereau/scrubbing/fcon_1000_connectomes/connectomes_multisite/';
main_path = '/data/cisl/cdansereau/multisite/connectomes_multisite_corrseeds/connectomes/';
% get selected connections
%path_selection = '/home/cdansereau/svn/projects/christian/scrubbing/simulation/conn_selection.csv';
%path_selection = '/home/cdansereau/svn/projects/multisite/simulation/conn_selection_corr.csv'
%[tab,selected_labels,labels_y] = niak_read_csv(path_selection);
output_path = '/data/cisl/cdansereau/multisite/simulations_corr/prediction_sim/'
path_covar = '/data/cisl/cdansereau/multisite/demographic_1000fcon_consolidated.csv'
[tab_covar,labels_x_covar,labels_y_covar] = niak_read_csv(path_covar);

% Get all connections
%path_ref = [main_path 'summary_graph_prop_basc.csv'];
%[tab,labels_x,labels_y] = niak_read_csv(path_ref);

%idx_conn = find(ismember(labels_y,selected_labels));
%idx_subj_sel = find(ismember(labels_x,labels_x_covar));
%idx_covar_sel = find(ismember(labels_x_covar,labels_x));
Y=[]
valid_idx=[]
for i = 1:size(labels_x_covar)
    try
        tmp_data = load([main_path,'connectome_basc_',labels_x_covar{i},'.mat']);
        Y = [Y,tmp_data.conn];
	valid_idx = [valid_idx,i];
    catch e
        printf(['no data for ',labels_x_covar{i},'\n'])
    end
end
Y=Y';

label_subject = labels_x_covar(valid_idx);
label_seed = [1:100];
%Y = tab(idx_subj_sel,idx_conn);
label_covar = labels_y_covar;
X = tab_covar(valid_idx,:);

save([output_path 'n_subject_estimation_bis_prediction.mat'],'label_subject','label_seed','label_covar','X','Y');
