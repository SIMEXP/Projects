clear all

%% add niak path
addpath(genpath('/sb/project/gsf-624-aa/quarantaine/niak-boss-0.12.18'))

%% input

path_results =  '/home/atam/database/adnet/results/glm30b_20141216_nii/';
path_scale =    {'sci35_scg35_scf33'};
path_contrast = {'ctrlvsmci'};
path_overlap = {'ctrlvsmci'}; % for % disc

data_contrast = {'ctrlvsmci'};
data_overlap = {'ctrlvsmci'};  % for % disc

data_seed     = {'22vmpfc','9dpfc','31sensmot','12mtl'};
data_cluster =   [22 9 31 12];
data_newcluster = [1 2 3 4];


%% Thresholded effect maps
 
% FDR
 
 
for i = 1:length(path_scale)
    for j = 1:length(path_contrast)
        for k = 1:length(data_cluster)
        
[hdr,fdr] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/fdr_',path_overlap{j},'_',path_scale{i},'.nii.gz'));
[hdr,eff] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/effect_',path_overlap{j},'_',path_scale{i},'.nii.gz'));
cluster = data_cluster(k);
mask_fdr = fdr(:,:,:,cluster);
mask_eff = eff(:,:,:,cluster);
eff_new = zeros(size(mask_eff));
% eff_new(mask_fdr>0|mask_fdr<0) = mask_eff(mask_fdr>0|mask_fdr<0);
eff_new(mask_fdr>0) = mask_eff(mask_fdr>0);
eff_new(mask_fdr<0) = mask_eff(mask_fdr<0);
 
hdr.file_name = strcat(path_results,'/',path_scale{i},'/effects/effect_fdr_overlap_',path_contrast{j},'_',data_seed{k},'_',path_scale{i},'.nii.gz');
niak_write_vol(hdr,eff_new);
 
        end
    end
end
