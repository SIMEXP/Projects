clear

%% Read data
%path_conn = '~/database/adni2/connectomes_multisite';
[x,lx,ly,lz]    = niak_read_csv(['/home/danserea/svn/projects/christian/adni2/adni2_demographic_multisite.csv']);
[y,lyx,lyy,lyz] = niak_read_csv(['/home/danserau/database/adni2/connectomes_multisite/summary_graph_prop_basc.csv']);
y = y(:,37:end); % keep only p2p 
lyy = lyy(37:end);
[mask,ind] = ismember(lyx,lx);
x = x(ind,:);

%% Build masks
mask_ctl = x(:,3) == 1;
mask_mci = x(:,3) == 2;
mask_ad  = x(:,3) == 3;
fprintf('CTL: %i, MCI: %i, DTA: %i\n',sum(mask_ctl),sum(mask_mci),sum(mask_ad));

%% Run a test for CTL|MCI minus AD
x2 = [ones(size(x,1),1) x(:,[1,2,3,4])]; % intercept, gender, age, education, diagnosis
x2(:,5) = mask_mci|mask_ctl;
y2 = y;
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 0 0 0 1]');
[fdr,test] = niak_fdr(pce(:),'BH',0.2);
sum(test)

%% Run a test for CTL minus AD
x2 = [ones(size(x,1),1) x(:,[1,2,3,4])]; % intercept, gender, age, education, diagnosis
x2 = x2(mask_ctl|mask_ad,:);
x2(:,5) = mask_ad(mask_ctl|mask_ad);
y2 = y(mask_ctl|mask_ad,:);
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 0 0 0 1]');
[fdr,test] = niak_fdr(pce(:),'BH',0.2);
sum(test)

%% Run a test for MCI minus AD
x2 = [ones(size(x,1),1) x(:,[1,2,3,4])]; % intercept, gender, age, education, diagnosis
x2 = x2(mask_mci|mask_ad,:);
x2(:,5) = mask_ad(mask_mci|mask_ad);
y2 = y(mask_mci|mask_ad,:);
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 0 0 0 1]');
[fdr,test] = niak_fdr(pce(:),'BH',0.05);
sum(test)

%% Run a test for MCI minus AD
x2 = [ones(size(x,1),1) x(:,[4])]; % intercept, gender, age, education, diagnosis
x2 = x2(mask_mci|mask_ad,:);
x2(:,2) = mask_ad(mask_mci|mask_ad);
y2 = y(mask_mci|mask_ad,:);
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 1]');
[fdr,test] = niak_fdr(pce(:),'BH',0.05);
sum(test)

%% Run a test for MCI minus CTL
x2 = [ones(size(x,1),1) x(:,[1,2,3,4])]; % intercept, gender, age, education, diagnosis
x2 = x2(mask_mci|mask_ctl,:);
x2(:,5) = mask_mci(mask_mci|mask_ctl);
y2 = y(mask_mci|mask_ctl,:);
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 0 0 0 1]');
[fdr,test] = niak_fdr(pce(:),'BH',0.1);
sum(test)
