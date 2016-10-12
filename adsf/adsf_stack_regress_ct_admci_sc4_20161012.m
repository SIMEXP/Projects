%% script to regress covariates (age, gender, mean network cortical thickness and whole brain ct) out of raw ct network stacks
% ct basc scale 4 admci template

clear all

model = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/model/admci_model_20161007_sc4.csv';

[tab,sid,ly,~] = niak_read_csv(model);
        
opt.regress_conf = cell(1,4);
opt.regress_conf{1} = 'age';
opt.regress_conf{2} = 'gender';
opt.regress_conf{3} = 'mean_ct_wb';
opt.regress_conf{4} = 'mnimci';
opt.regress_conf{5} = 'criugmad';
opt.regress_conf{6} = 'criugmmci';
opt.regress_conf{7} = 'adni5';

n_sub = size(sid,1); % get number of subjects

for net = 1:4 % for every network
    
    % get the right ct regressor for the network
    opt.regress_conf{8} = strcat('mean_ct_sc4_net',num2str(net));
    n_conf = length(opt.regress_conf);
    conf_ids = zeros(n_conf, 1);
    for cid = 1:n_conf
        conf_name = opt.regress_conf{cid};
        cidx = find(strcmp(ly, conf_name));
        % Make sure we found the covariate
        if ~isempty(cidx)
            conf_ids(cid) = cidx;
        else
            error('Could not find column for %s in model file',conf_name);
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
    fname = strcat('/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/basc_sc4_stacks/regress_agesexmeanct/ct_network_',num2str(net),'_stack.mat');
    save(fname, 'stack', 'provenance')

end