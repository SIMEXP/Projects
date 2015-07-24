

[tab,lx,ly]=niak_read_csv('main_scandate_demographic.csv');
tab = tab(23:end,:);
lx = lx(23:end);
subjid = unique(tab(:,1));


tab_variations = [];
for idx = 1:size(subjid,1)
    
    detect = find(ismember(tab(:,1),subjid(idx)));
    diag = tab(detect,3)';
    tab_variations(idx,:) = [subjid(idx) mean(diag-diag(1)) diag(1) diag(end)];
    
    %datenum('14-03-2014','dd-mm-yyyy')
end

ndeterior = sum(tab_variations(:,2)>0)
nimproved = sum(tab_variations(:,2)<0)
nadconver = sum(tab_variations(:,4)==3 & tab_variations(:,2)>0)