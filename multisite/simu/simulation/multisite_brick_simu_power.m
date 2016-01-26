function [files_in,files_out,opt] = multisite_brick_simu_power(files_in,files_out,opt)
% FILES_IN
%   (string) the name of a mat file with the Y/X variables
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
%   ALPHA
%      (double (between 0 and 1), default 0.5)  
%      percentage for balancing sample. 
% 
%   EFFECT_SIZE
%      (scalar, default 0.1) the effect size in the simulation
%
%   FLAG_TEST
%      (boolean, default false) if the FLAG is true, do not do 
%      anything. Just update the default values. 
%       


%% Default options

list_fields   = { 'force_balance', 'rand_seed' , 'threshold_p' , 'nb_samps' , 'effect_size' , 'flag_test' , 'seed_std', 'alpha', 'n_subjects', 'rnd_sampling','patho_site_bias'};
list_defaults = { []             ,  []         , 0.05          , 1000       , 0.1           , false       , []        ,  0.5   , 148         , false, false};
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
data = load(files_in);
X = data.X;
Y = data.Y;
label_covar = data.label_covar;
nb_site = length(label_covar)-1;
nb_conn = size(Y,2);

if size(opt.force_balance,2)>0
   alpha = opt.force_balance;
else
   alpha = opt.alpha;
end
n_subjects = opt.n_subjects;

%% Estimate intra-site std 
% std_site = zeros(nb_site,nb_conn);
% ind_site = cell(nb_site);
% for num_s = 1:nb_site
%     ind_site{num_s} = find(X(:,num_s)==1);
%     for num_c = 1:nb_conn
%         std_site(num_s,num_c) = std(Y(ind_site{num_s},num_c));
%     end
% end

% Estimate global-site std 
monosite = find(X(:,2)==3);
%monosite = monosite(1:n_subjects); %tmp to force the number of subject in monosite
multisite = find(~(X(:,2)==3));
%multisite = multisite(1:n_subjects);
if(isempty(opt.seed_std))
    for num_c = 1:nb_conn
        %std_multisite(num_c) = std(Y(:,num_c));
        std_monosite(num_c) = std(Y(monosite,num_c));
    end
    std_multisite = std_monosite;
else
    std_multisite = opt.seed_std;
end

%% Run the simulation for monosite (single site gold standard)
opt_glm.test = 'ttest';
sens = zeros(1,nb_conn);
sens_nullh = zeros(1,nb_conn);
for num_samp = 1:opt.nb_samps
    
    patho = zeros(size(X,1),1);
    Y_samp = Y;
    % random asignment
    patho_ratio = alpha;
    [samp_site,ctrl_samp] = sub_samp_sites(monosite,X(:,2),alpha,n_subjects,opt.rnd_sampling);
    
    selection = [samp_site;ctrl_samp];
    for num_c = 1:nb_conn
        Y_samp(samp_site,num_c) = Y_samp(samp_site,num_c) + opt.effect_size * std_multisite(num_c);
    end
    patho(samp_site) = 1;
    glm.x = [X(selection,[1,3,4]) patho(selection)];
    glm.x = niak_normalize_tseries(glm.x,'mean');
    glm.x = [ones(length(patho(selection)),1)  glm.x]; % add intercept
    glm.y = Y_samp(selection,:);
    glm.c = [zeros(1,size(glm.x,2)-1) 1]';
    res_test = niak_glm(glm,opt_glm);
    sens = sens + (res_test.pce<=opt.threshold_p);
    glm.y = Y(selection,:);
    sens_nullh = sens_nullh + sub_nullh(glm,opt_glm,opt.threshold_p,false);

end
sens_monosite = sens/opt.nb_samps;
sens_monosite_h0 = sens_nullh/opt.nb_samps;

%% Run the simulation for multisite (no correction)
opt_glm.test = 'ttest';
sens = zeros(1,nb_conn);
sens_nullh = zeros(1,nb_conn);
for num_samp = 1:opt.nb_samps
    patho = zeros(size(X,1),1);
    Y_samp = Y;
    [samp_site,ctrl_samp] = sub_samp_sites(multisite,X(:,2),alpha,n_subjects,opt.rnd_sampling);
    selection = [samp_site;ctrl_samp];
    for num_c = 1:nb_conn
        Y_samp(samp_site,num_c) = sub_add_effect(Y_samp(:,num_c), samp_site, opt.effect_size, std_multisite(num_c), X(:,2), opt.patho_site_bias);
        %Y_samp(samp_site,num_c) = sub_add_effect(Y_samp(samp_site,num_c) + opt.effect_size * std_multisite(num_c);
    end
    patho(samp_site) = 1;
    
    glm.x = [X(selection,[1,3,4]) patho(selection)];
    glm.x = niak_normalize_tseries(glm.x,'mean');
    glm.x = [ones(length(patho(selection)),1)  glm.x]; % add intercept
    glm.y = Y_samp(selection,:);
    glm.c = [zeros(1,size(glm.x,2)-1) 1]';
    %glm.c = [0 1]';
    res_test = niak_glm(glm,opt_glm);
    sens = sens + (res_test.pce<=opt.threshold_p);
    Y_samp = Y;
    for num_c = 1:nb_conn
        Y_samp(samp_site,num_c) = sub_add_effect(Y_samp(:,num_c), samp_site, 0, std_multisite(num_c), X(:,2), opt.patho_site_bias);
    end
    glm.y = Y_samp(selection,:);
    sens_nullh = sens_nullh + sub_nullh(glm,opt_glm,opt.threshold_p,false);
end
sens_multisite_nocorr = sens/opt.nb_samps;
sens_multisite_h0 = sens_nullh/opt.nb_samps;

%% Run the simulation for multisite (correction with dummy variables)
opt_glm.test = 'ttest';
sens = zeros(1,nb_conn);
sens_nullh = zeros(1,nb_conn);
for num_samp = 1:opt.nb_samps
    patho = zeros(size(X,1),1);
    Y_samp = Y;
    [samp_site,ctrl_samp] = sub_samp_sites(multisite,X(:,2),alpha,n_subjects,opt.rnd_sampling);
    selection = [samp_site;ctrl_samp];
    for num_c = 1:nb_conn
        Y_samp(samp_site,num_c) = sub_add_effect(Y_samp(:,num_c), samp_site, opt.effect_size, std_multisite(num_c), X(:,2), opt.patho_site_bias);
        %Y_samp(samp_site,num_c) = Y_samp(samp_site,num_c) + opt.effect_size * std_multisite(num_c);
    end
    patho(samp_site) = 1;
    
    dummyvar = sub_create_dummyvar(X(selection,2));
    glm.x = [X(selection,[1,3,4]), dummyvar ,patho(selection)];
    glm.x = niak_normalize_tseries(glm.x,'mean');
    glm.x = [ones(length(patho(selection)),1)  glm.x]; % add intercept
    glm.y = Y_samp(selection,:);
    glm.c = [zeros(1,size(glm.x,2)-1) 1]';
    res_test = niak_glm(glm,opt_glm);
    sens = sens + (res_test.pce<=opt.threshold_p);
    Y_samp = Y;
    for num_c = 1:nb_conn
        Y_samp(samp_site,num_c) = sub_add_effect(Y_samp(:,num_c), samp_site, 0, std_multisite(num_c), X(:,2), opt.patho_site_bias);
    end
    glm.y = Y_samp(selection,:);
    sens_nullh = sens_nullh + sub_nullh(glm,opt_glm,opt.threshold_p,false);
end
sens_multisite_dummyvar = sens/opt.nb_samps;
sens_multisite_h0_dummy = sens_nullh/opt.nb_samps;

if ~opt.rnd_sampling
%% Run the simulation for multisite (with correction METAL)
opt_glm.test = 'ttest';
sens = zeros(1,nb_conn);
sens_nullh = zeros(1,nb_conn);
for num_samp = 1:opt.nb_samps
    patho = zeros(size(X,1),1);
    Y_samp = Y;
    [samp_site,ctrl_samp] = sub_samp_sites(multisite,X(:,2),alpha,n_subjects,opt.rnd_sampling);
    selection = [samp_site;ctrl_samp];
    for num_c = 1:nb_conn
        Y_samp(samp_site,num_c) = sub_add_effect(Y_samp(:,num_c), samp_site, opt.effect_size, std_multisite(num_c), X(:,2), opt.patho_site_bias);
        %Y_samp(samp_site,num_c) = Y_samp(samp_site,num_c) + opt.effect_size * std_multisite(num_c);
    end
    patho(samp_site) = 1;
    
    glm.x = [X(selection,[1,3,4]) patho(selection)];
    %glm.x = niak_normalize_tseries(glm.x,'mean'); %this is done in the
    %glm_multisite
    %glm.x = [ones(length(patho(multisite)),1)  glm.x]; % add intercept
    glm.y = Y_samp(selection,:);
    glm.c = [zeros(1,size(glm.x,2)-1) 1]';
    opt_glm.multisite = X(selection,2);

    [results, opt_glm]=niak_glm_multisite(glm,opt_glm);  
    pce = results.pce;
    
    %[fdr,test] = niak_fdr(pce(mask_apriori),'BH',opt.q);
    test = pce <= opt.threshold_p;
    sens = sens + test;
    Y_samp = Y;
    for num_c = 1:nb_conn
        Y_samp(samp_site,num_c) = sub_add_effect(Y_samp(:,num_c), samp_site, 0, std_multisite(num_c), X(:,2), opt.patho_site_bias);
    end
    glm.y = Y_samp(selection,:);
    sens_nullh = sens_nullh + sub_nullh(glm,opt_glm,opt.threshold_p,true);
    
    
end
sens_multisite_metal = sens/opt.nb_samps;
sens_multisite_h0_metal = sens_nullh/opt.nb_samps;
end 

%% Save results
nb_samps = opt.nb_samps;
if opt.rnd_sampling
	save(files_out,'sens_monosite_h0','sens_multisite_h0','sens_multisite_h0_dummy','sens_monosite','sens_multisite_nocorr','sens_multisite_dummyvar','nb_samps','n_subjects')
else
	save(files_out,'sens_monosite_h0','sens_multisite_h0','sens_multisite_h0_dummy','sens_multisite_h0_metal','sens_monosite','sens_multisite_nocorr','sens_multisite_dummyvar','sens_multisite_metal','nb_samps','n_subjects')
end
end

function nullh = sub_nullh(glm,opt_glm,thres, metal)

    %glm.x(:,logical(glm.c)) = niak_normalize_tseries(randi([0,1],size(glm.x,1),1),'mean');
    
    if metal
        [res_test , opt_glm] = niak_glm_multisite(glm,opt_glm);
    else
        
        res_test = niak_glm(glm,opt_glm);
    end
    
    nullh = (res_test.pce<=thres);
end

function [samp_site,ctrl_samp] = sub_samp_sites(multisiteidx,siteids,alpha,n_subjects,rnd_samp)
    
    samp_site=[];
    ctrl_samp =[];
    ids = unique(siteids(multisiteidx));
    if size(alpha,2)>1 && size(ids,1)>=size(alpha,2)
        ids = ids(randperm(length(ids)));
        ids = ids(1:size(alpha,2))
    	samp_ratio = n_subjects/sum(ismember(siteids,ids));
    else
        samp_ratio = n_subjects/length(multisiteidx);
    end

    if rnd_samp
        patho_ratio = alpha(1);
        sub_samp_site = multisiteidx(randperm(length(multisiteidx)));
        sub_samp_site = sub_samp_site(1:ceil(length(sub_samp_site)*samp_ratio));
        samp_site = [sub_samp_site(1:floor(length(sub_samp_site).*patho_ratio))];
        ctrl_samp = [sub_samp_site(~ismember(sub_samp_site,samp_site))];
    else

        k=false;
        for i=1:size(ids,1)
            if size(alpha,2)>1
                  patho_ratio = alpha(i);
            else
               % randomize the effect on each site 
               if randi([0,1],1,1)
                  patho_ratio = 1-alpha;
               else
                  patho_ratio = alpha;
               end
            end
            tmp_site = find(siteids == ids(i));

            sub_samp_site = tmp_site(randperm(length(tmp_site)));
            if k
                sub_samp_site = sub_samp_site(1:ceil(length(sub_samp_site)*samp_ratio));
                k=false;
            else
                sub_samp_site = sub_samp_site(1:floor(length(sub_samp_site)*samp_ratio));
                k=true;
            end
            if floor(length(sub_samp_site).*patho_ratio)<1
                samp_site = [samp_site ;sub_samp_site(1)];
            else
                samp_site = [samp_site ;sub_samp_site(1:floor(length(sub_samp_site).*patho_ratio))];
            end

            ctrl_samp = [ctrl_samp ;sub_samp_site(~ismember(sub_samp_site,samp_site))];
        end
    end
end

function dummyvar = sub_create_dummyvar(sites)
    % create dummy variables we need number of sites - 1 variables
    ids = unique(sites);
    for s=1:size(ids)-1
        dummyvar(:,s) = (sites == ids(s));
    end
    
end

function result = sub_add_effect(Y_samp,samp_site,effect_size, std_multisite,site_ids,patho_site_effect)
   
   result = Y_samp;
   site_labels = site_ids(samp_site);
   labels = unique(site_labels);
   for s=1:size(labels)
      r=0;
      if patho_site_effect
         %a = -0.5;
         %b = 0.5;
         %r = (b-a).*rand(1,1) + a;
	 r = normrnd(0,0.2);
      end
      ids = samp_site(site_labels==labels(s));
      result(ids) = Y_samp(ids) + (effect_size + r) * std_multisite;
   end
   % only take the selected subjects
   result = result(samp_site);
end
