clear all
close all

% Test statistic threshold (NBS) 
T=3; 
% List of scenarios
list_scenario = { 'star' };
% Number of total nodes
opt_simu.n = 100;
% The effect size
opt_simu.theta = 1;
% The number of subjects per group
opt_simu.s = 20;
% Maximum FDR estimated
Max_FDR=0.2; 
% FDR
%list_fdr = [0.01 0.05 0.1 0.2];
list_fdr = [0.01 0.05 0.1 0.2];
% Number of samples
nb_samps = 20;
% GLM options
opt_glm.test = 'ttest';
% network FDR options
opt_netfdr.nb_samps = 2000;
opt_netfdr.nb_classes = 7;

%% NBS
for num_samp = 1:nb_samps
    if num_samp == 1
        [model,mask_true] = niak_simus_glm_connectome(opt_simu);
    else
        model = niak_simus_glm_connectome(opt_simu);
    end
    res = niak_glm(model,opt_glm);
    if num_samp == 1
        samps_nbs = zeros(nb_samps,length(res.ttest));
    end
    samps_nbs(num_samp,:) = niak_mat2lvec(nbs(niak_lvec2mat(res.ttest),T)); 
end

%% Estimate effective FDR and sensitivity for NBS
fprintf('Evaluating NBS...\n'); 
rng=0:max(max(samps_nbs));

sens_nbs = zeros(length(rng),1);
fdr_nbs  = zeros(length(rng),1);
for num_rng=1:length(rng)
    tp=sum(samps_nbs(:,mask_true)>rng(num_rng),2);
    nb_disc = sum(samps_nbs>rng(num_rng),2);    
    sens_nbs(num_rng)=mean(tp/sum(mask_true));
    tmp=tp./nb_disc;
    tmp(isnan(tmp))=1; 
    fdr_nbs(num_rng)=mean(1-tmp);    
end 
if fdr_nbs(1)<max(list_fdr)
    fdr_nbs  = [max(list_fdr) ; fdr_nbs  ]; 
    sens_nbs = [sens_nbs(1)   ; sens_nbs ]; 
end
 
%% Network FDR 
fprintf('Evaluating NETFDR...\n'); 
part = repmat(1:10,[10 1]);
part = part(:);
for num_samp = 1:nb_samps
    niak_progress(num_samp,nb_samps);
    if (num_samp == 1)
        [model,mask_true] = niak_simus_glm_connectome(opt_simu);
    else
        model = niak_simus_glm_connectome(opt_simu);
    end
    opt_netfdr.q = list_fdr;
    opt_netfdr.flag_verbose = false;
    res = niak_network_fdr(model,part,opt_netfdr);
    if (num_samp == 1)
        samps_fdrnet = zeros(nb_samps,length(res.ttest),length(list_fdr));
    end
    for qq = 1:length(list_fdr)
        samps_fdrnet(num_samp,:,qq) = res.test_fdr{1,qq}; 
    end
end

%% Estimate effective FDR and sensitivity for network_fdr

sens_netfdr = zeros(length(list_fdr),1);
fdr_netfdr  = zeros(length(list_fdr),1);
for num_fdr=1:length(list_fdr)
    tp=sum(samps_fdrnet(:,mask_true,num_fdr),2);
    nb_disc = sum(samps_fdrnet(:,:,num_fdr),2);    
    sens_netfdr(num_fdr)=mean(tp/sum(mask_true));
    tmp=tp./nb_disc;
    tmp(isnan(tmp))=1; 
    fdr_netfdr(num_fdr)=mean(1-tmp);    
end 
if fdr_netfdr(end)<max(list_fdr)
    fdr_netfdr  = [fdr_netfdr ; max(list_fdr) ]; 
    sens_netfdr = [sens_netfdr ; sens_netfdr(end)]; 
end

%% ROC curve
subplot(1,3,1);
set(gcf,'Position',[100,100,1000,300]);
semilogx(fdr_nbs,sens_nbs,'b+-'); 
hold; 
semilogx(fdr_netfdr,sens_netfdr,'r+-');
legend('NBS','NETFDR','Location','NorthWest');
xlim([0.01,Max_FDR]);
xlabel('False Discovery Rate');
ylabel('Sensitivity');

%AUC
subplot(1,3,2);
auc_nbs    = auc(flipud(fdr_nbs),flipud(sens_nbs),Max_FDR)*1/Max_FDR; 
auc_netfdr = auc(flipud(fdr_netfdr),flipud(sens_netfdr),Max_FDR)*1/Max_FDR; 
bar([auc_nbs,auc_netfdr]); 
set(gca, 'XTick', 1:4, 'XTickLabel', {'NBS','FDRNET'});
ylabel('Area Under Curve'); 

%% effective fdr
subplot(1,3,3)
plot(list_fdr,list_fdr,'r')
hold on
plot(list_fdr,fdr_netfdr);
title('NETFDR')
xlabel('Nominal FDR')
ylabel('Effective FDR')
