%% Import data
[tab,lx,ly] = niak_read_csv('schizo_weights_5subts.csv');
lcov = ly(1:10);
lsub = ly(11:end);
X = tab(:,1:10); % predictors
Y = tab(:,11:end); % weights

%% Run a metal analysis
num_c = 3;
lcov(num_c)
mask = ~isnan(X(:,num_c));
model.x = [ones(sum(mask),1) X(mask,num_c)];
model.y = Y(mask,:);
model.c = [0;1];
opt.multisite = X(mask,1);
res = niak_glm_multisite (model,opt);
[fdr,test] = niak_fdr(res.pce(:),'BH',0.05);

%% Have a look at the results
sum(test)
min(res.pce)
[val,order] = sort(res.pce);
val(1:3)
order(1:3)

%% Now try a prediction analysis without cross-validating features (shameful!)
num_site = 3;
num_sub = 13;
pred = zeros(size(targ));
targ = model.x(opt.multisite==num_site,2);
sig = model.y(opt.multisite==num_site,num_sub);
for ss = 1:length(targ)
    mask_cc = true(size(targ));
    mask_cc(ss) = false;
    sig_cc = sig(mask_cc);
    targ_cc = sig(mask_cc);
    list_thre = unique(sig_cc);
    acc = zeros(length(list_thre),1);
    acc2 = zeros(length(list_thre),1);
    for tt = 1:length(list_thre)
        thre = list_thre(tt);
        acc(tt) = 1-(sum(targ~=(sig<=thre))/length(targ));
        acc2(tt) = 1-(sum(targ~=(sig>=thre))/length(targ));
    end
    [macc,ind] = max(acc);
    [macc2,ind2] = max(acc2);
    if macc>=macc2
        pred(ss) = sig(ss) <= list_thre(ind);
    else
        pred(ss) = sig(ss) >= list_thre(ind);
    end
end

%% Final accuracy 
acc = 1-(sum(targ~=pred)/length(targ))