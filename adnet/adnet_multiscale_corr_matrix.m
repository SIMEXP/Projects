%% adnet correlation of effect maps between sites

clear all
%% add niak path
addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-boss-0.12.18'))

%% input

path_data =  '/home/atam/scratch/adnet/results/glm30b_scanner_20151113_nii/'; 

path_scale = {'sci5_scg4_scf4','sci5_scg7_scf6','sci15_scg12_scf12','sci20_scg22_scf22','sci35_scg35_scf33','sci80_scg64_scf65','sci130_scg117_scf111','sci190_scg209_scf208'};

data_seed = {'acc'}; %-2 31 20
data_cluster = [4 6 6 14 28 17 83 176];

[hdr,net] = niak_read_vol(strcat(path_data,'sci35_scg35_scf33/networks_',path_scale{5},'.nii.gz'));

[hdr,vol_sc4] = niak_read_vol(strcat(path_data,'/',path_scale{1},'/ctrlvsmci/effect_ctrlvsmci_',path_scale{1},'.nii.gz'));
tseries_sc4 = niak_vol2tseries(vol_sc4(:,:,:,data_cluster(1)),net>0);

[hdr,vol_sc6] = niak_read_vol(strcat(path_data,'/',path_scale{2},'/ctrlvsmci/effect_ctrlvsmci_',path_scale{2},'.nii.gz'));
tseries_sc6 = niak_vol2tseries(vol_sc6(:,:,:,data_cluster(2)),net>0);

[hdr,vol_sc12] = niak_read_vol(strcat(path_data,'/',path_scale{3},'/ctrlvsmci/effect_ctrlvsmci_',path_scale{3},'.nii.gz'));
tseries_sc12 = niak_vol2tseries(vol_sc12(:,:,:,data_cluster(3)),net>0);

[hdr,vol_sc22] = niak_read_vol(strcat(path_data,'/',path_scale{4},'/ctrlvsmci/effect_ctrlvsmci_',path_scale{4},'.nii.gz'));
tseries_sc22 = niak_vol2tseries(vol_sc22(:,:,:,data_cluster(4)),net>0);

[hdr,vol_sc33] = niak_read_vol(strcat(path_data,'/',path_scale{5},'/ctrlvsmci/effect_ctrlvsmci_',path_scale{5},'.nii.gz'));
tseries_sc33 = niak_vol2tseries(vol_sc33(:,:,:,data_cluster(5)),net>0);

[hdr,vol_sc65] = niak_read_vol(strcat(path_data,'/',path_scale{6},'/ctrlvsmci/effect_ctrlvsmci_',path_scale{6},'.nii.gz'));
tseries_sc65 = niak_vol2tseries(vol_sc65(:,:,:,data_cluster(6)),net>0);

[hdr,vol_sc111] = niak_read_vol(strcat(path_data,'/',path_scale{7},'/ctrlvsmci/effect_ctrlvsmci_',path_scale{7},'.nii.gz'));
tseries_sc111 = niak_vol2tseries(vol_sc111(:,:,:,data_cluster(7)),net>0);

[hdr,vol_sc208] = niak_read_vol(strcat(path_data,'/',path_scale{8},'/ctrlvsmci/effect_ctrlvsmci_',path_scale{8},'.nii.gz'));
tseries_sc208 = niak_vol2tseries(vol_sc208(:,:,:,data_cluster(8)),net>0);

final_matrix = corrcoef([tseries_sc4;tseries_sc6;tseries_sc12;tseries_sc22;tseries_sc33;tseries_sc65;tseries_sc111;tseries_sc208]');

namemat = strcat(path_data,'/multiscale_corr_effects_acc.mat'); 
save(namemat,'final_matrix')

colormap jet
imagesc(final_matrix,[0 1]);
colorbar;
axis square

namefig = strcat(path_data,'/multiscale_corr_effects_acc.pdf');
print(namefig,'-dpdf','-r600') 