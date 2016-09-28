%% Regress confounds for cortical thickness networks

clear all

%% inputs
path_csv = '/Users/AngelaTam/Desktop/adsf/model/preventad_model_20160408.csv';
path_data = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160808/raw_ct_net_20160808.mat';
path_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160808/regressed_ct_net_20160808.mat';
confs = {'age','gender'}; % names of variables to be regressed out in model csv

%% script starts here

load(path_data)
raw_stack = ct_net;
ct_sub = provenance.list_subject;
% Get dimensions of the data
n_sub = size(ct_net,1); % n subjects
n_vox = size(ct_net,2); % n voxels
n_net = size(ct_net,3); % n networks

% Read the csv
[tab,sid,ly,~] = niak_read_csv(path_csv);

n_conf = length(confs);
conf_ids = zeros(n_conf, 1);
for cid = 1:n_conf
    conf_name = confs{cid};
    cidx = find(strcmp(ly, conf_name));
    % Make sure we found the covariate
    if ~isempty(cidx)
        conf_ids(cid) = cidx;
    else
        error('Could not find column for %s in model file');
    end
    % Make sure there are no NaNs in the model
    if any(isnan(tab(:, cidx)))
        % Get the indices of the subjects
        missing = find(isnan(tab(:, cidx)));
        % Matlab error messages only allow for the double to iterate. Not
        % sure how we could tell them both the subject ID and the confound
        % name
        error('Subject #%d has missing data for one or more confounds. Please fix.\n', missing);
    end
end

% Match subjects in model with those we have data for
s_list = zeros(length(ct_sub), 1);
for ss = 1:length(ct_sub)
    ct_id = ct_sub{ss};
    l_sub = find(strcmp(sid, ct_id));
    if ~isempty(l_sub)
        s_list(ss) = l_sub;
    end
end

% Set up the model structure for the regression
opt_mod = struct;
opt_mod.flag_residuals = true;
m = struct;
m.x = zeros(length(s_list), n_conf+1);
for ss = 1:length(s_list)
    m.x(ss,:) = [1 tab(s_list(ss), conf_ids)];
end
stack = zeros(n_sub, n_vox, n_net);

% Loop through the networks for the regression
for net_id = 1:n_net
    % Get the correct network
    m.y = raw_stack(:, :, net_id);
    [res] = niak_glm(m, opt_mod);
    % Store the residuals in the confound stack
    stack(:, :, net_id) = res.e;
end

% Add the model information
provenance.model = struct;
provenance.model.matrix = m.x;
provenance.model.confounds = confs;

% Save the regressed stack and provenance info
save(path_out, 'provenance', 'stack')