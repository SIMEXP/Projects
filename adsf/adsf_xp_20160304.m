clear


path_data = '/Users/AngelaTam/Desktop/adsf/adsf_basc_ct_20160204/';
ct_data = [path_data 'preventad_civet_vertex_bl_20160202.mat'];
msteps_part = [path_data 'msteps_part.mat'];

% load cortical thickness data
load(ct_data)
% load basc parcellation
load(msteps_part)

path_out = '/Users/AngelaTam/Desktop/adsf/adsf_assoc_20160308/';
model = '/Users/AngelaTam/Desktop/adsf/model/model_preventad_20160121.csv'; % model containing variables of interest and no interest
[tab,list_subject,ly] = niak_read_csv(model);
nb_net = 11; % number of networks
nb_subt = 5; % number of subtypes
col = [0 0 0; 0 0 0; 0 0 0];

%% regress out confounding variables (age, fd, gender)

model.x = [ones(length(list_subject),1) tab(:,1) tab(:,2) tab(:,20)];
mask_nnan = ~max(isnan(model.x),[],2);
model.x = model.x(mask_nnan,:); 
data = ct(mask_nnan,:,:);  % putting a mask to get rid of NaNs over the loaded variable ct (from ct_data)
tab = tab(mask_nnan,:);
list_subject = list_subject(mask_nnan);

for nn = 1:size(data,3)
    model.y = data(:,:,nn);
    model.c = [1 0 0 0];
    opt_glm.test = 'ttest';
    opt_glm.flag_residuals = true;
    glm = niak_glm(model,opt_glm);
    data(:,:,nn) = glm.e;
end
    

%% subtyping the residual glm (left after regressing confounds)

for nn = 1:nb_net
sub(nn) = niak_build_subtypes(data,nb_subt,part(:,2)==(nn));
end
save('/Users/AngelaTam/Desktop/adsf/adsf_assoc_20160308/ct_subtypes_20160308.mat','sub')

%% glm to test for associations between subtypes and variables of interest ; add confounding variables again
% Louis Collins volumetrics? APOE, BDNF, 

flag_verb = false;

vv = 5; % variable number from model
for nn = 1:nb_net
    model.x = [ones(size(sub(nn).weights,1),1) tab(:,vv)];
        mask_nan = max(isnan(model.x),[],2);
        model.x = model.x(~mask_nan,:);
        model.y = sub(nn).weights(~mask_nan,:);
        model.c = [0 1]; % 0 to control for variables of no interest, 1 for associations with desired variables
        if ~flag_verb
            flag_verb = true;
            sum(model.x(:,2))
            sum(~model.x(:,2))
        end
        opt_glm.test = 'ttest';
        glm = niak_glm(model,opt_glm);
        pce(nn,:) = glm.pce;
        
        for cc = 1:nb_subt
            figure
            plot(model.x(:,2),model.y(:,cc),'o','markersize',7,'markeredgecolor', (col(3,:)), 'markerfacecolor', (col(3,:)+[2 2 2])/3,'linewidth', 0.3);
            hold on
            beta = niak_lse(model.y(:,cc),[ones(size(model.y(:,cc))) model.x(:,2)]);
            plot(model.x(:,2),[ones(size(model.y(:,cc))) model.x(:,2)]*beta,'linewidth',0.3,'color', (col(3,:)));
            namefig = [path_out 'net' num2str(nn) '_subt' num2str(cc) 'variable' num2str(vv) '.pdf'];
            print(namefig,'-dpdf','-r300')
            close all
        end
end
