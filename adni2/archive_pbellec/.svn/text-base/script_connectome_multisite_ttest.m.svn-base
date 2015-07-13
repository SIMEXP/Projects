clear

%% Read data
%path_conn = '/home/pbellec/database/adni2/connectomes_multisite';
[x,lx,ly]    = niak_read_csv(['/home/danserea/svn/projects/christian/adni2/adni2_demographic_multisite.csv']);
[y,lyx,lyy] = niak_read_csv(['/home/danserea/database/adni2/connectomes_multisite/summary_graph_prop_basc.csv']);
y = y(:,37:end); % keep only p2p 
lyy = lyy(37:end);
[mask,ind] = ismember(lyx,lx);
x = x(ind,:);
lx = lx(ind);

mask_apriori = ismember(lyy,{'p2p_PCC_X_PCUN','p2p_dMPFC_X_dMPFC2','p2p_IPL_X_SFGr','p2p_aMPFC_X_PCUN','p2p_SFGr_X_FUS','p2p_PCC_X_PCUNm','p2p_IPL_X_dMPFC3','p2p_PCC_X_MTL','p2p_IPL_X_MTL','p2p_aMPFC_X_MTL'});

%% Build masks
mask_ctl = x(:,3) == 1;
mask_mci = x(:,3) == 2;
mask_ad  = x(:,3) == 3;
fprintf('CTL: %i, MCI: %i, DTA: %i\n',sum(mask_ctl),sum(mask_mci),sum(mask_ad));

q = 0.2;

%% Run a test for CTL minus AD
x2 = [ones(size(x,1),1) x(:,[1,2,3,8,9])]; % intercept, gender, age, diagnosis, siemensVSphilips
x2 = x2(mask_ctl|mask_ad,:);
x2(:,4) = mask_ad(mask_ctl|mask_ad);
y2 = y(mask_ctl|mask_ad,:);
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 0 0 1 0 0]');
[fdr,test] = niak_fdr(pce(:),'BH',q);
sum(test)
lyy(pce<0.05)
pce(mask_apriori)

%% Run a test for MCI minus AD
x2 = [ones(size(x,1),1) x(:,[1,2,3,8,9])]; % intercept, gender, age, diagnosis, siemensVSphilips
x2 = x2(mask_mci|mask_ad,:);
x2(:,4) = mask_ad(mask_mci|mask_ad);
y2 = y(mask_mci|mask_ad,:);
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 0 0 1 0 0]');
[fdr,test] = niak_fdr(pce(:),'BH',q);
sum(test)
lyy(pce<0.05)
pce(mask_apriori)

%% Run a test for MCI minus CTL
x2 = [ones(size(x,1),1) x(:,[1,2,3,8,9])]; % intercept, gender, age, diagnosis, siemensVSphilips
x2 = x2(mask_mci|mask_ctl,:);
x2(:,4) = mask_mci(mask_mci|mask_ctl);
y2 = y(mask_mci|mask_ctl,:);
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 0 0 1 0 1]');
[fdr,test] = niak_fdr(pce(:),'BH',q);
sum(test)
lyy(pce<0.05)
pce(mask_apriori)

%% Run a test for AD minus CTL -- ADNI2 + AD-CRUGM
x2 = [ones(size(x,1),1) x(:,[1,2,3])]; % intercept, gender, age
mask = (mask_ctl|mask_ad)&((x(:,8)==1)|(x(:,9)==1));
x2 = x2(mask,:);
x2(:,4) = mask_ad(mask);
y2 = y(mask,:);
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 0 0 1]');
[fdr,test] = niak_fdr(pce(:),'BH',q);
sum(test)
lyy(pce<0.05)
pce(mask_apriori)
lyy(mask_apriori)

%% Run a test for MCI minus CTL -- ADNI2 + MNI-MCI
x2 = [ones(size(x,1),1) x(:,[1,2,3])]; % intercept, gender, age
mask = (mask_ctl|mask_mci)&((x(:,8)==1)|(x(:,9)==0));
x2 = x2(mask,:);
x2(:,4) = mask_mci(mask);
y2 = y(mask,:);
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 0 0 1]');
[fdr,test] = niak_fdr(pce(:),'BH',q);
sum(test)
lyy(pce<0.05)
pce(mask_apriori)
lyy(mask_apriori)

%% Run a test for AD minus CTL -- ADNI2 only
x2 = [ones(size(x,1),1) x(:,[1,2,3])]; % intercept, gender, age, diagnosis, siemensVSphilips
mask = (mask_ctl|mask_ad)&(x(:,8)==1);
x2 = x2(mask,:);
x2(:,4) = mask_ad(mask);
y2 = y(mask,:);
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 0 0 1]');
[fdr,test] = niak_fdr(pce(mask_apriori)','BH',q);
sum(test)
lyy(pce<0.05)
pce(mask_apriori)
lyy(mask_apriori)

%% Run a test for MCI minus CTL -- ADNI2 only
x2 = [ones(size(x,1),1) x(:,[1,2,3])]; % intercept, gender, age, diagnosis, siemensVSphilips
mask = (mask_ctl|mask_mci)&(x(:,8)==1);
x2 = x2(mask,:);
x2(:,4) = mask_mci(mask);
y2 = y(mask,:);
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 0 0 1]');
[fdr,test] = niak_fdr(pce(mask_apriori)','BH',q);
sum(test)
lyy(pce<0.05)
pce(mask_apriori)
lyy(mask_apriori)

%% Run a test for MCI minus AD -- ADNI2 only
x2 = [ones(size(x,1),1) x(:,[1,2,3])]; % intercept, gender, age, diagnosis
mask = (mask_ad|mask_mci)&(x(:,8)==1);
x2 = x2(mask,:);
x2(:,4) = mask_mci(mask);
y2 = y(mask,:);
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 0 0 1]');
[fdr,test] = niak_fdr(pce(:),'BH',q);
sum(test)
lyy(pce<0.05)
pce(mask_apriori)
lyy(mask_apriori)

%% Run a test for AD minus CTL -- AD-CRIUGM only
x2 = [ones(size(x,1),1) x(:,[1,2,3])]; % intercept, gender, age, diagnosis
x2 = x2((mask_ctl|mask_ad)&(x(:,9)==1),:);
x2(:,4) = mask_ad((mask_ctl|mask_ad)&(x(:,9)==1));
y2 = y((mask_ctl|mask_ad)&(x(:,9)==1),:);
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 0 0 1]');
[fdr,test] = niak_fdr(pce(:),'BH',q);
sum(test)
lyy(pce<0.05)
pce(mask_apriori)
lyy(mask_apriori)

%% Run a test for MCI minus CTL -- MNI-MCI only
x2 = [ones(size(x,1),1) x(:,[1,2,3])]; % intercept, gender, age, diagnosis
x2 = x2((mask_ctl|mask_mci)&(x(:,9)==0)&(x(:,8)==0),:);
x2(:,4) = mask_mci((mask_ctl|mask_mci)&(x(:,9)==0)&(x(:,8)==0));
y2 = y((mask_ctl|mask_mci)&(x(:,9)==0)&(x(:,8)==0),:);
[beta,e,std_e,ttest,pce] = niak_lse(y2,x2,[0 0 0 1]');
[fdr,test] = niak_fdr(pce(:),'BH',q);
sum(test)
lyy(pce<0.05)
pce(mask_apriori)
lyy(mask_apriori)
