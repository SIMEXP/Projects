%% overlap of results to describe consistency of sites

clear all

%% add niak path
addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-boss-0.12.18'))

%% input

path_results =  '/home/atam/scratch/adnet/results/glm30b_nii/';
path_scale =    {'sci35_scg35_scf33'};
path_contrast = {'ctrlvsmci'}; 

data_seed     = {'22vmpfc','2caudate','9dpfc','12mtl'};
data_cluster =   [22 2 9 12];

mat_file = 'glm_ctrlvsmci_sci35_scg35_scf33.mat';

path_adni = '/home/atam/scratch/adnet/results/glm30b_adni2_nii/sci35_scg35_scf33/ctrlvsmci/';
path_adpd = '/home/atam/scratch/adnet/results/glm30b_adpd_nii/sci35_scg35_scf33/ctrlvsmci/';
path_criugmmci = '/home/atam/scratch/adnet/results/glm30b_criugmmci_nii/sci35_scg35_scf33/ctrlvsmci/';
path_mnimci = '/home/atam/scratch/adnet/results/glm30b_mnimci_nii/sci35_scg35_scf33/ctrlvsmci/';

mat_adni = fullfile(path_adni,mat_file);
mat_adpd = fullfile(path_adpd,mat_file);
mat_criugmmci = fullfile(path_criugmmci,mat_file);
mat_mnimci = fullfile(path_mnimci,mat_file);

data_adni = load(mat_adni);
data_adpd = load(mat_adpd);
data_criugmmci = load(mat_criugmmci);
data_mnimci = load(mat_mnimci);

%% threshold on findings
mask_adni = data_adni.pce <= 0.001;
mask_adpd = data_adpd.pce <= 0.001;
mask_criugmmci = data_criugmmci.pce <= 0.001;
mask_mnimci = data_mnimci.pce <= 0.001;
frequency_of_sites = mask_adni + mask_adpd + mask_criugmmci + mask_mnimci; % summation of individual site masks

aa = niak_lvec2mat(frequency_of_sites);
networks_mask = aa([22,2,9,12],:); % 4x33 matrix; extracting just seeds of interest


for ii = 1:length(path_scale)
    for jj = 1:length(path_contrast)
        for kk =  1:length(data_cluster)
            
            % convert into a volume
            partition = niak_read_vol(strcat(path_results,path_scale{ii},'/','networks_',path_scale{ii},'.nii.gz'));
            vol_freq_mask = niak_part2vol(networks_mask,partition);
            
            [hdr,fdr] = niak_read_vol(strcat(path_results,'/',path_scale{ii},'/',path_contrast{jj},'/fdr_',path_contrast{jj},'_',path_scale{ii},'.nii.gz'));
            for vv=1:size(vol_freq_mask,4)
                mask = fdr(:,:,:,data_cluster(vv))>0; % main mask of significant results
                final_res = vol_freq_mask(:,:,:,vv) & mask; % overlap of main mask with the frequencies at all sites
                hdr.file_name = strcat(path_results,path_scale{ii},'/overlap_freq/overlap_effect_',data_seed{kk},'_',path_scale{ii},'.nii.gz');
                niak_write_vol(hdr,final_res);
            end
        end
    end
end


        









