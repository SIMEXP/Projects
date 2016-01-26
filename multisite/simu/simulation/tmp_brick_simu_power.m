function [files_in,files_out,opt] = scrubbing_brick_simu_power_ttest_multisite(files_in,files_out,opt)
% FILES_IN
%   (structure) with the following fields:
%   DATA
%   (string) the name of a mat file with the Y/X variables
%
%   DEMOGRAPHIC
%   (string) the name of a mat file with the demographic values
%
% FILES_OUT
%   (string) the name of a .mat file to store the results
%
% OPT
%   (structure) with the following fields:
%
%   RAND_SEED
%      (vector, default []) if non-empty, RAND_SEED is used to 
%      initialize the random number generator using PSOM_SET_RAND_SEED
%
%   NB_SAMPS
%      (scalar, default 1000) the number of Monte-Carlo samples
%
%   THRESHOLD_P
%      (scalar, default 0.01) the threshold on p-value for the test
%
%   Q
%      (scalar, default 0.2) the q factor in the FDR correction
%
%   SUB_SAMP
%      (scalar, default 0.6) the sample size of each group for every
%      simulation in pourcentage
%
%   ADNI2ONLY
%      (boolean, default false) the simulation will be executed only on adni2
%
%   FLAG_TEST
%      (boolean, default false) if the FLAG is true, do not do 
%      anything. Just update the default values. 
%       


%% Default options

list_fields   = { 'rand_seed' , 'threshold_p' , 'nb_samps' , 'flag_test' , 'q'  , 'sub_samp','adni2only'};
list_defaults = { []          , 0.05          , 1000       , false       ,  0.05 ,  0.6      ,false  };
if nargin < 3
    opt = psom_struct_defaults ( struct , list_fields , list_defaults );
else
    opt = psom_struct_defaults ( opt    , list_fields , list_defaults );
end

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%% Seed the random generator
if ~isempty(opt.rand_seed)
    psom_set_rand_seed(opt.rand_seed);
end

%% Load inputs 
% data = load(files_in.data);
% X = data.X;
% Y = data.Y;
% label_subjects = data.label_subject;
% label_covar = data.label_covar;
% nb_site = length(label_covar)-1;
% nb_conn = size(Y,2);

[x,lx,ly]    = niak_read_csv(files_in.demographic);
[y,lyx,lyy] = niak_read_csv(files_in.data);

y = y(:,37:end); % keep only p2p 
lyy = lyy(37:end);
[mask,ind] = ismember(lyx,lx);
x = x(ind,:);
lx = lx(ind);

mask_apriori = ismember(lyy,{'p2p_PCC_X_PCUN','p2p_dMPFC_X_dMPFC2','p2p_IPL_X_SFGr','p2p_aMPFC_X_PCUN','p2p_SFGr_X_FUS','p2p_PCC_X_PCUNm','p2p_IPL_X_dMPFC3','p2p_PCC_X_MTL','p2p_IPL_X_MTL','p2p_aMPFC_X_MTL'});

opt_glm.test = 'ttest';
%% Build masks
mask_ctrl = x(:,3) == 1;
mask_mci = x(:,3) == 2;
mask_ad  = x(:,3) == 3;
fprintf('CTL: %i, MCI: %i, DTA: %i\n',sum(mask_ctrl),sum(mask_mci),sum(mask_ad));

%% Normalize
%x = niak_normalize_tseries(x,'mean');
%x(:,2) = niak_normalize_tseries(x(:,2),'mean');

%% Run the simulation for multisite
sens_adctrl = 0;
sens_mcictrl = 0;
sens_admci = 0;
nadmci =[0,0,0];
nmcictrl =[0,0,0];
nadctrl =[0,0,0];
for num_samp = 1:opt.nb_samps
    
    if opt.adni2only 
        sites = x(:,[5]);
    else
        %sites = x(:,[5,7,8,9,10]);
        sites = [x(:,5), sum(x(:,[7,8,9,10]),2)];
        %sites = [x(:,5), sum(x(:,[7,8,9]),2)]; % excluded adpd
        %sites = [x(:,[5,7,10]), sum(x(:,[8,9]),2)]; % all site  adni2, criugm ad mci fused and mnimci and adpd independant
    end
    
    
    %sites = x(:,[8,9,10]);
    
    %% Run a test for AD-CTL
    [subsamp1,subsamp2,subsites] = sub_strata(mask_ad,mask_ctrl,sites,opt.sub_samp); 
    nadctrl = nadctrl + [size(subsites,2), sum(subsamp1),sum(subsamp2)];
    subsites = sum(subsites.*repmat([1:size(subsites,2)],size(subsites,1),1),2);
    
    x2 = x(:,[1,2,3]); % gender, age, diagnosis, ...
    subsites = subsites(subsamp1|subsamp2,:);
    x2 = x2(subsamp1|subsamp2,:);
    x2(:,3) = subsamp1(subsamp1|subsamp2);
    x2(:,1) = x2(:,1) == 2;
    y2 = y(subsamp1|subsamp2,mask_apriori);
    
%     if (sum(x2(:,2))/size(x2(:,2),1))==1
%         x2 = x2(:,[1,3:end]); 
%         c  = zeros(size(x2,2),1);
%         c(3) = 1;
%     else
%         c  = zeros(size(x2,2),1);
%         c(4) = 1;
%     end
    
    c  = zeros(size(x2,2),1);
    c(3) = 1;
    
    model.c = c;
    model.x = x2;
    model.y = y2;
    opt_glm.multisite = subsites;
    
    [results , opt_glm]=niak_glm_multisite(model,opt_glm);  
    pce = results.pce;


    %[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,c);
    %[fdr,test] = niak_fdr(pce(mask_apriori),'BH',opt.q);
    test = (pce <= opt.threshold_p);
    sens_adctrl = sens_adctrl + test;
    
    
    %% Run a test for MCI-CTL
    [subsamp1,subsamp2,subsites] = sub_strata(mask_mci,mask_ctrl,sites,opt.sub_samp);
    nmcictrl = nmcictrl + [size(subsites,2), sum(subsamp1),sum(subsamp2)];
    subsites = sum(subsites.*repmat([1:size(subsites,2)],size(subsites,1),1),2);
    
    x2 = x(:,[1,2,3]); % gender, age, diagnosis, ...
    subsites = subsites(subsamp1|subsamp2,:);
    x2 = x2(subsamp1|subsamp2,:);
    x2(:,3) = subsamp1(subsamp1|subsamp2);
    x2(:,1) = x2(:,1) == 2;
    y2 = y(subsamp1|subsamp2,mask_apriori);
%     if (sum(x2(:,2))/size(x2(:,2),1))==1
%         x2 = x2(:,[1,3:end]); 
%         c  = zeros(size(x2,2),1);
%         c(3) = 1;
%     else
%         c  = zeros(size(x2,2),1);
%         c(4) = 1;
%     end
    
    c  = zeros(size(x2,2),1);
    c(3) = 1;
    
    model.c = c;
    model.x = x2;
    model.y = y2;
    opt_glm.multisite = subsites;
    
   
    [results , opt_glm]=niak_glm_multisite(model,opt_glm);  
    pce = results.pce;
    %[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,c);
    %[fdr,test] = niak_fdr(pce(mask_apriori),'BH',opt.q);
    test = pce <= opt.threshold_p;
    sens_mcictrl = sens_mcictrl + test;

    %% Run a test for AD-MCI
    [subsamp1,subsamp2,subsites] = sub_strata(mask_ad,mask_mci,sites,opt.sub_samp);
    nadmci = nadmci + [size(subsites,2), sum(subsamp1),sum(subsamp2)];
    subsites = sum(subsites.*repmat([1:size(subsites,2)],size(subsites,1),1),2);
    
    x2 = x(:,[1,2,3]); % gender, age, diagnosis, ...
    subsites = subsites(subsamp1|subsamp2,:);
    x2 = x2(subsamp1|subsamp2,:);
    x2(:,3) = subsamp1(subsamp1|subsamp2);
    x2(:,1) = x2(:,1) == 2;
    y2 = y(subsamp1|subsamp2,mask_apriori);
%     if (sum(x2(:,2))/size(x2(:,2),1))==1
%         x2 = x2(:,[1,3:end]); 
%         c  = zeros(size(x2,2),1);
%         c(3) = 1;
%     else
%         c  = zeros(size(x2,2),1);
%         c(4) = 1;
%     end
    c  = zeros(size(x2,2),1);
    c(3) = 1;
    
    model.c = c;
    model.x = x2;
    model.y = y2;
    opt_glm.multisite = subsites;


    [results , opt_glm]=niak_glm_multisite(model,opt_glm);  
    pce = results.pce;

    %[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,c);
    %[fdr,test] = niak_fdr(pce(mask_apriori),'BH',opt.q);
    test = pce <= opt.threshold_p;
    sens_admci = sens_admci + test;


end
sens_multisite_adctrl = sens_adctrl/opt.nb_samps;
sens_multisite_mcictrl = sens_mcictrl/opt.nb_samps;
sens_multisite_admci = sens_admci/opt.nb_samps;

sens_stat.avg_nadmci = nadmci ./ opt.nb_samps;
sens_stat.avg_nmcictrl = nmcictrl ./ opt.nb_samps;
sens_stat.avg_nadctrl = nadctrl ./ opt.nb_samps;


% global ttest
 %% Run a test for AD-CTRL
    [subsamp1,subsamp2,subsites] = sub_strata(mask_ad,mask_ctrl,sites,1);
    allsubj_gb.adctrl.nsites = size(subsites,2);
    allsubj_gb.adctrl.narg1 = sum(subsamp1);
    allsubj_gb.adctrl.narg2 = sum(subsamp2);
    if(size(subsites,2)==1)
        subsites=[];
    else
        subsites = subsites(:,1:end-1);
    end
    x2 = [ones(size(x,1),1) x(:,[1,2,3]) subsites]; % intercept, gender, age, diagnosis, sites ...
    x2 = x2(subsamp1|subsamp2,:);
    x2(:,4) = subsamp1(subsamp1|subsamp2);
    x2(:,2) = x2(:,2) == 2;
    y2 = y(subsamp1|subsamp2,mask_apriori);
    c  = zeros(size(x2,2),1);
    c(4) = 1;
    [beta,e,std_e,ttest,pce] = niak_lse(y2,x2,c);
    %[fdr,test] = niak_fdr(pce(mask_apriori),'BH',opt.q);
    sens_gb_adctrl = pce <= opt.threshold_p;
    allsubj_gb.adctrl.pce = pce;
    
    %% Run a test for MCI-CTRL
    [subsamp1,subsamp2,subsites] = sub_strata(mask_mci,mask_ctrl,sites,1);
    allsubj_gb.mcictrl.nsites = size(subsites,2);
    allsubj_gb.mcictrl.narg1 = sum(subsamp1);
    allsubj_gb.mcictrl.narg2 = sum(subsamp2);
    if(size(subsites,2)==1)
        subsites=[];
    else
        subsites = subsites(:,1:end-1);
    end
    x2 = [ones(size(x,1),1) x(:,[1,2,3]) subsites]; % intercept, gender, age, diagnosis, sites ...
    x2 = x2(subsamp1|subsamp2,:);
    x2(:,4) = subsamp1(subsamp1|subsamp2);
    x2(:,2) = x2(:,2) == 2;
    y2 = y(subsamp1|subsamp2,mask_apriori);
    c  = zeros(size(x2,2),1);
    c(4) = 1;
    [beta,e,std_e,ttest,pce] = niak_lse(y2,x2,c);
    %[fdr,test] = niak_fdr(pce(mask_apriori),'BH',opt.q);
    sens_gb_mcictrl = pce <= opt.threshold_p;
    allsubj_gb.mcictrl.pce = pce;
    
    %% Run a test for AD-MCI
    [subsamp1,subsamp2,subsites] = sub_strata(mask_ad,mask_mci,sites,1);
    allsubj_gb.admci.nsites = size(subsites,2);
    allsubj_gb.admci.narg1 = sum(subsamp1);
    allsubj_gb.admci.narg2 = sum(subsamp2);
    if(size(subsites,2)==1)
        subsites=[];
    else
        subsites = subsites(:,1:end-1);
    end
    x2 = [ones(size(x,1),1) x(:,[1,2,3]) subsites]; % intercept, gender, age, diagnosis, sites ...
    x2 = x2(subsamp1|subsamp2,:);
    x2(:,4) = subsamp1(subsamp1|subsamp2);
    x2(:,2) = x2(:,2) == 2;
    y2 = y(subsamp1|subsamp2,mask_apriori);
    c  = zeros(size(x2,2),1);
    c(4) = 1;
    [beta,e,std_e,ttest,pce] = niak_lse(y2,x2,c);
    %[fdr,test] = niak_fdr(pce(mask_apriori),'BH',opt.q);
    sens_gb_admci = pce <= opt.threshold_p;
    allsubj_gb.admci.pce = pce;

%% Save results
nb_samps = opt.nb_samps;
sub_samp = opt.sub_samp;
group_size_ctrl_mci_ad = [sum(mask_ctrl),sum(mask_mci),sum(mask_ad)];
labels_conn = lyy(mask_apriori);
threshold_p = opt.threshold_p;
save(files_out,'sens_multisite_adctrl','sens_multisite_mcictrl','sens_multisite_admci','sens_gb_adctrl','sens_gb_mcictrl','sens_gb_admci','nb_samps','sub_samp','group_size_ctrl_mci_ad','labels_conn','threshold_p','allsubj_gb','sens_stat')

function [subsamp1,subsamp2,subsites] = sub_strata(var1,var2,sites,pct_subsamp)
% Apply a stratified subsampling on the two datasample based on the sites
nb_sites = size(sites,2);
subsamp1 = zeros(size(var1));
subsamp2 = zeros(size(var2));
subsites = [];
for num_s = 1:nb_sites
    n_sub1 = ceil(sum(sites(:,num_s) & var1)*pct_subsamp);
    n_sub2 = ceil(sum(sites(:,num_s) & var2)*pct_subsamp);
    %min_n = min(n_sub1,n_sub2);
    
   if n_sub1<=3 || n_sub2<=3
        %Do noting with this site (it will be excluded)
   else
        subsites = [subsites, sites(:,num_s)];
        % Selectect a sub sample for var1
        idx_samp = find(sites(:,num_s) & var1);
        idx_samp = idx_samp(randperm(length(idx_samp)));
        subsamp1(idx_samp(1:n_sub1)) = 1;

        % Selectect a sub sample for var2
        idx_samp = find(sites(:,num_s) & var2);
        idx_samp = idx_samp(randperm(length(idx_samp)));
        subsamp2(idx_samp(1:n_sub2)) = 1;
   end
        
end
