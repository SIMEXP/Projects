function [files_in,files_out,opt] = brick_simu_power(files_in,files_out,opt)
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
%   EFFECT_SIZE
%      (scalar, default 0.1) the effect size in the simulation
%
%   FLAG_TEST
%      (boolean, default false) if the FLAG is true, do not do 
%      anything. Just update the default values. 
%       


%% Default options

list_fields   = { 'rand_seed' , 'threshold_p' , 'nb_samps' , 'effect_size' , 'flag_test' , 'seed_std'};
list_defaults = { []          , 0.05          , 1000       , 0.1           , false       , []};
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
multisite = find(sum(X(:,2:end),2));
%fake_multisite = find(X(:,end)==1);
if(isempty(opt.seed_std))
    %     for num_c = 1:nb_conn
%         std_multisite(num_c) = std(Y(:,num_c));
%         %std_fake_multisite(num_c) = std(Y(fake_multisite,num_c));
%     end
    
else
    std_multisite = opt.seed_std;
end



%% Run the simulation for multisite
opt_glm.test = 'ttest';
sens = zeros(1,nb_conn);
for num_samp = 1:opt.nb_samps
    patho = zeros(size(X,1),1);
    Y_samp = Y;
    samp_site = multisite(randperm(length(multisite)));
    samp_site = samp_site(1:floor(length(samp_site)/2));
    for num_c = 1:nb_conn
        Y_samp(samp_site,num_c) = Y_samp(samp_site,num_c) + opt.effect_size * std_multisite(num_c);
    end
    patho(samp_site) = 1;
    
    glm.x = [X(multisite,2:end) patho(multisite)];
    %glm.x = [ones(length(patho(multisite)),1) patho(multisite)];
    glm.y = Y_samp(multisite,:);
    glm.c = [zeros(1,size(X(multisite,2:end),2)) 1]';
    %glm.c = [0 1]';
    res_test = niak_glm(glm,opt_glm);
    sens = sens + (res_test.pce<opt.threshold_p);
end
sens_multisite = sens/opt.nb_samps;

% %% Run the simulation for Fake multisite (single site)
% opt_glm.test = 'ttest';
% sens = zeros(1,nb_conn);
% for num_samp = 1:opt.nb_samps
%     patho = zeros(size(X,1),1);
%     Y_samp = Y;
%     samp_site = fake_multisite(randperm(length(fake_multisite)));
%     samp_site = samp_site(1:floor(length(samp_site)/2));
%     for num_c = 1:nb_conn
%         Y_samp(samp_site,num_c) = Y_samp(samp_site,num_c) + opt.effect_size * std_multisite(num_c);
%     end
%     patho(samp_site) = 1;
%     
%     glm.x = [X(fake_multisite,end-1) patho(fake_multisite)];
%     glm.y = Y_samp(fake_multisite,:);
%     glm.c = [zeros(1,size(X(fake_multisite,end-1),2)) 1]';
%     res_test = niak_glm(glm,opt_glm);
%     sens = sens + (res_test.pce<opt.threshold_p);
% end
% sens_fake_multisite = sens/opt.nb_samps;


% %% Run the simulation various population size in Fake multisite (single site)
% opt_glm.test = 'ttest';
% sens = zeros(1,nb_conn);
% label_popu_size_fake_multisite=[];
% k=0;
% for popu_size = 10:10:length(fake_multisite)
%     k=k+1;
%     sens = zeros(1,nb_conn);
%     for num_samp = 1:opt.nb_samps
%         % Random selection of the polpulation for a specific size
%         primary_selection_site = fake_multisite(randperm(length(fake_multisite)));
%         fake_multisite_sub = primary_selection_site(1:popu_size);
%         
%         patho = zeros(size(X,1),1);
%         Y_samp = Y;
%         
%         samp_site = fake_multisite_sub(randperm(length(fake_multisite_sub)));
%         samp_site = samp_site(1:floor(length(samp_site)/2));
%         for num_c = 1:nb_conn
%             Y_samp(samp_site,num_c) = Y_samp(samp_site,num_c) + opt.effect_size * std_multisite(num_c);
%         end
%         patho(samp_site) = 1;
% 
%         glm.x = [X(fake_multisite_sub,end-1) patho(fake_multisite_sub)];
%         glm.y = Y_samp(fake_multisite_sub,:);
%         glm.c = [zeros(1,size(X(fake_multisite_sub,end-1),2)) 1]';
%         res_test = niak_glm(glm,opt_glm);
%         sens = sens + (res_test.pce<opt.threshold_p);
%     end
%     sens_popu_size_fake_multisite(k,:) = sens/opt.nb_samps;
%     label_popu_size_fake_multisite{k} = ['nSubjects' int2str(popu_size)];
%     nsubjects(k) = popu_size; 
% end


%% Save results
nb_samps = opt.nb_samps;
%save(files_out,'sens_multisite','sens_fake_multisite','sens_popu_size_fake_multisite','label_popu_size_fake_multisite','nb_samps','nsubjects')
save(files_out,'sens_multisite','nb_samps','nsubjects')
