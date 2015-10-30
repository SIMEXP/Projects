
%% adnet correlation of effect maps between sites

clear all
%% add niak path
addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-boss-0.12.18'))


path_data = '/home/atam/scratch/adnet/results';
path_net = '/home/atam/scratch/adnet/results/glm30b_nii/sci35_scg35_scf33';
path_scale = 'sci35_scg35_scf33';
path_site = {'glm30b_adni2_nii','glm30b_criugmmci_nii','glm30b_adpd_nii','glm30b_mnimci_nii'};
data_cluster = 12;

path_result = '/home/atam/scratch/adnet/results/glm30b_nii/sci35_scg35_scf33/multisite_maps';


[hdr,net] = niak_read_vol(strcat(path_net,'/','networks_',path_scale,'.nii.gz'));

[hdr,vol_adni] = niak_read_vol(strcat(path_data,'/',path_site{1},'/',path_scale,'/ctrlvsmci/effect_ctrlvsmci_sci35_scg35_scf33.nii.gz'));
tseries_adni = niak_vol2tseries(vol_adni(:,:,:,data_cluster),net>0);

[hdr,vol_criugmmci] = niak_read_vol(strcat(path_data,'/',path_site{2},'/',path_scale,'/ctrlvsmci/effect_ctrlvsmci_sci35_scg35_scf33.nii.gz'));
tseries_criugmmci = niak_vol2tseries(vol_criugmmci(:,:,:,data_cluster),net>0);

[hdr,vol_adpd] = niak_read_vol(strcat(path_data,'/',path_site{3},'/',path_scale,'/ctrlvsmci/effect_ctrlvsmci_sci35_scg35_scf33.nii.gz'));
tseries_adpd = niak_vol2tseries(vol_adpd(:,:,:,data_cluster),net>0);

[hdr,vol_mnimci] = niak_read_vol(strcat(path_data,'/',path_site{4},'/',path_scale,'/ctrlvsmci/effect_ctrlvsmci_sci35_scg35_scf33.nii.gz'));
tseries_mnimci = niak_vol2tseries(vol_mnimci(:,:,:,data_cluster),net>0);

final_matrix = corrcoef([tseries_adni;tseries_criugmmci;tseries_adpd;tseries_mnimci]');

namemat = strcat(path_result,'/multisite_corr_effects_0.3_mtl.mat'); 
save(namemat,'final_matrix')

colormap jet
imagesc(final_matrix,[0 1]);
colorbar;
axis square

namefig = strcat(path_result,'/multisite_corr_effects_0.3_mtl.pdf');
print(namefig,'-dpdf','-r600') 


% %% .mat files
% 
% nb_net = 33;
% conn = [32 31];
% min_c = min(conn);
% max_c = max(conn);
% num_conn = (nb_net*(min_c-1)) -sum((0:1:(min_c-2))) +max_c -min_c +1
% 
% % extract names of subjects













