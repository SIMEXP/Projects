%%%%%%%%%%%%%%%%%%%%%%

%% script for testing the association between structural volumes with subtypes of cortical thickness networks
%% prevent-ad dataset, data release 2.0

%%%%%%%%%%%%%%%%%%%%%%

clear

path_data = '/Users/AngelaTam/Desktop/adsf/adsf_basc_ct_20160316/';
ct_data = [path_data 'preventad_civet_vertex_bl_20160316.mat'];
msteps_part = [path_data 'msteps_part.mat'];
path_out = '/Users/AngelaTam/Desktop/adsf/adsf_assoc_ct_vol_20160316/';

nb_net = 9; % number of networks
nb_subt = 5; % number of subtypes

col = [0 0 0; 0 0 0; 0 0 0];

model = '/Users/AngelaTam/Desktop/adsf/model/preventad_model_vol_bl_dr2_20160316_qc_2.csv'; % model containing variables of interest and no interest (note: removed failed qc [rs-fmri, civet], failed T1s are filled with Nans for this model)
[tab,list_sub,ly] = niak_read_csv(model);

% Extract volume measures from model
vol = tab(:,24:end);
vol_sf = vol(:,2:end) .* repmat(vol(:,1),[1 size(vol,2)-1]); % multiply all individual raw volumes by the scale factor
labels_vol_sf = ly(25:end); % labels for volume measures

% load cortical thickness data
load(ct_data)
% load basc parcellation
load(msteps_part)

%%

% load subtypes from previous subtyping xp
ct_subtype = '/Users/AngelaTam/Desktop/adsf/adsf_ct_subtypes_20160316/ct_subtypes_20160316.mat';
load(ct_subtype)


% %% regress out confounding variables (age, fd, gender)
% 
% model.x = [ones(length(list_sub),1) tab(:,1) tab(:,2) tab(:,18)];
% mask_nnan = ~max(isnan(model.x),[],2);
% model.x = model.x(mask_nnan,:); 
% data = ct(mask_nnan,:,:);  % putting a mask to get rid of NaNs over the loaded variable ct (from ct_data)
% tab = tab(mask_nnan,:); % mask to get rid of NaNs within tab
% vol_sf = vol(mask_nnan,:); % mask to get rid of NaNs within vol_sf
% list_sub = list_sub(mask_nnan);
% 
% for nn = 1:size(data,3)
%     model.y = data(:,:,nn);
%     model.c = [1 0 0 0];
%     opt_glm.test = 'ttest';
%     opt_glm.flag_residuals = true;
%     glm = niak_glm(model,opt_glm);
%     data(:,:,nn) = glm.e;
% end
%     
% 
% %% subtyping the residual glm (left after regressing confounds)
% file_sub = [path_out 'ct_subtypes_20160316.mat'];
% 
% for nn = 1:nb_net
%     sub(nn) = niak_build_subtypes(data,nb_subt,part(:,2)==(nn));
% end
% save(file_sub,'sub')

%% glm to test for associations between subtypes and variables of interest 

% generate the models, do the GLMs, and save them

file_res = [path_out 'adsf_glm_vol_20160316.mat'];
list_contrast = {'pari_r_gm','occi_r_gm','pari_l_gm','occi_l_gm','fron_l_gm','fron_r_gm','temp_l_gm','temp_r_gm','hipp_r_gm','hipp_l_gm'};
list_covariate = [5 6 7 8 23 24 25 26 39 40];
glm = struct();
model = struct();
for nn = 1:nb_net
    for cc = 1:length(list_contrast)
        contrast = list_contrast{cc};
        model(nn).(contrast).x = [ones(size(sub(nn).weights,1),1) tab(:,1) tab(:,2) tab(:,18) vol_sf(:,list_covariate(cc))];
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
            figure % 4+cc in the following lines because the first four variables in the model are the intercept + confounds
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


