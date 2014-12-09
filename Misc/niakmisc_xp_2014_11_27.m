
clear
opt_glm.test = 'ttest';

%% Load raw data
load glm_ctrlvsmci_sci50_scg50_scf50.mat
model = multisite.model(1);
[hdr,sc] = niak_read_vol('networks_sci50_scg50_scf50.nii.gz');

%% Get rid of AD_CRIUGM's data
ad_criugm = niak_find_str_cell(model.labels_x,'ad_hc');
model.x = model.x(~ad_criugm,:);
%model.y = model.y(~ad_criugm,:);
model.y = niak_normalize_tseries(model.y(~ad_criugm,:)','median_mad')';
model.c = model.c;
model.labels_x = model.labels_x(~ad_criugm);
model.labels_y = model.labels_y;

%% Make masks per site
mni_mci = niak_find_str_cell(model.labels_x,'ad_');
criugm_mci = niak_find_str_cell(model.labels_x,'SB_');
adpd = niak_find_str_cell(model.labels_x,'AD');

%% Extract submodels: mni_mci
model_metal(1).x = model.x(mni_mci,:);
model_metal(1).y = model.y(mni_mci,:);
model_metal(1).c = model.c;
model_metal(1).labels_x = model.labels_x(mni_mci);
model_metal(1).labels_y = model.labels_y;

%% Extract submodels: criugm_mci
model_metal(2).x = model.x(criugm_mci,:);
model_metal(2).y = model.y(criugm_mci,:);
model_metal(2).c = model.c;
model_metal(2).labels_x = model.labels_x(criugm_mci);
model_metal(2).labels_y = model.labels_y;

%% Extract submodels: adpd
model_metal(3).x = model.x(adpd,:);
model_metal(3).y = model.y(adpd,:);
model_metal(3).c = model.c;
model_metal(3).labels_x = model.labels_x(adpd);
model_metal(3).labels_y = model.labels_y;

%% Extract submodels: adni2
model_metal(4) = multisite.model(2);

%% Build connectomes
conn = [];
exp = [];
for num_m = 1:length(model_metal)
    conn = [conn ; niak_normalize_tseries(model_metal(num_m).y')'];
    exp = [exp ; [ones(size(model_metal(num_m).x,1),1) (model_metal(num_m).x(:,2)==max(model_metal(num_m).x(:,2)))]];    
end

%% Just simple t-stats
x = exp;
x(:,2) = niak_normalize_tseries(exp(:,2));
[beta,e,std_e,ttest,pce] = niak_lse(conn,x,[0;1]);
[fdr,sig] = niak_fdr(pce','BH',0.05);
fprintf('Max ttest: %1.2f\n',max(ttest));
fprintf('Percentage of discovery: %1.2f\n',sum(sig)/length(sig));
opt_v.limits = [-0.5 0.5];
niak_visu_matrix(beta(2,:)',opt_v)

%% Now try to predict age
list_subject = cell(size(conn,1),1);
list_c = 2.^(-7:2:10);
list_g = 2.^(-10:2:5);
K = 10;
n = 8;
age_hat = zeros(length(list_subject),1);
age = exp(:,2);
for ss = 1:length(list_subject) % Leave-one out cross-validation
%for ss = 1:10 % Leave-one out cross-validation
    % Verbose progress
    niak_progress(ss,length(list_subject));
    
    % Create a logical mask for the leave-one-out
    mask = true(size(age));
    mask(ss) = false;
    
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
    
    % Normalize the low-resolution connectomes (not using the test data)
    avg_conn = avg_conn(:,order(1:n));
    m_avg_conn = mean(avg_conn(mask,:),1);
    s_avg_conn = std(avg_conn(mask,:),[],1);
    avg_conn = (avg_conn - ones(length(list_subject),1)*m_avg_conn)./repmat(s_avg_conn,[length(list_subject),1]);
    
    % a simple regression model
    beta_age = niak_lse(x(:,2),[ones(length(list_subject)-1,1) avg_conn(mask,:)]);
    age_hat(ss) = [1 avg_conn(ss,:)]*beta_age;
    
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