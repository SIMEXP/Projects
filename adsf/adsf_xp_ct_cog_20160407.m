%%%%%%%%%%%%%%%%%%%%%%

%% script for testing the association between cognitive variables with subtypes of cortical thickness networks
%% prevent-ad dataset, data release 2.0

%%%%%%%%%%%%%%%%%%%%%%

clear

path_data = '/Users/AngelaTam/Desktop/adsf/adsf_basc_ct_20160316/';
ct_subtype = '/Users/AngelaTam/Desktop/adsf/adsf_ct_subtypes_20160316/ct_subtypes_20160316.mat';
path_out = '/Users/AngelaTam/Desktop/adsf/adsf_assoc_ct_cog_20160408/';
psom_mkdir(path_out)

nb_net = 9; % number of networks
nb_subt = 5; % number of subtypes

col = [0 0 0; 0 0 0; 0 0 0];

model = '/Users/AngelaTam/Desktop/adsf/model/adsf_model_20140108.csv'; % model containing variables of interest and no interest 
[tab,list_sub,ly] = niak_read_csv(model);

% load subtypes from previous xp
load(ct_subtype)


%% glm to test for associations between subtypes and variables of interest 

% generate the models, do the GLMs, and save them

file_res = [path_out 'adsf_glm_cog_20160408.mat'];
list_contrast = {'im_mem','vis','lan','att','del_mem'};
list_covariate = [13 14 15 16 17];
glm = struct();
model = struct();
for nn = 1:nb_net
    for cc = 1:length(list_contrast)
        contrast = list_contrast{cc};
        model(nn).(contrast).x = [ones(size(sub(nn).weights,1),1) tab(:,1) tab(:,2) tab(:,18) tab(:,list_covariate(cc))];
        mask_nan = max(isnan(model(nn).(contrast).x),[],2);
        model(nn).(contrast).x = model(nn).(contrast).x(~mask_nan,:);
        model(nn).(contrast).x(:,2:end) = niak_normalize_tseries(model(nn).(contrast).x(:,2:end));
        model(nn).(contrast).y = niak_normalize_tseries(sub(nn).weights(~mask_nan,:));
        model(nn).(contrast).c = [0 0 0 0 1]; % structure containing contrast vectors (1 for variable of interest, 0 for covariates of no interest)
        opt_glm.test = 'ttest';
        glm(nn).(contrast) = niak_glm(model(nn).(contrast),opt_glm);
    end
end
save(file_res,'model','glm')

%% Check p-values
nn = 10;
for cc = 1:length(list_contrast)
    contrast = list_contrast{cc}
    glm(nn).(contrast).pce
end


%% visualization

for nn = 1:nb_net
    for gg = 1:nb_subt
        for cc = 1:length(list_contrast)
            contrast = list_contrast{cc};
            figure 
            plot(model(nn).(contrast).x(:,5),model(nn).(contrast).y(:,gg),'o','markersize',7,'markeredgecolor', (col(3,:)), 'markerfacecolor', (col(3,:)+[2 2 2])/3,'linewidth', 0.3);
            hold on
            beta = niak_lse(model(nn).(contrast).y(:,gg),[ones(size(model(nn).(contrast).y(:,gg))) model(nn).(contrast).x(:,5)]);
            plot(model(nn).(contrast).x(:,5),[ones(size(model(nn).(contrast).y(:,gg))) model(nn).(contrast).x(:,5)]*beta,'linewidth',0.3,'color', (col(3,:)));
            namefig = [path_out 'net' num2str(nn) '_subt' num2str(gg) '_' contrast '.pdf'];
            print(namefig,'-dpdf','-r300')
            close all
        end
    end
end