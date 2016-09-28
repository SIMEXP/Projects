function [files_in,files_out,opt] = multisite_brick_simu_power_prediction(files_in,files_out,opt)
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

list_fields   = { 'force_balance', 'rand_seed' , 'pi_1' , 'nb_samps' , 'effect_size' , 'flag_test' , 'seed_std', 'alpha', 'n_subjects', 'rnd_sampling','patho_site_bias'};
list_defaults = { []             ,  []         , 0.01          , 1000       , 0.1           , false       , []        ,  0.5   , 120         , false, false};
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
    %for num_c = 1:nb_conn
        %std_multisite(num_c) = std(Y(:,num_c));
    std_monosite = std(Y(monosite,:));
    %end
    std_multisite = std_monosite;
else
    std_multisite = opt.seed_std;
end

%% Run the simulation for monosite (single site gold standard)
opt_glm.test = 'ttest';
opt_glm.flag_residuals=true;
opt_glm.flag_beta = true;
sens = []%zeros(1,nb_conn);
sens_nullh = []%zeros(1,nb_conn);
for num_samp = 1:opt.nb_samps
    
    patho = zeros(size(X,1),1);
    Y_samp = Y;
    % random asignment
    patho_ratio = alpha;
    [samp_site,ctrl_samp,test_samp,test_ctrl] = sub_samp_sites(monosite,X(:,2),alpha,n_subjects,opt.rnd_sampling);
    
    selection = [samp_site;ctrl_samp];
    
    idx_affected = randi(size(Y_samp,2)-1,ceil(size(Y_samp,2)*opt.pi_1),1);

    Y_samp([samp_site;test_samp],idx_affected) = Y_samp([samp_site;test_samp],idx_affected) + opt.effect_size .* std_multisite(idx_affected);
    %for num_c = 1:nb_conn
    %    Y_samp(samp_site,num_c) = Y_samp(samp_site,num_c) + opt.effect_size * std_multisite(num_c);
    %end
    patho(samp_site) = 1;
    glm.x = [X(selection,[1,3,4])];%patho(selection)];
    glm.x = niak_normalize_tseries(glm.x,'mean');
    glm.x = [ones(length(patho(selection)),1)  glm.x]; % add intercept
    glm.y = Y_samp(selection,:);
    glm.c = [zeros(1,size(glm.x,2)-1) 1]';
    res_test = niak_glm(glm,opt_glm);

    %Training 
    [best_acc, best_model]=grid_search(res_test.e,patho(selection),-3,0,.05);

    %Test
    patho = zeros(size(X,1),1);
    selection = [test_samp;test_ctrl];
    patho(test_samp) = 1;
    glm.x = [X(selection,[1,3,4])];%patho(selection)];
    glm.x = niak_normalize_tseries(glm.x,'mean');
    glm.x = [ones(length(patho(selection)),1)  glm.x]; % add intercept
    glm.y = Y_samp(selection,:);

    dataY = glm.y - glm.x*res_test.beta;
    [predict_label_L, accuracy_L, dec_values_L] = svmpredict(patho(selection), dataY, best_model);
    sens = [sens,accuracy_L(1)/100];
    %sens = sens + (res_test.pce<=opt.threshold_p);
    null_patho = patho(selection)(randperm(length(patho(selection))));
    [predict_label_L, accuracy_L, dec_values_L] = svmpredict(null_patho, dataY, best_model);
    sens_nullh =[sens_nullh,accuracy_L(1)/100];
end
sens_monosite = sens;
sens_monosite_h0 = sens_nullh;

%% Run the simulation for multisite (no correction)
opt_glm.test = 'ttest';
sens = [];
sens_nullh = [];
for num_samp = 1:opt.nb_samps
    patho = zeros(size(X,1),1);
    Y_samp = Y;
    [samp_site,ctrl_samp,test_samp,test_ctrl] = sub_samp_sites(multisite,X(:,2),alpha,n_subjects,opt.rnd_sampling);
    selection = [samp_site;ctrl_samp];

    idx_affected = randi(size(Y_samp,2)-1,ceil(size(Y_samp,2)*opt.pi_1),1);

    %for num_c = 1:nb_conn
    Y_samp([samp_site;test_samp],idx_affected) = sub_add_effect(Y_samp(:,idx_affected), [samp_site;test_samp], opt.effect_size, std_multisite(idx_affected), X(:,2), opt.patho_site_bias);
    %end
    patho(samp_site) = 1;
    
    glm.x = [X(selection,[1,3,4])];
    glm.x = niak_normalize_tseries(glm.x,'mean');
    glm.x = [ones(length(patho(selection)),1)  glm.x]; % add intercept
    glm.y = Y_samp(selection,:);
    glm.c = [zeros(1,size(glm.x,2)-1) 1]';
    %glm.c = [0 1]';
    res_test = niak_glm(glm,opt_glm);

    %Training 
    [best_acc, best_model]=grid_search(res_test.e,patho(selection),-3,0,.05);

    %Test
    patho = zeros(size(X,1),1);
    selection = [test_samp;test_ctrl];
    patho(test_samp) = 1;
    glm.x = [X(selection,[1,3,4])];%patho(selection)];
    glm.x = niak_normalize_tseries(glm.x,'mean');
    glm.x = [ones(length(patho(selection)),1)  glm.x]; % add intercept
    glm.y = Y_samp(selection,:);

    dataY = glm.y - glm.x*res_test.beta;
    [predict_label_L, accuracy_L, dec_values_L] = svmpredict(patho(selection), dataY, best_model);
    sens = [sens,accuracy_L(1)/100];

    null_patho = patho(selection)(randperm(length(patho(selection))));
    [predict_label_L, accuracy_L, dec_values_L] = svmpredict(null_patho, dataY, best_model);
    sens_nullh =[sens_nullh,accuracy_L(1)/100];

end
sens_multisite_nocorr = sens;
sens_multisite_h0 = sens_nullh;

%% Run the simulation for multisite (correction with dummy variables)
opt_glm.test = 'ttest';
sens = [];
sens_nullh = [];
for num_samp = 1:opt.nb_samps
    patho = zeros(size(X,1),1);
    Y_samp = Y;
    [samp_site,ctrl_samp,test_samp,test_ctrl] = sub_samp_sites(multisite,X(:,2),alpha,n_subjects,opt.rnd_sampling);
    selection = [samp_site;ctrl_samp];

    idx_affected = randi(size(Y_samp,2)-1,ceil(size(Y_samp,2)*opt.pi_1),1);

    %for num_c = 1:nb_conn
    Y_samp([samp_site;test_samp],idx_affected) = sub_add_effect(Y_samp(:,idx_affected), [samp_site;test_samp], opt.effect_size, std_multisite(idx_affected), X(:,2), opt.patho_site_bias);
    %end
    patho(samp_site) = 1;
 
    dummyvar = sub_create_dummyvar(X(selection,2));
    glm.x = [X(selection,[1,3,4]), dummyvar];
    glm.x = niak_normalize_tseries(glm.x,'mean');
    glm.x = [ones(length(patho(selection)),1)  glm.x]; % add intercept
    glm.y = Y_samp(selection,:);
    glm.c = [zeros(1,size(glm.x,2)-1) 1]';
    %glm.c = [0 1]';
    res_test = niak_glm(glm,opt_glm);

    %Training 
    [best_acc, best_model]=grid_search(res_test.e,patho(selection),-3,0,.05);
    
    %Test
    patho = zeros(size(X,1),1);
    selection = [test_samp;test_ctrl];
    dummyvar = sub_create_dummyvar(X(selection,2));
    patho(test_samp) = 1;
    glm.x = [X(selection,[1,3,4]),dummyvar];
    glm.x = niak_normalize_tseries(glm.x,'mean');
    glm.x = [ones(length(patho(selection)),1)  glm.x]; % add intercept
    glm.y = Y_samp(selection,:);

    dataY = glm.y - glm.x*res_test.beta;
    [predict_label_L, accuracy_L, dec_values_L] = svmpredict(patho(selection), dataY, best_model);
    sens = [sens,accuracy_L(1)/100];

    null_patho = patho(selection)(randperm(length(patho(selection))));
    [predict_label_L, accuracy_L, dec_values_L] = svmpredict(null_patho, dataY, best_model);
    sens_nullh =[sens_nullh,accuracy_L(1)/100];

end
sens_multisite_dummyvar = sens;
sens_multisite_h0_dummy = sens_nullh;

sens_multisite_metal = zeros(size(sens_multisite_dummyvar))
sens_multisite_h0_metal = zeros(size(sens_multisite_dummyvar));
 

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

function [samp_site,ctrl_samp,test_samp,test_ctrl] = sub_samp_sites(multisiteidx,siteids,alpha,n_subjects,rnd_samp)
    
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

    test_selection = multisiteidx(~ismember(multisiteidx,[samp_site;ctrl_samp]));
    test_selection = test_selection(randperm(length(test_selection),147-length([samp_site;ctrl_samp])));
    idx_2cut = floor(length(test_selection)*patho_ratio);
    test_samp = test_selection(1:idx_2cut);
    test_ctrl = test_selection(idx_2cut:end);

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
      result(ids,:) = Y_samp(ids,:) + ((effect_size + r) .* std_multisite);
   end
   % only take the selected subjects
   result = result(samp_site,:);
end

function [best_acc, best_model]=grid_search(data,labels,g_min,g_max,step)
    grid_param = (10^g_min):(10^step):(10^g_max);
    best_acc=0;
    for i=1:length(grid_param)
        accuracy_L = svmtrain(labels, data, ['-q -t 0 -v 10 -c ' num2str(grid_param(i))]);
        %[predict_label_L, accuracy_L, dec_values_L] = svmpredict(test_label, labels, data, model_linear);
        if accuracy_L > best_acc
            best_acc = accuracy_L;
            best_model = svmtrain(labels, data, ['-q -t 0 -c ' num2str(grid_param(i))]);
        end
    end
end

