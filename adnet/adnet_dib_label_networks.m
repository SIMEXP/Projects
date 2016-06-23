%%%%%%%%% generate labels for clusters


%% extract each network in scale 6

clear all

path_data = '/Users/AngelaTam/Desktop/1480461/template_mcinet_basc_sym_clusters_nii/';
scale6 = [path_data 'brain_parcellation_mcinet_basc_sym_6clusters.nii.gz'];
[hdr,mask] = niak_read_vol(scale6);
networks = [1 2 3 4 5 6];

for nn = 1:length(networks)
    net = networks(nn);
    submask = zeros(size(mask));
    submask(mask==net) = 1;
    hdr.file_name = strcat(path_data, 'network_', num2str(net), '.nii.gz');
    niak_write_vol(hdr,submask);
end

%% make the labels

clear all

path_data = '/Users/AngelaTam/Desktop/data_in_brief/parcellations/';
path_clus = [path_data 'template_mcinet_basc_sym_clusters_nii/'];

files_in.cluster = [path_data 'scale_6_networks_sym/salience.nii.gz'];

nb_clus = [12 22 33 65 111 208];

for nn = 1:length(nb_clus)

    files_in.subcluster = [path_clus 'brain_parcellation_mcinet_basc_sym_' num2str(nb_clus(nn)) 'clusters.nii.gz'];
    
    files_out = struct;
    files_out.subcluster = {strcat('salience_res', num2str(nb_clus(nn)), '.nii.gz')};
    opt.folder_out = [path_clus 'labels/'];
    
    niak_brick_subclusters(files_in,files_out,opt);

end



