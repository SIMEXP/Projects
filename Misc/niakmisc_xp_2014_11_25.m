clear

%% Network FDR
opt_glm.test = 'ttest';
opt_fdr.nb_samps = 1000;
opt_fdr.nb_classes = 7;

%% Load raw data
load glm_ctrlvsmci_sci50_scg50_scf50.mat
model = multisite.model(1);
[hdr,sc] = niak_read_vol('networks_sci50_scg50_scf50.nii.gz');

%% Get rid of AD_CRIUGM's data
ad_criugm = niak_find_str_cell(model.labels_x,'ad_hc');
model.x = model.x(~ad_criugm,:);
model.y = model.y(~ad_criugm,:);
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

%% Run a global analyis -- covariates
model_cov = model;
model_cov.x = [model_cov.x mni_mci adpd];
model_cov.labels_y = [model_cov.labels_y ; { 'mni_mci' ; 'adpd' }];
model_cov.c = [model_cov.c ; [0 ; 0]];
res_glm = niak_glm(model_cov,opt_glm);
[fdr,test] = niak_fdr(res_glm.pce(:),'BH',0.05);
sum(test)/length(test)
perc_disc = mean(niak_lvec2mat(abs(res_glm.ttest)>3),1);
hdr.file_name = 'perc_disc_cov.nii.gz';
niak_write_vol(hdr,niak_part2vol(perc_disc,sc));

%% Metal analysis
opt_fdr2 = opt_fdr;
opt_fdr2.nb_samps = 1;
res = niak_network_fdr(model_metal,[],opt_fdr2);
[fdr,test] = niak_fdr(res.pce(:),'BH',0.1);
sum(test)/length(test)
%perc_disc = mean(niak_lvec2mat(abs(res.ttest)>3),1);
perc_disc = mean(niak_lvec2mat(test),1);
hdr.file_name = 'perc_disc_metal.nii.gz';
niak_write_vol(hdr,niak_part2vol(perc_disc,sc));

res_metal = niak_network_fdr (model,[],opt_fdr);
sum(res.test_fdr{1})
perc_disc = mean(niak_lvec2mat(res_metal.test_fdr{1}),1);
hdr.file_name = 'perc_disc_metal.nii.gz';
niak_write_vol(hdr,niak_part2vol(perc_disc,sc));

%% Metal analysis -- without ADPD
opt_fdr2 = opt_fdr;
opt_fdr2.nb_samps = 1;
res = niak_network_fdr(model_metal([1 2 4]),[],opt_fdr2);
[fdr,test] = niak_fdr(res.pce(:),'BH',0.1);
sum(test)/length(test)
%perc_disc = mean(niak_lvec2mat(abs(res.ttest)>3),1);
perc_disc = mean(niak_lvec2mat(test),1);
hdr.file_name = 'perc_disc_metal_without_adpd.nii.gz';
niak_write_vol(hdr,niak_part2vol(perc_disc,sc));

%% MNI MCI
opt_fdr2 = opt_fdr;
opt_fdr2.nb_samps = 1;
res = niak_network_fdr(model_metal(1),[],opt_fdr2);
[fdr,test] = niak_fdr(res.pce(:),'BH',0.1);
sum(test)/length(test)
perc_disc = mean(niak_lvec2mat(abs(res.ttest)>2),1);
hdr.file_name = 'perc_disc_mni_mci.nii.gz';
niak_write_vol(hdr,niak_part2vol(perc_disc,sc));

%% CRIUGM_MCI
%  opt_fdr2 = opt_fdr;
%  opt_fdr2.nb_samps = 1;
%  res = niak_network_fdr(model_metal(2),[],opt_fdr2);
%  [fdr,test] = niak_fdr(res.pce(:),'BH',0.1);
%  sum(test)/length(test)
%  perc_disc = mean(niak_lvec2mat(abs(res.ttest)>2),1);
%  hdr.file_name = 'perc_disc_criugm_mci.nii.gz';
%  niak_write_vol(hdr,niak_part2vol(perc_disc,sc));

res_criugm_mci = niak_network_fdr (model_metal(2),[],opt_fdr);
sum(res_criugm_mci.test_fdr{1})
perc_disc = mean(niak_lvec2mat(res_criugm_mci.test_fdr{1}),1);
hdr.file_name = 'perc_disc_criugm_mci.nii.gz';
niak_write_vol(hdr,niak_part2vol(perc_disc,sc));


%% ADPD
%  opt_fdr2 = opt_fdr;
%  opt_fdr2.nb_samps = 1;
%  res = niak_network_fdr(model_metal(3),[],opt_fdr2);
%  [fdr,test] = niak_fdr(res.pce(:),'BH',0.1);
%  sum(test)/length(test)
%  perc_disc = mean(niak_lvec2mat(abs(res.ttest)>2),1);
%  hdr.file_name = 'perc_disc_adpd.nii.gz';
%  niak_write_vol(hdr,niak_part2vol(perc_disc,sc));

res_adpd = niak_network_fdr (model_metal(3),[],opt_fdr);
sum(res_adpd.test_fdr{1})
perc_disc = mean(niak_lvec2mat(res_adpd.test_fdr{1}),1);
hdr.file_name = 'perc_disc_adpd.nii.gz';
niak_write_vol(hdr,niak_part2vol(perc_disc,sc));

%% ADNI2
%  opt_fdr2 = opt_fdr;
%  opt_fdr2.nb_samps = 1;
%  res = niak_network_fdr(model_metal(4),[],opt_fdr2);
%  [fdr,test] = niak_fdr(res.pce(:),'BH',0.1);
%  sum(test)/length(test)
%  perc_disc = mean(niak_lvec2mat(abs(res.ttest)>2),1);
%  hdr.file_name = 'perc_disc_adni2.nii.gz';
%  niak_write_vol(hdr,niak_part2vol(perc_disc,sc));

res_adni2 = niak_network_fdr (model_metal(4),[],opt_fdr);
sum(res_adni2.test_fdr{1})
perc_disc = mean(niak_lvec2mat(res_adni2.test_fdr{1}),1);
hdr.file_name = 'perc_disc_adni2.nii.gz';
niak_write_vol(hdr,niak_part2vol(perc_disc,sc));
