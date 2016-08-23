%% glm to test for associations between cognition and global measures of cortical thickness 
%% cogntion = age, gender, education, apoe, cortical thickness

clear all

path_csv = '/Users/AngelaTam/Desktop/adsf/model/model_preventad_20160813.csv';
path_out = '/Users/AngelaTam/Desktop/adsf/glm_mean_ct_cog_20160822/';
psom_mkdir(path_out);

[tab,list_sub,ly] = niak_read_csv(path_csv);

list_cog_name = {'immediate_mem','visuospatial','language','attention','delayed_mem'};
list_cog = [17 18 19 20 21];

glm = struct();
model = struct();

for vv = 1:length(list_cog)
    cog_var = list_cog_name{vv};
    
    list_contrast = {'whole_brain','net1','net2','net3','net4','net5','net6','net7','net8','net9'};
    list_covariate = [22 23 24 25 26 27 28 29 30 31];
    
    for cc = 1:length(list_contrast)
        contrast = list_contrast{cc};
        model.(contrast).x = [ones(size(tab,1),1) tab(:,1) tab(:,2) tab(:,3) tab(:,5) tab(:,list_covariate(cc))];
        mask_nan = max(isnan(model.(contrast).x),[],2);
        model.(contrast).x = model.(contrast).x(~mask_nan,:);
        %         model.(contrast).x(:,2:end) = niak_normalize_tseries(model.(contrast).x(:,2:end));
        
        v_cog = tab(:,list_cog(vv));
        %         model.(contrast).y = niak_normalize_tseries(v_cog(~mask_nan,:));
        model.(contrast).y = v_cog(~mask_nan,:);
        model.(contrast).c = [0 0 0 0 0 1]; % structure containing contrast vectors (1 for variable of interest, 0 for covariates of no interest)
        opt_g = struct;
        opt_g.test = 'ttest';
        opt_g.flag_beta = true;
        opt_g.flag_rsquare = true;
        opt_g.flag_eff = true;
        glm.(contrast) = niak_glm(model.(contrast),opt_g);
    end
    
    file_res = strcat(path_out, 'adsf_glm_mean_ct_', cog_var, '_20160822.mat');
    save(file_res,'model','glm')
end

%% Check p-values
for nn = 1:length(nb_cnet)
    nn
    for cc = 1:length(list_contrast)
        contrast = list_contrast{cc}
        glm(nn).(contrast).pce
    end
end