%% script to make masks from basc on dartel on adni

clear all

% set the paths and inputs
all_path = '/Users/AngelaTam/Desktop/adsf/adni_dartel/';
path_basc = [all_path 'basc_msteps_20160912_1/stability_ind/adni/sci10_scf9/brain_partition_consensus_ind_adni_sci10_scf9.nii.gz'];
path_out = [all_path 'basc_masks/'];
scale = 9;

% read the parcellation
[hdr,parc] = niak_read_vol(path_basc);

% make a logical mask of whole brain
wb_mask = parc > 0;

%% make masks out of each network

for nn = 1:max(parc(:)) % for every network in parcellation
    mask = wb_mask.*(parc == nn);
    mask = mask > 0; % make the mask logical
    hdr.file_name = strcat(path_out, 'adni_dartel_basc_sc', num2str(scale), '_net', num2str(nn), '.nii.gz');
    niak_write_vol(hdr,mask)
end

