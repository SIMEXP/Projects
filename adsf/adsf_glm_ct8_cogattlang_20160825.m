%% glm to test for associations between occipital lobe CT subtypes and visuospatial ability (RBANS)

clear all

path_ct = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160815_4_meanctnetwb/subtype_weights.mat';
path_csv = '/Users/AngelaTam/Desktop/adsf/model/model_preventad_20160813.csv';
path_out = '/Users/AngelaTam/Desktop/adsf/glm_ct8_attlang_20180825/';
psom_mkdir(path_out);

nb_net = 8; % number of the desired networks
nb_subt = 4; % number of subtypes

load(path_ct)
[tab,list_sub,ly] = niak_read_csv(path_csv);

% generate the models, do the GLMs, and save them

file_res = [path_out 'adsf_glm_ct8_attlang_20160825.mat'];
list_contrast = {'ct8_1','ct8_2','ct8_3','ct8_4'};
list_covariate = [19 20];
name_covariate = {'language','attention'};
glm = struct();
model = struct();

for nn = 1:length(nb_net)
    for vv = 1:length(list_covariate)
        varia = name_covariate{vv};
        for cc = 1:length(list_contrast)
            contrast = list_contrast{cc};
            weights = weight_mat(:,:,nb_net(nn));
            model(nn).(varia).(contrast).x = [ones(size(weight_mat(:,:,nb_net(nn)),1),1) weights(:,cc)];
            cog = tab(:,list_covariate(vv));
            tmp_model = [model(nn).(varia).(contrast).x cog];
            mask_nan = max(isnan(tmp_model),[],2);
            model(nn).(varia).(contrast).x = model(nn).(varia).(contrast).x(~mask_nan,:);
            model(nn).(varia).(contrast).x(:,2:end) = niak_normalize_tseries(model(nn).(varia).(contrast).x(:,2:end));
            model(nn).(varia).(contrast).y = niak_normalize_tseries(cog(~mask_nan,:));
            model(nn).(varia).(contrast).c = [0 1]; % structure containing contrast vectors (1 for variable of interest, 0 for covariates of no interest)
            opt_glm.test = 'ttest';
            glm(nn).(varia).(contrast) = niak_glm(model(nn).(varia).(contrast),opt_glm);
        end
    end
end
save(file_res,'model','glm')

%% Check p-values
for nn = 1:length(nb_net)
    nn
    for cc = 1:length(list_contrast)
        contrast = list_contrast{cc}
        glm(nn).(contrast).pce
    end
end


%% visualization

col = [0 0 0; 0 0 0; 0 0 0];

for nn = 1:length(nb_net)
    for gg = 1:length(list_covariate)
        varia = name_covariate{gg};
        for cc = 1:length(list_contrast)
            contrast = list_contrast{cc};
            figure 
            plot(model(nn).(varia).(contrast).x(:,2),model(nn).(varia).(contrast).y(:,1),'o','markersize',7,'markeredgecolor', (col(3,:)), 'markerfacecolor', (col(3,:)+[2 2 2])/3,'linewidth', 0.3);
            hold on
            beta = niak_lse(model(nn).(varia).(contrast).y(:,1),[ones(size(model(nn).(varia).(contrast).y(:,1))) model(nn).(varia).(contrast).x(:,2)]);
            plot(model(nn).(varia).(contrast).x(:,2),[ones(size(model(nn).(varia).(contrast).y(:,1))) model(nn).(varia).(contrast).x(:,2)]*beta,'linewidth',0.3,'color', (col(3,:)));
            namefig = [path_out 'net' num2str(nb_net(nn)) '_rbans_' varia '_' contrast '.pdf'];
            print(namefig,'-dpdf','-r300')
            close all
        end
    end
end