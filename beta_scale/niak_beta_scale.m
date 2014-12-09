function res = niak_beta_scale(model,opt)

%% Setting up defaults for MODEL
model = psom_struct_defaults( model , ...
        { 'x' , 'y' , 'c' } , ...
        { NaN , NaN , NaN } );
        
%% Setting up defaults for OPT 
opt = psom_struct_defaults ( opt , ...
      { 'type_normalize' , 'nb_samps' , 'perc' , 'nb_clusters' , 'nb_features' } , ...
      { 'median_mad'     , 100        , 50     , 30            , 10            } );
      
%% Normalize connectomes
if ~strcmp(opt.type_normalize)
    model.y = niak_normalize_tseries(model.y',opt.type_normalize)';
end

%% Extract variable of interest 
if sum(model.c>0)>1
    error('Only a contrast on one variable is supported')
end
var_to_predict = model.x(:,model.c>0);

%% Run the estimation
nb_samps_age = zeros(size(age));
nb_samps = 40;
for ss = 1:nb_samps % Leave-one out cross-validation
%for ss = 1:10 % Leave-one out cross-validation
    % Verbose progress
    niak_progress(ss,nb_samps);
    
    % Create a logical mask for the leave-one-out
    mask = false(size(age));
    mask(1:ceil(perc*length(list_subject))) = true;
    mask = mask(randperm(length(mask)));
    
    % Extract the data, excluding one subject
    y = conn(mask,:);
    x = exp(mask,:);
    
    % Run a BASC-GLM analysis
    [beta,e,std_e,ttest,pce] = niak_lse(y,x,[0;1]); 
    R = niak_build_correlation(niak_vec2mat(ttest')); % Compute the similarity matrix between effect maps
    hier = niak_hierarchical_clustering(R,struct('flag_verbose',false));
    part = niak_threshold_hierarchy(hier,struct('thresh',K));
    
    % Generate connectomes at the new resolution
    avg_conn = zeros(length(list_subject)-1,K*(K-1)/2);
    for ss2 = 1:length(list_subject)
        avg_conn(ss2,:) = niak_build_avg_sim(niak_vec2mat(conn(ss2,:)),part,true);
    end

    % Rank connections   
    [brank,erank,std_erank,ttest_rank,pce_rank] = niak_lse(avg_conn(mask,:),x,[0;1]);
    [val,order] = sort(abs(ttest_rank),'descend');
    
    % Run a stability analysis
    if ss == 1
        stab = zeros(length(part),length(part));
    end
    tmp = zeros(size(ttest_rank));
    tmp(order(1:n)) = 1;
    tmp = niak_vec2mat(tmp,0);
    [indx,indy] = find(tmp);
    adj = zeros(size(stab));
    for num_i = 1:length(indx)
        adj(part==indx(num_i),part==indy(num_i)) = 1;
    end
    stab = stab + adj;
    
    % Normalize the low-resolution connectomes (not using the test data)
    avg_conn = avg_conn(:,order(1:n));
    m_avg_conn = mean(avg_conn(mask,:),1);
    s_avg_conn = std(avg_conn(mask,:),[],1);
    avg_conn = (avg_conn - ones(length(list_subject),1)*m_avg_conn)./repmat(s_avg_conn,[length(list_subject),1]);
    
    % a simple regression model
    beta_age = niak_lse(x(:,2),[ones(sum(mask),1) avg_conn(mask,:)]);
    age_hat(~mask) = age_hat(~mask) + [ones(sum(~mask),1) avg_conn(~mask,:)]*beta_age;
    nb_samps_age(~mask) = nb_samps_age(~mask)+1;
%      % a SVM prediction
%      score = zeros(length(list_c),length(list_g));
%      samp = [ones(length(list_subject)-1,1) avg_conn(mask,:)];
%      for num_c = 1:length(list_c)
%          for num_g = 1:length(list_g)
%              for ss2 = 1:(length(list_subject)-2) %% Nested cross-validation
%                  mask2 = true(length(list_subject)-1,1);
%                  mask2(ss2) = false;
%                  model_svm = svmtrain(x(mask2,2),samp(mask2,:),sprintf('-s 3 -t 2 -c %1.10f -g %1.10f',list_c(num_c),list_g(num_g)));
%                  val_pred = svmpredict(x(ss2,2),samp(ss2,:),model_svm);
%                  score(num_c,num_g) = score(num_c,num_g) + (val_pred-x(ss2,2))^2;
%               end
%               score(num_c,num_g) = sqrt(score(num_c,num_g)/(length(list_subject)-2));
%          end
%      end
%      [score_min,ind] = min(score(:));
%      [ind_c,ind_g] = ind2sub(size(score),ind);
%      model_svm = svmtrain(x(:,2),samp,sprintf('-s 3 -t 2 -c %1.10f -g %1.10f',list_c(ind_c),list_g(ind_g)));
%      age_hat(ss) = svmpredict(exp(ss,2),[1 avg_conn(ss,:)],model_svm);
end
stab = stab / nb_samps;
R = niak_build_correlation(stab);
hier_stab = niak_hierarchical_clustering (R);
order_stab = niak_hier2order (hier_stab);
beta = niak_vec2mat(beta(2,:));
niak_visu_matrix(beta(order_stab,order_stab),opt_v)
figure
niak_visu_matrix(stab(order_stab,order_stab))
age_hat = age_hat./nb_samps_age;