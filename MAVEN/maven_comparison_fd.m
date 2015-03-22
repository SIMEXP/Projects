clear

% Which metric to work with
% 2: percentage of volumes after qc_scrubbing 
% 3: mean FD before scrubbing 
% 4: mean FD after scrubbing
ind_metric = 4;
list_metric = {'NaN','PercVolumeKept','FDraw','FDresiduals'};
metric = list_metric{ind_metric};

%% Read CSV
[tab,lx,ly] = niak_read_csv('qc_scrubbing_group.csv');
tab(:,2) = tab(:,2)./(tab(:,2)+tab(:,1));
%% Find the inscape entries
ind = find(niak_find_str_cell (lx,'inscape'));

%% Parse the subject labels
list_subject = cell(length(ind),1);
for ss = 1:length(ind)
    label = lx{ind(ss)};
    pos = strfind(label,'_session1');
    list_subject{ss} = label(1:(pos-1));
end

%% Build FD values
%% Column 1: inscape
%% Column 2: rest1
%% Column 3: rest2
val = zeros(length(list_subject),3);
list_condition = { 'inscape' , 'rest1' , 'rest2' };
for ss = 1:length(list_subject)
    subject = list_subject{ss};
    for cc = 1:length(list_condition)
        condition = list_condition{cc};
        label = [subject '_session1_' condition];
        ind = find(niak_find_str_cell(lx,label));
        if isempty(ind)
            warning('Could not find subject %s condition %s',subject,condition)
            val(ss,cc) = NaN;
        end
        val(ss,cc) = tab(ind,ind_metric);
     end
end
    
%% Make a plot of distribution for FD
figure
boxplot(val)
hold on
hp = plot(1+0.2*rand(size(val,1),1),val(:,1),'b.');
set(hp,'markersize',16)
hp = plot(2+0.2*rand(size(val,1),1),val(:,2),'r.');
set(hp,'markersize',16)
hp = plot(3+0.2*rand(size(val,1),1),val(:,3),'k.');
set(hp,'markersize',16)
title (['distribution of ' metric ' in inscapes / rest1 / rest2'])
print('fig_distribution_FD.png','-dpng');

%% Make a plot of distribution for FD rest1 - inscape, FD rest2 - inscape
figure
boxplot([val(:,2)-val(:,1) val(:,3)-val(:,1)])
hold on
hp = plot(1+0.2*rand(size(val,1),1),val(:,2)-val(:,1),'b.');
set(hp,'markersize',16)
hp = plot(2+0.2*rand(size(val,1),1),val(:,3)-val(:,1),'r.');
set(hp,'markersize',16)
title (['distribution of ' metric ' in rest1-inscapes / rest2-inscapes'])
print('fig_distribution_FD_rest_minus_inscapes.png','-dpng');
 
%% Make a t-test
[ttest1,pce1,mean_eff1,std_eff1,df1] = niak_ttest(val(:,2)-val(:,1))
[ttest2,pce2,mean_eff2,std_eff2,df2] = niak_ttest(val(:,3)-val(:,1))