
clear

warning('This script will generate a lot of results in the current folder. Press CTRL-C now to interrupt !')
pause

%% Set up paths
path_curr = pwd;
path_roi  = [path_curr filesep 'rois']; % Where to save the real regional time series
path_out  = [path_curr filesep 'xp_2014_11_15']; % Where to store the results of the simulation
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
bvol = tab(:,3);
csf = tab(:,4);
gm = tab(:,5);

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

%% Run SICA on connectomes
opt_s.type_nb_comp = 0;
opt_s.param_nb_comp = 20;
res_ica = niak_sica (conn,opt_s);

%% ICA-based prediction of age
age_hat = zeros(size(age));
list_c = 2.^(-7:2:10);
list_g = 2.^(-10:2:5);
K = 20;
n = 3;
age_hat = zeros(length(list_subject),1);
for ss = 1:length(list_subject) % Leave-one out cross-validation
%for ss = 1:10 % Leave-one out cross-validation
    % Verbose progress
    niak_progress(ss,length(list_subject));
    
    % Create a logical mask for the leave-one-out
    mask = true(size(age));
    mask(ss) = false;
    
    % Extract the data, excluding one subject
    y = res_ica.poids(mask,:);
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
    avg_conn = [avg_conn(:,order(1:n)) bvol csf gm];
    m_avg_conn = mean(avg_conn(mask,:),1);
    s_avg_conn = std(avg_conn(mask,:),[],1);
    avg_conn = (avg_conn - ones(length(list_subject),1)*m_avg_conn)./repmat(s_avg_conn,[length(list_subject),1]);
    
%      % a simple regression model
%      beta_age = niak_lse(x(:,2),[ones(length(list_subject)-1,1) avg_conn(mask,:)]);
%      age_hat(ss) = [1 avg_conn(ss,:)]*beta_age;
    
    % a SVM prediction
    score = zeros(length(list_c),length(list_g));
    samp = [ones(length(list_subject)-1,1) avg_conn(mask,:)];
    for num_c = 1:length(list_c)
        for num_g = 1:length(list_g)
            for ss2 = 1:(length(list_subject)-2) %% Nested cross-validation
                mask2 = true(length(list_subject)-1,1);
                mask2(ss2) = false;
                model_svm = svmtrain(x(mask2,2),samp(mask2,:),sprintf('-s 3 -t 2 -q -c %1.10f -g %1.10f',list_c(num_c),list_g(num_g)));
                val_pred = svmpredict(x(ss2,2),samp(ss2,:),model_svm);
                score(num_c,num_g) = score(num_c,num_g) + (val_pred-x(ss2,2))^2;
             end
             score(num_c,num_g) = sqrt(score(num_c,num_g)/(length(list_subject)-2));
        end
    end
    [score_min,ind] = min(score(:));
    [ind_c,ind_g] = ind2sub(size(score),ind);
    model_svm = svmtrain(x(:,2),samp,sprintf('-s 3 -t 2 -c %1.10f -g %1.10f',list_c(ind_c),list_g(ind_g)));
    age_hat(ss) = svmpredict(exp(ss,2),[1 avg_conn(ss,:)],model_svm);
end
plot(age_hat,age,'*')
corr(age_hat,age)


%% Now try to predict young vs old with a combination of functional connectivity and anatomy
list_c = 2.^(-7:2:10);
list_g = 2.^(-10:2:5);
K = 10;
n = 8;
group = zeros(size(age));
group(age<=35) = -1;
group(age>=60) = 1;
mask_g = group~=0;
group = group(mask_g);
conn = conn(mask_g,:);
bvol = bvol(mask_g);
csf = csf(mask_g);
gm = gm(mask_g);

for ss = 1:length(group) % Leave-one out cross-validation
%for ss = 1:10 % Leave-one out cross-validation
    % Verbose progress
    niak_progress(ss,length(group));
    
    % Create a logical mask for the leave-one-out
    mask = true(size(group));
    mask(ss) = false;
    
    % Extract the data, excluding one subject
    y = conn(mask,:);
    x = [ones(sum(mask),1) group(mask,:)];
    
    % Run a BASC-GLM analysis
    [beta,e,std_e,ttest,pce] = niak_lse(y,x,[0;1]); 
    R = niak_build_correlation(niak_vec2mat(ttest')); % Compute the similarity matrix between effect maps
    hier = niak_hierarchical_clustering(R,struct('flag_verbose',false));
    part = niak_threshold_hierarchy(hier,struct('thresh',K));
    
    % Generate connectomes at the new resolution
    avg_conn = zeros(length(group)-1,K*(K-1)/2);
    for ss2 = 1:length(group)
        avg_conn(ss2,:) = niak_build_avg_sim(niak_vec2mat(conn(ss2,:)),part,true);
    end

    % Rank connections   
    [brank,erank,std_erank,ttest_rank,pce_rank] = niak_lse(avg_conn(mask,:),x,[0;1]);
    [val,order] = sort(abs(ttest_rank),'descend');
    
    % Normalize the low-resolution connectomes (not using the test data)
    avg_conn = [avg_conn(:,order(1:n)) bvol csf gm];
    m_avg_conn = mean(avg_conn(mask,:),1);
    s_avg_conn = std(avg_conn(mask,:),[],1);
    avg_conn = (avg_conn - ones(length(group),1)*m_avg_conn)./repmat(s_avg_conn,[length(group),1]);
    
    % a simple regression model
    beta_group = niak_lse(x(:,2),[ones(length(group)-1,1) avg_conn(mask,:)]);
    age_group(ss) = [1 avg_conn(ss,:)]*beta_group;
    
%      % a SVM prediction
%      score = zeros(length(list_c),length(list_g));
%      samp = [ones(length(group)-1,1) avg_conn(mask,:)];
%      for num_c = 1:length(list_c)
%          for num_g = 1:length(list_g)
%              for ss2 = 1:(length(group)-2) %% Nested cross-validation
%                  mask2 = true(length(group)-1,1);
%                  mask2(ss2) = false;
%                  model_svm = svmtrain(x(mask2,2),samp(mask2,:),sprintf('-s 2 -t 2 -q -c %1.10f -g %1.10f',list_c(num_c),list_g(num_g)));
%                  val_pred = svmpredict(x(ss2,2),samp(ss2,:),model_svm);
%                  score(num_c,num_g) = score(num_c,num_g) + (val_pred-x(ss2,2))^2;
%               end
%               score(num_c,num_g) = sqrt(score(num_c,num_g)/(length(group)-2));
%          end
%      end
%      [score_min,ind] = min(score(:));
%      [ind_c,ind_g] = ind2sub(size(score),ind);
%      model_svm = svmtrain(x(:,2),samp,sprintf('-s 2 -t 2 -c %1.10f -g %1.10f',list_c(ind_c),list_g(ind_g)));
%      group_hat(ss) = svmpredict(group(ss),[1 avg_conn(ss,:)],model_svm);
end
group_hat = zeros(size(age_group));
group_hat(age_group>0) = 1;
group_hat(age_group<=0) = -1;
sum(group==group_hat(:))/length(group)