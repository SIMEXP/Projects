
clear

warning('This script will generate a lot of results in the current folder. Press CTRL-C now to interrupt !')
pause

%% Set up paths
path_curr = pwd;
path_roi  = [path_curr filesep 'rois']; % Where to save the real regional time series
path_out  = [path_curr filesep 'xp_2014_11_27b']; % Where to store the results of the simulation
path_logs = [path_out filesep 'logs']; % Where to save the logs of the pipeline
psom_mkdir(path_out);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Download the ICBM aging functional connectomes - time series %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~psom_exist(path_roi)
    mkdir(path_roi)
    cd(path_roi)
    fprintf('Could not find the aging time series. Downloading from figshare ...\n')
    instr_dwnld = 'wget http://downloads.figshare.com/article/public/1241650';
    [status,msg] = system(instr_dwnld);
    if status~=0
        psom_clean(path_roi)
        error('Could not download the necessary data from figshare. The command was: %s. The error message was: %s',instr_dwnld,msg);
    end
    instr_unzip = 'unzip 1241650';
    [status,msg] = system(instr_unzip);
    if status~=0
        psom_clean(path_roi)
        error('Could not unzip the necessary data. The command was: %s. The error message was: %s',instr_unzip,msg);
    end
    psom_clean('1241650');
    cd(path_curr)
end

%% Read the demographics data
[tab,list_subject,ly] = niak_read_csv([path_roi filesep 'aging_full_model.csv']);
age = tab(:,2);

%% Read connectoms
for ss = 1:length(list_subject)
    file_conn = [path_roi filesep 'correlation_' list_subject{ss} '_roi.mat'];
    data = load(file_conn);
    if ss == 1
        conn = zeros(length(list_subject),length(data.mat_r));
    end
    R = data.mat_r;
    R = (R-median(R))/niak_mad(R);    
    conn(ss,:) = R;
end

%% Just simple t-stats
exp = [ones(length(age),1) age];
x = exp;
x(:,2) = niak_normalize_tseries(exp(:,2));
[beta,e,std_e,ttest,pce] = niak_lse(conn,x,[0;1]);
[fdr,sig] = niak_fdr(pce','BH',0.05);
fprintf('Max ttest: %1.2f\n',max(ttest));
fprintf('Percentage of discovery: %1.2f\n',sum(sig)/length(sig));
opt_v.limits = [-0.5 0.5];
niak_visu_matrix(beta(2,:)',opt_v)

%% Build a brain parcellation
K = 30;
R = niak_build_correlation(niak_vec2mat(ttest')); % Compute the similarity matrix between effect maps
hier = niak_hierarchical_clustering(R,struct('flag_verbose',false));
part = niak_threshold_hierarchy(hier,struct('thresh',K));
    
%% Build connectomes at the new resolution
avg_conn_all = zeros(length(list_subject)-1,K*(K-1)/2);
for ss2 = 1:length(list_subject)
    avg_conn_all(ss2,:) = niak_build_avg_sim(niak_vec2mat(conn(ss2,:)),part,true);
end

%% Now try to predict age
list_c = 2.^(-7:2:10);
list_g = 2.^(-10:2:5);
n = 8;
age_hat = zeros(length(list_subject),1);

for ss = 1:length(list_subject) % Leave-one out cross-validation
%for ss = 1:10 % Leave-one out cross-validation
    % Verbose progress
    niak_progress(ss,length(list_subject));
    
    % Create a logical mask for the leave-one-out
    mask = true(size(age));
    mask(ss) = false;
    
    % Rank connections   
    [brank,erank,std_erank,ttest_rank,pce_rank] = niak_lse(avg_conn_all(mask,:),x,[0;1]);
    [val,order] = sort(abs(ttest_rank),'descend');
    
    % Normalize the low-resolution connectomes (not using the test data)
    avg_conn = avg_conn_all(:,order(1:n));
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