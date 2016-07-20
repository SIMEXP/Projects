clear all

%% add niak path
path_niak = ('/gs/project/gsf-624-aa/quarantaine/niak-issue100/')
addpath(genpath(path_niak))

%% input
path_results = '/home/perrine/scratch/RANN/RANN_GLMconnectome/GLM_cont_ant160625.nii'; %% ANTONYMS 
%path_results = '/home/perrine/scratch/RANN/RANN_GLMconnectome/GLM_cont_syn160625.nii'; %% SYNONYMS
%path_results = '/home/perrine/scratch/RANN/RANN_GLMconnectome/GLM_rest5.nii'; %% REST 

path_scale =    {'sci70_scg70_scf68'};
path_contrast = {'age'};
path_overlap = {'age'}; % for % disc

data_contrast = {'age'};
data_overlap = {'age'};  % for % disc

data_seed     = {'63ifg', '65stg','52mtg','62stgL','64mtgp','22mtgm','45itg','32tpole'};
data_cluster =   [63 65 52 62 64 22 45 32];
data_newcluster = [1 2 3 4 5 6 7 8];

%% GLM connectome extraction

for i = 1:length(path_scale)
    for k = 1:length(data_cluster)
        
% map d'un seul cluster (à partir de networks) avec valeur à 1
[hdr,mask] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/networks/networks_',path_scale{i},'.nii.gz'));
submask = zeros(size(mask));
cluster = data_cluster(k);
submask(mask==cluster) = 1;
hdr.file_name = strcat(path_results,'/',path_scale{i},'/networks/cluster_',data_seed{k},'_networks_',path_scale{i},'.nii.gz');
niak_write_vol(hdr,submask);

    end
end
  
  
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
