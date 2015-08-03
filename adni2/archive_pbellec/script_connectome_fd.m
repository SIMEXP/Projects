clear

%% Read data
path_adni2 = '/home/pbellec/database/adni2/';
path_nyu = '/home/pbellec/database/NYU_TRT/';
path_res = '/home/pbellec/svn/presentations/triad_2013/figures/fig_fd_adni2';

[x,lx,ly,lz]    = niak_read_csv([path_adni2 filesep 'connectomes_multisite/adni2_demographic_multisite.csv']);
[y,lyx,lyy,lyz] = niak_read_csv([path_adni2 filesep 'qc_scrubbing_group.csv']);

nb_vol = repmat(NaN,[size(x,1),1]);
fd_raw = repmat(NaN,[size(x,1),1]);
fd = repmat(NaN,[size(x,1),1]);
for num_e = 1:length(lx)
    niak_progress(num_e,length(lx));
    ind = find(niak_find_str_cell(lyx,lx{num_e}));
    if ~isempty(ind)
        nb_vol(num_e) = y(ind,2);
        fd_raw(num_e) = y(ind,end-1);
        fd(num_e) = y(ind,end);
    end
end


% Build masks
mask_ad = (x(:,3)==3)&~isnan(fd);
mask_mci = (x(:,3)==2)&~isnan(fd);
mask_ctl = (x(:,3)==1)&~isnan(fd);
bins = 0:0.05:0.5;

%% stats
fprintf('Raw ECN: %i, MCI: %i, DAT: %i\n',sum(mask_ctl),sum(mask_mci),sum(mask_ad))
fprintf('Scrubbed ECN: %i, MCI: %i, DAT: %i\n',sum(mask_ctl&(nb_vol>70)),sum(mask_mci&(nb_vol>70)),sum(mask_ad&(nb_vol>70)))

%% figure AD
figure
hist(fd_raw(mask_ad),bins);
axis([0 0.55 0 20])
print('/home/pbellec/svn/presentations/triad_2013/figures/fig_fd_adni2/fd_raw_ad.pdf','-dpdf')

%% figure MCI
figure
hist(fd_raw(mask_mci),bins);
axis([0 0.55 0 20])
print('/home/pbellec/svn/presentations/triad_2013/figures/fig_fd_adni2/fd_raw_mci.pdf','-dpdf')

%% figure CTL
figure
hist(fd_raw(mask_ctl),bins);
axis([0 0.55 0 20])
print('/home/pbellec/svn/presentations/triad_2013/figures/fig_fd_adni2/fd_raw_ctl.pdf','-dpdf')

%% figure NYU_TRT
figure
[fd_nyu,xnyu,ynyu] = niak_read_csv([path_nyu 'qc_scrubbing_group.csv']);
hist(fd_nyu(niak_find_str_cell(xnyu,'session3'),3),bins);
axis([0 0.55 0 20])
print('/home/pbellec/svn/presentations/triad_2013/figures/fig_fd_adni2/fd_raw_nyu.pdf','-dpdf')

%% figure AD
figure
hist(fd(mask_ad),bins);
axis([0 0.55 0 20])
print('/home/pbellec/svn/presentations/triad_2013/figures/fig_fd_adni2/fd_ad.pdf','-dpdf')

%% figure MCI
figure
hist(fd(mask_mci),bins);
axis([0 0.55 0 20])
print('/home/pbellec/svn/presentations/triad_2013/figures/fig_fd_adni2/fd_mci.pdf','-dpdf')

%% figure CTL
figure
hist(fd(mask_ctl),bins);
axis([0 0.55 0 20])
print('/home/pbellec/svn/presentations/triad_2013/figures/fig_fd_adni2/fd_ctl.pdf','-dpdf')

%% figure NYU_TRT
figure
[fd_nyu,xnyu,ynyu] = niak_read_csv([path_nyu 'qc_scrubbing_group.csv']);
fd_nyu = fd_nyu(niak_find_str_cell(xnyu,'session3'),:);
hist(fd_nyu(:,4),bins);
axis([0 0.55 0 20])
print('/home/pbellec/svn/presentations/triad_2013/figures/fig_fd_adni2/fd_nyu.pdf','-dpdf')
sum(fd_nyu(:,2)>(fd_nyu(:,1)/2))