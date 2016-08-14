%% script to regress covariates (age, gender, mean network cortical thickness) out of raw ct network stacks

clear all

model = '/Users/AngelaTam/Desktop/adsf/model/model_preventad_20160813.csv';

[tab,sid,ly,~] = niak_read_csv(model);
        
opt.regress_conf = cell(1,3);
opt.regress_conf{1} = 'age';
opt.regress_conf{2} = 'gender';

n_sub = size(sid,1); % get number of subjects

for net = 1:9 % for every network
    
    % get the right ct regressor for the network
    opt.regress_conf{3} = strcat('mean_ct_net',num2str(net));
    n_conf = length(opt.regress_conf);
    conf_ids = zeros(n_conf, 1);
    for cid = 1:n_conf
        conf_name = opt.regress_conf{cid};
        cidx = find(strcmp(ly, conf_name));
        % Make sure we found the covariate
        if ~isempty(cidx)
            conf_ids(cid) = cidx;
        else
            error('Could not find column for %s in model file');
        end
    end
    
    % load the specific network stack
    stack_file = strcat('ct_network_', num2str(net), '_stack.mat');
    load(stack_file)
    r_stack = stack;
    n_vox = size(r_stack,2);
    
    % Match subjects in model with those we have data for
    s_list = zeros(n_sub, 1);
    for ss = 1:n_sub
        ct_id = provenance.subjects{ss};
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
    stack = zeros(n_sub, n_vox);
    
    % Do the regression
    m.y = r_stack;
    [res] = niak_glm(m, opt_mod);
    % Store the residuals in the confound stack
    stack = res.e;
    
    % Provenance stuff
    provenance.model = struct;
    provenance.model.matrix = m.x;
    provenance.model.confounds = opt.regress_conf;
    
    % Save the new stack
    fname = strcat('/Users/AngelaTam/Desktop/adsf/ct_stack_age_gender_meanctnet/ct_network_',num2str(net),'_stack.mat');
    save(fname, 'stack', 'provenance')

end