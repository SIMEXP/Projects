%% script to run glms on resting-state subtype weights vs cortical thickness (sc 4 net 1) subtype weights

clear all

path_model = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/model/admci_model_ct_sc4net1_rs_20161018.csv';
file_res = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_rs_glm/ct_sc4net1_rs_weights_glm_20161018.mat';

var_y = [19 20 21; 22 23 24; 25 26 27]; % dependent variables of interest in tab

var_x = 15:18; % independent variables of interest in tab

list_contrast = {'limbic','dmn','salience'};

[tab,sub,ly] = niak_read_csv(path_model);

for iv = 1:length(var_x)
    for dv = 1:length(var_y)
        contrast = list_contrast{dv};
        % set up model with one iv and covariates of no interest (age, gender, sites)
        model(iv).(contrast).x = [tab(:,var_x(iv)) tab(:,1) tab(:,2) tab(:,6) tab(:,7) tab(:,8) tab(:,9)];
        % temporarily store y variables here
        yy = var_y(dv,:);
        % set up dependent variables in model (3 subtypes per resting-state network)
        model(iv).(contrast).y = [tab(:,yy(1)) tab(:,yy(2)) tab(:,yy(3))];
        % set up contrast vector
        model(iv).(contrast).c = [1 0 0 0 0 0 0];
        model(iv).(contrast).labels_y = [ly(yy(1)) ly(yy(2)) ly(yy(3))];
        model(iv).(contrast).labels_x = [ly(var_x(iv)) ly(1) ly(2) ly(6) ly(7) ly(8) ly(9)];
        opt_glm.test = 'ttest';
        opt_glm.flag_rsquare = true;
        glm(iv).(contrast) = niak_glm(model(iv).(contrast),opt_glm);
    end
end
save(file_res,'model','glm')
    


