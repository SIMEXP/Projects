%% script to run glms on resting-state weights and cognitive weights (ecogsp) in adni2

clear all

path_model = '/Users/AngelaTam/Desktop/adsf/cognitive_subtypes/adni_cog/adni2_ecogsp_weights.csv';
file_res = '/Users/AngelaTam/Desktop/adsf/cognitive_subtypes/cog_rs_weights_glm_20161208.mat';

var_y = 1:4; % dependent variables of interest in tab

var_x = [5:7; 8:10; 11:13]; % independent variables of interest in tab

list_contrast = {'limbic','dmn','salience'};
list_subtype = {'sub_1','sub_2','sub_3'};

[tab,sub,ly] = niak_read_csv(path_model);

mask_nan = max(isnan(tab),[],2);
tab = tab(~mask_nan,:);
sub = sub(~mask_nan);

for iv = 1:length(list_contrast)
    for vv = 1:length(list_subtype)
        contrast = list_contrast{iv};
        subtype = list_subtype{vv};
        % temporarily store x variable
        xx = var_x(iv,:);
        % set up model with one iv and covariates of no interest (age, gender, diagnosis)
        model.(contrast).(subtype).x = [tab(:,xx(vv)) tab(:,14) tab(:,15) tab(:,16)];
        % set up dependent variables in model (3 subtypes per resting-state network)
        model.(contrast).(subtype).y = tab(:,var_y);
        % set up contrast vector
        model.(contrast).(subtype).c = [1 0 0 0];
        model.(contrast).(subtype).labels_y = [ly(1) ly(2) ly(3) ly(4)];
        model.(contrast).(subtype).labels_x = [ly(xx(vv)) ly(14) ly(15) ly(16)];
        opt_glm.test = 'ttest';
        opt_glm.flag_rsquare = true;
        glm.(contrast).(subtype) = niak_glm(model.(contrast).(subtype),opt_glm);
    end
end
save(file_res,'model','glm')

