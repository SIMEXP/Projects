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
list_fdr = [0.01 0.05 0.1 0.2];
% Number of samples
nb_samps = 100;
% GLM options
opt_glm.test = 'ttest';
% network FDR options
opt_netfdr.nb_samps = 1000;
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
part = repmat(1:10,[10 1]);
part = part(:);
for num_samp = 1:nb_samps
    niak_progress(num_samp,nb_samps);
    if (num_samp == 1)
        [model,mask_true] = niak_simus_glm_connectome(opt_simu);
    else
        model = niak_simus_glm_connectome(opt_simu);
    end
    for num_fdr = 1:length(list_fdr)
        opt_netfdr.q = list_fdr(num_fdr);
        opt_netfdr.flag_verbose = false;
        res = niak_network_fdr(model,part,opt_netfdr);
        if (num_samp == 1)&&(num_fdr==1)
            samps_fdrnet = zeros(nb_samps,length(res.ttest),length(list_fdr));
        end
        samps_fdrnet(num_samp,:,num_fdr) = res.test_fdr{1}; 
    end
end

%% Estimate effective FDR and sensitivity for network_fdr
fprintf('Evaluating NETFDR...\n'); 

sens_netfdr = zeros(length(list_fdr),1);
fdr_netfdr  = zeros(length(list_fdr),1);
for num_fdr=1:length(list_fdr)
    tp=sum(samps_netfdr(:,mask_true,num_fdr),2);
    nb_disc = sum(samps_netfdr(:,:,num_fdr),2);    
    sens_netfdr(num_fdr)=mean(tp/sum(mask_true));
    tmp=tp./nb_disc;
    tmp(isnan(tmp))=1; 
    fdr_netfdr(num_fdr)=mean(1-tmp);    
end 
if fdr_netfdr(end)<max(list_fdr)
    fdr_netfdr  = [fdr_netfdr ; max(list_fdr) ]; 
    sens_netfdr = [sens_netfdr ; sens_netfdr(end)]; 
end

figure;
set(gcf,'Position',[100,100,1000,300]);
subplot(1,2,1);
semilogx(fdr1,tpr1,'b+-'); 
hold; 
semilogx(fdr2,tpr2,'r+-');
semilogx(fdrG,tprG,'k+-');
semilogx(fdrGs,tprG,'g+-');
legend('NBS','FDR-BH','FDR-Group','FDR-group-sym','Location','NorthWest');
xlim([0.01,Max_FDR]);
xlabel('False Discovery Rate');
ylabel('True Positive Rate');

subplot(1,2,2);


%AUC
Max_FDR = 0.15;
auc1=auc(flipud(fdr1),flipud(tpr1),Max_FDR)*1/Max_FDR; 
auc2=auc(fdr2,tpr2,Max_FDR)*1/Max_FDR;
aucG=auc(fdrG,tprG,Max_FDR)*1/Max_FDR;
aucGs=auc(fdrGs,tprGs,Max_FDR)*1/Max_FDR;

%set(gcf,'Position',[100,550,500,250]);
bar([auc1,auc2,aucG,aucGs]); 
set(gca, 'XTick', 1:4, 'XTickLabel', {'NBS','FDR-BH','FDR-Group','FDR-Group-sym'});
ylabel('Area Under Curve'); 

%% effective fdr
figure
subplot(1,3,1)
plot(rng,rng,'r')
hold on
plot(rng,fdr2);
title('FDR-BH')
xlabel('Nominal FDR')
ylabel('Effective FDR')

subplot(1,3,2)
plot(rng,rng,'r')
hold on
plot(rng,fdrG);
title('FDR-group')
xlabel('Nominal FDR')
ylabel('Effective FDR')

subplot(1,3,3)
plot(rng,rng,'r')
hold on
plot(rng,fdrGs);
title('FDR-group-sym')
xlabel('Nominal FDR')
ylabel('Effective FDR')
