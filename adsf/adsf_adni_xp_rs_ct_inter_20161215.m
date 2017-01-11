%% script to test interaction of resting-state weight and cortical thickness weights on cognition

clear all

path_c = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/adni2/';
path_model = [path_c 'adni2_model_rs_ct_20161215.csv'];

[model_csv.x,model_csv.labels_x,model_csv.labels_y] = niak_read_csv(path_model);

n_var = [28 30 36];

for ss = 1:length(n_var)

    % set up and normalize model
    
    model_csv.y = model_csv.x(:,n_var(ss));
    dv_label = model_csv.labels_y(n_var(ss));
    
    fprintf('Setting up model for dependent variable %s\n',dv_label{1})
    
    opt_n.interaction.label = 'rs_x_ct';
    opt_n.interaction.factor = {'rs_n5_sub3','ct_sub3'};
    opt_n.contrast.rs_x_ct = 1;
    opt_n.contrast.rs_n5_sub3 = 0;
    opt_n.contrast.ct_sub2 = 0;
    opt_n.contrast.age = 0;
    opt_n.contrast.gender = 0;
    opt_n.contrast.diagnosis = 0;
    
    [model_n(ss),opt_n] = niak_normalize_model(model_csv,opt_n);
    
    % get rid of NaN
    
    mask_nan = max(isnan([model_n(ss).x model_n(ss).y]),[],2);
    model_n(ss).x = model_n(ss).x(~mask_nan,:);
    model_n(ss).y = model_n(ss).y(~mask_nan,:);
    
    % perform glm
    
    opt_g.test = 'ttest';
    opt_g.flag_rsquare = true;
    opt_g.flag_residuals = true;
    opt_g.flag_eff = true;
    
    fprintf('Perfoming GLM for dependent variable %s\n',dv_label{1})
    
    [result(ss),opt_g] = niak_glm(model_n(ss),opt_g);
    
    dv_labels{ss} = dv_label; 
    
%     file_res = strcat(path_c '
%     save(

end


